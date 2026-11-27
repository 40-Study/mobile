import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/data/teacher_leave_api.dart';
import 'package:study/features/teacher/data/teacher_preview_api.dart';
import 'package:study/features/teacher/presentation/leave/teacher_leave_create_screen.dart';
import 'package:study/features/teacher/presentation/leave/teacher_leave_detail_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherLeaveListScreen extends StatefulWidget {
  const TeacherLeaveListScreen({
    super.key,
    required this.api,
    this.organizationId,
    this.workplaceLabel,
  });
  final TeacherApi api;
  final String? organizationId;
  final String? workplaceLabel;

  @override
  State<TeacherLeaveListScreen> createState() => _TeacherLeaveListScreenState();
}

class _TeacherLeaveListScreenState extends State<TeacherLeaveListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late Future<List<TeacherLeaveRequest>?> _future;
  final _withdrawingIds = <String>{};

  bool get _readOnly => widget.api is TeacherPreviewApi;

  static const _tabs = ['Tất cả', 'Chờ duyệt', 'Đã duyệt', 'Từ chối'];
  static const _statusFilters = [null, 'pending', 'approved', 'rejected'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _future = _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<TeacherLeaveRequest>?> _load() async {
    try {
      final list = await teacherAllPages(
        widget.api,
        '/me/leave-requests',
        'leave_requests',
      );
      return list.map(TeacherLeaveRequest.fromJson).toList();
    } on DioException catch (error) {
      if (![404, 405, 501].contains(error.response?.statusCode)) rethrow;
      return null;
    }
  }

  void _reload() => setState(() => _future = _load());

  String _workplaceLabel(TeacherLeaveRequest request) {
    final name = request.organizationName;
    if (name != null && name.trim().isNotEmpty) return name;
    if (request.organizationId == null) return 'Cá nhân';
    if (request.organizationId == widget.organizationId) {
      return widget.workplaceLabel ?? 'Tổ chức';
    }
    return 'Tổ chức khác';
  }

  /// Withdraw leave request via swipe
  Future<bool> _withdrawRequest(TeacherLeaveRequest request) async {
    if (!mounted || _readOnly || !_withdrawingIds.add(request.id)) return false;
    try {
      await widget.api.post('/me/leave-requests/${request.id}/withdraw');
      if (mounted) {
        _reload();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã rút đơn xin nghỉ'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return false; // Không dismiss, reload list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể rút đơn: ${teacherErrorMessage(e)}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return false;
    } finally {
      _withdrawingIds.remove(request.id);
    }
  }

  Future<void> _createLeave() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TeacherLeaveCreateScreen(
          api: widget.api,
          organizationId: widget.organizationId,
          workplaceLabel: widget.workplaceLabel,
        ),
      ),
    );
    if (mounted && result == true) _reload();
  }

  Future<void> _openDetail(TeacherLeaveRequest request) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TeacherLeaveDetailScreen(
          api: widget.api,
          request: request,
          workplaceLabel: _workplaceLabel(request),
        ),
      ),
    );
    if (mounted && result == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TeacherLeaveRequest>?>(
      future: _future,
      builder: (context, snapshot) {
        final canCreate =
            snapshot.connectionState == ConnectionState.done &&
            snapshot.data?.isNotEmpty == true;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Đơn xin nghỉ'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
              onTap: (_) => setState(() {}),
            ),
          ),
          body: Column(
            children: [
              if (teacherUsingSampleLeave(widget.api))
                const ListTile(
                  leading: Icon(Icons.science_outlined),
                  title: Text('Dữ liệu xin nghỉ mẫu'),
                  subtitle: Text(
                    'Đơn chỉ lưu trong phiên này và không thay đổi lịch thật.',
                  ),
                ),
              Expanded(child: _buildBody(context, snapshot)),
            ],
          ),
          floatingActionButton: canCreate
              ? FloatingActionButton.extended(
                  onPressed: _createLeave,
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo đơn'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<List<TeacherLeaveRequest>?> snapshot,
  ) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return TeacherErrorView(error: snapshot.error!, onRetry: _reload);
    }
    final allRequests = snapshot.data;
    if (allRequests == null) {
      return const Center(child: Text('Tính năng xin nghỉ chưa khả dụng.'));
    }
    final statusFilter = _statusFilters[_tabController.index];
    final requests = statusFilter == null
        ? allRequests
        : allRequests.where((r) => r.status == statusFilter).toList();

    if (requests.isEmpty) {
      return allRequests.isEmpty
          ? _buildEmptyState(context)
          : const TeacherEmptyStateInline(
              icon: Icons.filter_list,
              message: 'Không có đơn ở trạng thái này.',
            );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _reload();
        try {
          await _future;
        } catch (_) {
          // The future builder presents the error and retry action.
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.section + AppSpacing.lg,
        ),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          final canWithdraw = !_readOnly && request.status == 'pending';
          return TeacherSwipeToAction(
            itemKey: Key('leave_${request.id}'),
            icon: Icons.undo,
            label: 'Rút đơn',
            color: AchievementColors.yellow,
            enabled: canWithdraw,
            confirmMessage: 'Bạn có chắc muốn rút đơn xin nghỉ này?',
            onAction: () => _withdrawRequest(request),
            child: _LeaveRequestItem(
              request: request,
              workplaceLabel: _workplaceLabel(request),
              onTap: () => _openDetail(request),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return TeacherEmptyState(
      icon: Icons.event_busy_outlined,
      title: 'Chưa có đơn xin nghỉ',
      subtitle: 'Đơn xin nghỉ sẽ hiện ở đây khi bạn tạo.',
      actionLabel: 'Tạo đơn mới',
      onAction: _createLeave,
    );
  }
}

class _LeaveRequestItem extends StatelessWidget {
  const _LeaveRequestItem({
    required this.request,
    this.workplaceLabel,
    required this.onTap,
  });
  final TeacherLeaveRequest request;
  final String? workplaceLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final format = DateFormat('dd/MM/yyyy');
    final (status, background, foreground) = switch (request.status) {
      'pending' => ('Chờ duyệt', cs.tertiaryContainer, cs.onTertiaryContainer),
      'approved' => (
        'Đã duyệt',
        cs.secondaryContainer,
        cs.onSecondaryContainer,
      ),
      'rejected' => ('Từ chối', cs.errorContainer, cs.onErrorContainer),
      'withdrawn' => ('Đã rút', cs.surfaceContainerHigh, cs.onSurfaceVariant),
      _ => ('Chưa rõ trạng thái', cs.surfaceContainerHigh, cs.onSurfaceVariant),
    };
    final from = format.format(request.fromDate);
    final dateRange = DateUtils.isSameDay(request.fromDate, request.toDate)
        ? from
        : '$from – ${format.format(request.toDate)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side: BorderSide(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: AppSpacing.paddingMd,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateRange, style: tt.titleSmall),
                      AppSpacing.vGap4,
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: background,
                              borderRadius: AppRadius.borderSm,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Text(
                                status,
                                style: tt.labelSmall?.copyWith(
                                  color: foreground,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            '${request.affectedSessions.length} buổi bị ảnh hưởng',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (workplaceLabel case final label?) ...[
                        AppSpacing.vGap4,
                        Text(
                          label,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (request.reason.trim().isNotEmpty) ...[
                        AppSpacing.vGap4,
                        Text(
                          request.reason,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AppSpacing.hGap8,
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Model for leave request
class TeacherLeaveRequest {
  const TeacherLeaveRequest({
    required this.id,
    this.organizationId,
    this.organizationName,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
    this.feedback,
    required this.createdAt,
    required this.affectedSessions,
  });

  final String id;
  final String? organizationId;
  final String? organizationName;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final String status;
  final String? feedback;
  final DateTime createdAt;
  final List<AffectedSession> affectedSessions;

  factory TeacherLeaveRequest.fromJson(Map<String, dynamic> json) {
    final sessions =
        (json['affected_sessions'] as List<dynamic>?)
            ?.map((e) => AffectedSession.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return TeacherLeaveRequest(
      id: '${json['id']}',
      organizationId: json['organization_id']?.toString(),
      organizationName: json['organization_name']?.toString(),
      fromDate: DateTime.tryParse('${json['from_date']}') ?? DateTime.now(),
      toDate: DateTime.tryParse('${json['to_date']}') ?? DateTime.now(),
      reason: '${json['reason'] ?? ''}',
      status: '${json['status'] ?? 'pending'}',
      feedback: json['feedback']?.toString(),
      createdAt: DateTime.tryParse('${json['created_at']}') ?? DateTime.now(),
      affectedSessions: sessions,
    );
  }
}

class AffectedSession {
  const AffectedSession({
    required this.id,
    required this.className,
    required this.date,
    required this.time,
  });

  final String id;
  final String className;
  final String date;
  final String time;

  factory AffectedSession.fromJson(Map<String, dynamic> json) {
    return AffectedSession(
      id: '${json['id']}',
      className: '${json['class_name'] ?? ''}',
      date: '${json['date'] ?? ''}',
      time: '${json['time'] ?? ''}',
    );
  }
}
