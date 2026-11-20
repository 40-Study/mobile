import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/leave/teacher_leave_create_screen.dart';
import 'package:study/features/teacher/presentation/leave/teacher_leave_detail_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/app_spacing.dart';

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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có đơn xin nghỉ',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _createLeave,
            icon: const Icon(Icons.add),
            label: const Text('Tạo đơn mới'),
          ),
        ],
      ),
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
        return Colors.orange;
      case 'approved':
        return Colors.green;
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
    final dateFormat = DateFormat('dd/MM/yyyy');

    final dateRange = request.fromDate == request.toDate
        ? dateFormat.format(request.fromDate)
        : '${dateFormat.format(request.fromDate)} - ${dateFormat.format(request.toDate)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dateRange,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _statusLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: _statusColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                request.reason,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.school_outlined, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${request.affectedSessions.length} buổi bị ảnh hưởng',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    'Tạo ${DateFormat('dd/MM').format(request.createdAt)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
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
