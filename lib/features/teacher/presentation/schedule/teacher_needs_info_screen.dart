import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

/// Màn hình Cần bổ sung (T06 theo spec).
/// Hiển thị khi giờ của người dạy bị trung tâm trả về.
/// Người dạy chính: sửa được nội dung + lý do sửa.
/// Trợ giảng: chỉ xem lý do, không có ô sửa.
class TeacherNeedsInfoScreen extends StatefulWidget {
  const TeacherNeedsInfoScreen({
    super.key,
    required this.api,
    required this.classId,
    required this.sessionId,
    required this.className,
    required this.date,
    this.isAssistant = false,
  });

  final TeacherApi api;
  final String classId;
  final String sessionId;
  final String className;
  final String date;

  /// Trợ giảng chỉ xem lý do, không sửa được
  final bool isAssistant;

  @override
  State<TeacherNeedsInfoScreen> createState() => _TeacherNeedsInfoScreenState();
}

class _TeacherNeedsInfoScreenState extends State<TeacherNeedsInfoScreen> {
  late Future<_NeedsInfoData> _future;
  final _contentController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _saving = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<_NeedsInfoData> _load() async {
    final session = teacherPayload(
      await widget.api.get(
        '/classes/${widget.classId}/sessions/${widget.sessionId}',
      ),
    );

    // Pre-fill content
    final existingContent = session['notes']?.toString() ?? '';
    if (_contentController.text.isEmpty) {
      _contentController.text = existingContent;
    }

    // Duration
    final startTime = session['start_time']?.toString() ?? '00:00';
    final endTime = session['end_time']?.toString() ?? '00:00';
    final duration = _calculateDuration(startTime, endTime);

    // Rejection info
    final rejectionReason = session['rejection_reason']?.toString() ?? '';
    final rejectedAt = session['rejected_at']?.toString();

    return _NeedsInfoData(
      session: session,
      duration: duration,
      rejectionReason: rejectionReason,
      rejectedAt: rejectedAt,
    );
  }

  int _calculateDuration(String start, String end) {
    final startParts = start.split(':');
    final endParts = end.split(':');
    final startMin = (int.tryParse(startParts.first) ?? 0) * 60 +
        (int.tryParse(startParts.length > 1 ? startParts[1] : '0') ?? 0);
    final endMin = (int.tryParse(endParts.first) ?? 0) * 60 +
        (int.tryParse(endParts.length > 1 ? endParts[1] : '0') ?? 0);
    return endMin > startMin ? endMin - startMin : 0;
  }

  Future<void> _submit() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập lý do sửa')),
      );
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.api.put(
        '/classes/${widget.classId}/sessions/${widget.sessionId}',
        data: {
          'notes': _contentController.text,
          'revision_reason': _reasonController.text,
          'hour_confirmation_status': 'pending',
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi lại thành công')),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cần bổ sung')),
      body: FutureBuilder<_NeedsInfoData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return TeacherErrorView(
              error: snapshot.error!,
              onRetry: () => setState(() => _future = _load()),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final hours = data.duration ~/ 60;
          final mins = data.duration % 60;
          final durationText = hours > 0
              ? '$hours giờ${mins > 0 ? ' $mins phút' : ''}'
              : '$mins phút';

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: AppSpacing.paddingScreenAll,
                  children: [
                    // Session info
                    Text(
                      widget.className,
                      style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      widget.date,
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    AppSpacing.vGap24,

                    // Rejection reason from center
                    Container(
                      padding: AppSpacing.paddingLg,
                      decoration: BoxDecoration(
                        color: AchievementColors.red.withValues(alpha: 0.1),
                        borderRadius: AppRadius.borderMd,
                        border: Border.all(
                          color: AchievementColors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AchievementColors.red,
                                size: 20,
                              ),
                              AppSpacing.hGap8,
                              Text(
                                'Lý do trung tâm trả về',
                                style: tt.titleSmall?.copyWith(
                                  color: AchievementColors.red,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.vGap8,
                          Text(
                            data.rejectionReason.isEmpty
                                ? 'Không có lý do cụ thể'
                                : data.rejectionReason,
                            style: tt.bodyMedium,
                          ),
                          if (data.rejectedAt != null) ...[
                            AppSpacing.vGap4,
                            Text(
                              'Ngày trả: ${teacherDisplayDate(data.rejectedAt)}',
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    AppSpacing.vGap24,

                    // Duration (read-only)
                    Container(
                      padding: AppSpacing.paddingLg,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.schedule, color: cs.onSurfaceVariant),
                          AppSpacing.hGap12,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Giờ được tính',
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  durationText,
                                  style: tt.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Không sửa',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.vGap24,

                    if (widget.isAssistant) ...[
                      // Assistant view - read only
                      Container(
                        padding: AppSpacing.paddingLg,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: AppRadius.borderMd,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: cs.onSurfaceVariant,
                            ),
                            AppSpacing.vGap8,
                            Text(
                              'Bạn là trợ giảng của buổi này. '
                              'Vui lòng liên hệ trung tâm để được hỗ trợ.',
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Main teacher - can edit
                      Text(
                        'Nội dung đã dạy',
                        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      AppSpacing.vGap8,
                      TextField(
                        controller: _contentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Mô tả nội dung đã dạy...',
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.borderMd,
                          ),
                        ),
                      ),
                      AppSpacing.vGap16,

                      Text(
                        'Lý do sửa (bắt buộc)',
                        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      AppSpacing.vGap8,
                      TextField(
                        controller: _reasonController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Giải thích lý do bổ sung/sửa thông tin...',
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.borderMd,
                          ),
                        ),
                      ),
                    ],

                    if (_error != null) ...[
                      AppSpacing.vGap16,
                      Text(
                        'Lỗi: $_error',
                        style: tt.bodySmall?.copyWith(color: cs.error),
                      ),
                    ],
                  ],
                ),
              ),
              if (!widget.isAssistant)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: AppSpacing.paddingLg,
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving ? null : _submit,
                        child: Text(_saving ? 'Đang gửi...' : 'Gửi lại'),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _NeedsInfoData {
  const _NeedsInfoData({
    required this.session,
    required this.duration,
    required this.rejectionReason,
    this.rejectedAt,
  });

  final Map<String, dynamic> session;
  final int duration;
  final String rejectionReason;
  final String? rejectedAt;
}
