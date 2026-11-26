import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/leave/teacher_leave_create_screen.dart';
import 'package:study/features/teacher/presentation/leave/teacher_leave_detail_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherLeaveListScreen extends StatefulWidget {
  const TeacherLeaveListScreen({
    super.key,
    required this.api,
    this.organizationId,
  });
  final TeacherApi api;
  final String? organizationId;

  @override
  State<TeacherLeaveListScreen> createState() => _TeacherLeaveListScreenState();
}

class _TeacherLeaveListScreenState extends State<TeacherLeaveListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late Future<List<TeacherLeaveRequest>> _future;

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

  Future<List<TeacherLeaveRequest>> _load() async {
    final raw = await widget.api.get('/me/leave-requests');
    final list = teacherList(teacherMap(raw), keys: const ['leave_requests']);
    return list.map((e) => TeacherLeaveRequest.fromJson(e)).toList();
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _createLeave() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TeacherLeaveCreateScreen(
          api: widget.api,
          organizationId: widget.organizationId,
        ),
      ),
    );
    if (result == true) _reload();
  }

  Future<void> _openDetail(TeacherLeaveRequest request) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TeacherLeaveDetailScreen(
          api: widget.api,
          request: request,
        ),
      ),
    );
    if (result == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn xin nghỉ'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          onTap: (_) => setState(() {}),
        ),
      ),
      body: FutureBuilder<List<TeacherLeaveRequest>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return TeacherErrorView(
              error: snapshot.error!,
              onRetry: _reload,
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allRequests = snapshot.data!;
          final statusFilter = _statusFilters[_tabController.index];
          final requests = statusFilter == null
              ? allRequests
              : allRequests.where((r) => r.status == statusFilter).toList();

          if (requests.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _future;
            },
            child: ListView.builder(
              padding: AppSpacing.paddingScreenAll,
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return _LeaveRequestItem(
                  request: request,
                  onTap: () => _openDetail(request),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createLeave,
        icon: const Icon(Icons.add),
        label: const Text('Tạo đơn'),
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
  const _LeaveRequestItem({required this.request, required this.onTap});
  final TeacherLeaveRequest request;
  final VoidCallback onTap;

  Color _statusColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (request.status) {
      case 'pending':
        return AchievementColors.yellow;
      case 'approved':
        return AchievementColors.green;
      case 'rejected':
        return cs.error;
      case 'withdrawn':
        return cs.onSurfaceVariant;
      default:
        return cs.primary;
    }
  }

  String get _statusLabel {
    switch (request.status) {
      case 'pending':
        return 'Chờ duyệt';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Từ chối';
      case 'withdrawn':
        return 'Đã rút';
      default:
        return request.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final statusColor = _statusColor(context);

    final dateRange = request.fromDate == request.toDate
        ? dateFormat.format(request.fromDate)
        : '${dateFormat.format(request.fromDate)} - ${dateFormat.format(request.toDate)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF010120).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.borderLg,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: AppRadius.borderSm,
                        ),
                        child: Icon(
                          _statusIcon,
                          size: 20,
                          color: statusColor,
                        ),
                      ),
                      AppSpacing.hGap12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateRange,
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${request.affectedSessions.length} buổi bị ảnh hưởng',
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _statusLabel,
                          style: tt.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (request.reason.isNotEmpty) ...[
                    AppSpacing.vGap12,
                    Text(
                      request.reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                  AppSpacing.vGap12,
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tạo ${DateFormat('dd/MM/yyyy').format(request.createdAt)}',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: cs.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData get _statusIcon {
    switch (request.status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'withdrawn':
        return Icons.undo;
      default:
        return Icons.event_busy_outlined;
    }
  }
}

/// Model for leave request
class TeacherLeaveRequest {
  const TeacherLeaveRequest({
    required this.id,
    this.organizationId,
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
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final String status;
  final String? feedback;
  final DateTime createdAt;
  final List<AffectedSession> affectedSessions;

  factory TeacherLeaveRequest.fromJson(Map<String, dynamic> json) {
    final sessions = (json['affected_sessions'] as List<dynamic>?)
            ?.map((e) => AffectedSession.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return TeacherLeaveRequest(
      id: '${json['id']}',
      organizationId: json['organization_id']?.toString(),
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
