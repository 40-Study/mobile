import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/data/teacher_notification_api.dart';
import 'package:study/features/teacher/data/teacher_preview_api.dart';
import 'package:study/features/teacher/presentation/leave/teacher_leave_detail_screen.dart';
import 'package:study/features/teacher/presentation/leave/teacher_leave_list_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherNotificationsScreen extends StatefulWidget {
  const TeacherNotificationsScreen({
    super.key,
    required this.api,
    this.leaveApi,
    this.confirmWorkplace,
  });

  final TeacherApi api;
  final TeacherApi? leaveApi;
  final Future<String?> Function(String? organizationId)? confirmWorkplace;

  @override
  State<TeacherNotificationsScreen> createState() =>
      _TeacherNotificationsScreenState();
}

class _TeacherNotificationsScreenState
    extends State<TeacherNotificationsScreen> {
  late final _api = TeacherNotificationApi(widget.api);
  final _items = <TeacherNotification>[];
  final _readIds = <String>{};
  final _markingIds = <String>{};
  bool _loading = false;
  bool _hasMore = false;
  int _page = 0;
  int _failedPage = 1;
  Object? _error;
  String? _openingId;
  bool get _preview => widget.api is TeacherPreviewApi;

  @override
  void initState() {
    super.initState();
    _loadPage(1);
  }

  Future<void> _loadPage(int page) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _api.list(page);
      if (!mounted) return;
      setState(() {
        if (page == 1) _items.clear();
        final ids = _items.map((item) => item.id).toSet();
        _items.addAll(result.items.where((item) => ids.add(item.id)));
        _page = page;
        _hasMore = result.hasMore;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _failedPage = page;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _markRead(TeacherNotification notification) async {
    if (_preview ||
        notification.isRead ||
        _readIds.contains(notification.id) ||
        !_markingIds.add(notification.id)) {
      return false;
    }
    try {
      await _api.markAsRead(notification.id);
      if (mounted) setState(() => _readIds.add(notification.id));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Chưa đánh dấu đã đọc. ${teacherErrorMessage(error)}',
            ),
          ),
        );
      }
    } finally {
      _markingIds.remove(notification.id);
    }
    return false;
  }

  String? _targetId(Object? value) {
    if (value is! String || !RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
      return null;
    }
    return value;
  }

  Future<bool> _openTarget(TeacherNotification notification) async {
    final confirm = widget.confirmWorkplace;
    if (confirm == null) return false;
    switch (notification.type) {
      case 'upcoming_session':
      case 'needs_completion':
      case 'schedule_changed':
      case 'confirmation_feedback':
        final sessionId = _targetId(notification.payload['session_id']);
        final classId = _targetId(notification.payload['class_id']);
        if (sessionId == null || classId == null) return false;
        final path = '/classes/$classId';
        final classData = teacherPayload(await widget.api.get(path));
        if (!mounted || classData['id']?.toString() != classId) return false;
        final orgId = classData['organization_id']?.toString();
        final targetOrg = notification.payload['organization_id']?.toString();
        if (targetOrg != null && targetOrg != orgId) return false;
        final session = teacherPayload(
          await widget.api.get('$path/sessions/$sessionId'),
        );
        if (!mounted ||
            session['id']?.toString() != sessionId ||
            session['class_id']?.toString() != classId) {
          return false;
        }
        final label = await confirm(orgId);
        if (!mounted || label == null) return false;
        await teacherPush<bool>(
          context,
          TeacherSessionScreen(
            api: widget.api,
            sessionId: sessionId,
            classId: classId,
            workplaceLabel: label,
          ),
        );
        return true;
      case 'leave_result':
        final leaveId = _targetId(notification.payload['leave_id']);
        if (leaveId == null) return false;
        final leaveApi = widget.leaveApi ?? widget.api;
        final rows = await teacherAllPages(
          leaveApi,
          '/me/leave-requests',
          'leave_requests',
        );
        final row = rows
            .where((row) => row['id']?.toString() == leaveId)
            .firstOrNull;
        if (!mounted || row == null) return false;
        final request = TeacherLeaveRequest.fromJson(row);
        final targetOrg = notification.payload['organization_id']?.toString();
        if (targetOrg != null && targetOrg != request.organizationId) {
          return false;
        }
        final label = await confirm(request.organizationId);
        if (!mounted || label == null) return false;
        await teacherPush<bool>(
          context,
          TeacherLeaveDetailScreen(
            api: leaveApi,
            request: request,
            workplaceLabel: label,
          ),
        );
        return true;
      default:
        return false;
    }
  }

  Future<void> _open(TeacherNotification notification) async {
    if (_openingId != null) return;
    setState(() => _openingId = notification.id);
    try {
      await _markRead(notification);
      if (!mounted) return;
      String? errorMessage;
      try {
        if (await _openTarget(notification)) return;
      } catch (error) {
        errorMessage = teacherErrorMessage(error);
      }
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_title(notification)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notification.content.isNotEmpty)
                  SelectableText(notification.content),
                if (notification.createdAt case final time?)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(DateFormat('dd/MM/yyyy · HH:mm').format(time)),
                  ),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(errorMessage),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  String _title(TeacherNotification notification) =>
      notification.title.trim().isEmpty ? 'Thông báo' : notification.title;

  String _dayLabel(DateTime? time) {
    if (time == null) return 'Thông báo khác';
    final now = DateTime.now();
    if (DateUtils.isSameDay(time, now)) return 'Hôm nay';
    if (DateUtils.isSameDay(time, DateTime(now.year, now.month, now.day - 1))) {
      return 'Hôm qua';
    }
    return DateFormat('dd/MM/yyyy').format(time);
  }

  IconData _icon(String type) => switch (type) {
    'upcoming_session' || 'schedule_changed' => Icons.event_outlined,
    'needs_completion' => Icons.warning_amber_outlined,
    'leave_result' => Icons.event_busy_outlined,
    'confirmation_feedback' => Icons.fact_check_outlined,
    _ => Icons.notifications_outlined,
  };

  Widget _tile(TeacherNotification notification) {
    final unread = !notification.isRead && !_readIds.contains(notification.id);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return TeacherSwipeToAction(
      itemKey: ValueKey(notification.id),
      icon: Icons.mark_email_read_outlined,
      label: 'Đã đọc',
      color: cs.primary,
      enabled: unread && !_preview && _openingId == null,
      onAction: () => _markRead(notification),
      child: Semantics(
        label: unread ? 'Chưa đọc' : 'Đã đọc',
        child: ListTile(
          contentPadding: AppSpacing.paddingHorizontalLg,
          tileColor: unread ? cs.primaryContainer : cs.surface,
          leading: Icon(_icon(notification.type), color: cs.primary),
          title: Text(
            _title(notification),
            style: tt.titleSmall?.copyWith(
              fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (notification.content.isNotEmpty)
                Text(
                  notification.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (notification.createdAt case final time?)
                Text(DateFormat('HH:mm').format(time), style: tt.labelSmall),
            ],
          ),
          trailing: _openingId == notification.id
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.chevron_right),
          onTap: _openingId == null ? () => _open(notification) : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<TeacherNotification>>{};
    for (final notification in _items) {
      groups
          .putIfAbsent(_dayLabel(notification.createdAt), () => [])
          .add(notification);
    }
    final error = _error;
    return Scaffold(
      appBar: AppBar(title: const Text('Thông báo')),
      body: _page == 0 && _loading
          ? const Center(child: CircularProgressIndicator())
          : _page == 0 && error != null
          ? TeacherErrorView(error: error, onRetry: () => _loadPage(1))
          : RefreshIndicator(
              onRefresh: () => _loading ? Future.value() : _loadPage(1),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSpacing.paddingVerticalSm,
                children: [
                  if (_preview)
                    const ListTile(
                      leading: Icon(Icons.science_outlined),
                      title: Text('Thông báo mẫu · Chỉ xem'),
                    ),
                  if (_items.isEmpty)
                    const TeacherEmptyState(
                      icon: Icons.notifications_none_outlined,
                      title: 'Chưa có thông báo',
                      subtitle:
                          'Thông báo về lịch dạy và cập nhật sẽ hiện ở đây.',
                    ),
                  for (final group in groups.entries) ...[
                    Padding(
                      padding: AppSpacing.paddingLg,
                      child: Text(
                        group.key,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    for (final notification in group.value) _tile(notification),
                  ],
                  if (_loading)
                    const Padding(
                      padding: AppSpacing.paddingLg,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (error != null)
                    TeacherErrorView(
                      error: error,
                      onRetry: () => _loadPage(_failedPage),
                    )
                  else if (_hasMore)
                    Center(
                      child: TextButton(
                        onPressed: () => _loadPage(_page + 1),
                        child: const Text('Xem thêm thông báo'),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
