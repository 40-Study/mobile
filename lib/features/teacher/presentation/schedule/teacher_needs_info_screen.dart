import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

/// Hiển thị lý do trung tâm trả về khi buổi dạy cần bổ sung.
class TeacherNeedsInfoScreen extends StatefulWidget {
  const TeacherNeedsInfoScreen({
    super.key,
    required this.api,
    required this.classId,
    required this.sessionId,
    required this.className,
    required this.date,
    this.isAssistant = false,
    this.initial = const {},
    this.sample = false,
  });

  final TeacherApi api;
  final String classId;
  final String sessionId;
  final String className;
  final String date;
  final Map<String, dynamic> initial;
  final bool sample;

  /// Trợ giảng chỉ xem lý do, không sửa được
  final bool isAssistant;

  @override
  State<TeacherNeedsInfoScreen> createState() => _TeacherNeedsInfoScreenState();
}

class _TeacherNeedsInfoScreenState extends State<TeacherNeedsInfoScreen> {
  late Future<_NeedsInfoData> _future;
  final _sampleNotes = TextEditingController();
  bool _sampleSent = false;
  bool get _sample => widget.sample && teacherDevSamplesEnabled;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _sampleNotes.dispose();
    super.dispose();
  }

  Future<_NeedsInfoData> _load() async {
    final session = _sample
        ? widget.initial
        : teacherPayload(
            await widget.api.get(
              '/classes/${widget.classId}/sessions/${widget.sessionId}',
            ),
          );

    // Duration
    final startTime = teacherTime(
      session['start_time'] ?? widget.initial['start_time'],
    );
    final endTime = teacherTime(
      session['end_time'] ?? widget.initial['end_time'],
    );
    final duration = _calculateDuration(startTime, endTime);

    // Rejection info
    final rejectionReason =
        (session['rejection_reason'] ?? widget.initial['rejection_reason'])
            ?.toString()
            .trim() ??
        '';
    final rejectedAt = (session['rejected_at'] ?? widget.initial['rejected_at'])
        ?.toString();

    return _NeedsInfoData(
      duration: duration,
      rejectionReason: rejectionReason,
      rejectedAt: rejectedAt,
    );
  }

  int _calculateDuration(String start, String end) {
    final startParts = start.split(':');
    final endParts = end.split(':');
    if (startParts.length != 2 || endParts.length != 2) return 0;
    final startHour = int.tryParse(startParts[0]);
    final startMinute = int.tryParse(startParts[1]);
    final endHour = int.tryParse(endParts[0]);
    final endMinute = int.tryParse(endParts[1]);
    if (startHour == null ||
        startMinute == null ||
        endHour == null ||
        endMinute == null) {
      return 0;
    }
    final startMin = startHour * 60 + startMinute;
    final endMin = endHour * 60 + endMinute;
    return endMin > startMin ? endMin - startMin : 0;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final date = DateTime.tryParse(widget.date)?.toLocal();
    final dateLabel = date == null
        ? null
        : DateFormat('dd/MM/yyyy').format(date);

    return Scaffold(
      appBar: AppBar(title: const Text('Yêu cầu bổ sung giờ dạy')),
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
          final durationText = data.duration == 0
              ? 'Chưa có thời lượng'
              : hours > 0
              ? '$hours giờ${mins > 0 ? ' $mins phút' : ''}'
              : '$mins phút';

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: AppSpacing.paddingScreenAll,
                  children: [
                    if (_sample) ...[
                      const Text('Dữ liệu mẫu · Không gửi đến trung tâm'),
                      AppSpacing.vGap12,
                    ],
                    Container(
                      padding: AppSpacing.paddingLg,
                      decoration: BoxDecoration(
                        color: cs.tertiaryContainer,
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: cs.onTertiaryContainer,
                                size: 20,
                              ),
                              AppSpacing.hGap8,
                              Expanded(
                                child: Text(
                                  'Lý do trung tâm trả về',
                                  style: tt.titleSmall?.copyWith(
                                    color: cs.onTertiaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.vGap8,
                          Text(
                            data.rejectionReason.isEmpty
                                ? 'Trung tâm chưa ghi lý do.'
                                : data.rejectionReason,
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onTertiaryContainer,
                            ),
                          ),
                          if (data.rejectedAt != null) ...[
                            AppSpacing.vGap4,
                            Text(
                              'Ngày trả: ${teacherDisplayDate(data.rejectedAt)}',
                              style: tt.labelSmall?.copyWith(
                                color: cs.onTertiaryContainer,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    AppSpacing.vGap24,

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
                                  widget.className,
                                  style: tt.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                AppSpacing.vGap4,
                                Text(
                                  [
                                    if (dateLabel != null) dateLabel,
                                    durationText,
                                  ].join(' · '),
                                  style: tt.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.vGap24,

                    if (widget.isAssistant)
                      const Text(
                        'Bạn là trợ giảng của buổi này. '
                        'Liên hệ trung tâm để được hỗ trợ.',
                      )
                    else if (!_sample)
                      const Text('Chưa thể gửi bổ sung từ ứng dụng.'),
                    if (_sample) ...[
                      TextField(
                        controller: _sampleNotes,
                        enabled: !_sampleSent,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Nội dung bổ sung',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      AppSpacing.vGap12,
                      FilledButton(
                        onPressed:
                            _sampleSent || _sampleNotes.text.trim().isEmpty
                            ? null
                            : () => setState(() => _sampleSent = true),
                        child: Text(_sampleSent ? 'Đã gửi thử' : 'Gửi thử'),
                      ),
                    ],
                  ],
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
    required this.duration,
    required this.rejectionReason,
    this.rejectedAt,
  });

  final int duration;
  final String rejectionReason;
  final String? rejectedAt;
}
