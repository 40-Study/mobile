import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/leave/teacher_leave_list_screen.dart';
import 'package:study/theme/theme.dart';

class TeacherLeaveDetailScreen extends StatefulWidget {
  const TeacherLeaveDetailScreen({
    super.key,
    required this.api,
    required this.request,
  });
  final TeacherApi api;
  final TeacherLeaveRequest request;

  @override
  State<TeacherLeaveDetailScreen> createState() =>
      _TeacherLeaveDetailScreenState();
}

class _TeacherLeaveDetailScreenState extends State<TeacherLeaveDetailScreen> {
  bool _withdrawing = false;

  Future<void> _withdraw() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rút đơn xin nghỉ?'),
        content: const Text('Đơn sẽ bị hủy và bạn sẽ phải tạo đơn mới nếu cần.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rút đơn'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _withdrawing = true);
    try {
      await widget.api.post('/me/leave-requests/${widget.request.id}/withdraw');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã rút đơn xin nghỉ')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _withdrawing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(teacherErrorMessage(e))),
        );
      }
    }
  }

  Color _statusColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (widget.request.status) {
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
    switch (widget.request.status) {
      case 'pending':
        return 'Chờ duyệt';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Từ chối';
      case 'withdrawn':
        return 'Đã rút';
      default:
        return widget.request.status;
    }
  }

  IconData get _statusIcon {
    switch (widget.request.status) {
      case 'pending':
        return Icons.hourglass_empty_outlined;
      case 'approved':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'withdrawn':
        return Icons.undo_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final request = widget.request;

    final dateRange = request.fromDate == request.toDate
        ? dateFormat.format(request.fromDate)
        : '${dateFormat.format(request.fromDate)} - ${dateFormat.format(request.toDate)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết đơn xin nghỉ')),
      body: ListView(
        padding: AppSpacing.paddingScreenAll,
        children: [
          // Status card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _statusColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _statusColor(context).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(_statusIcon, color: _statusColor(context), size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusLabel,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: _statusColor(context),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        'Tạo ngày ${DateFormat('dd/MM/yyyy HH:mm').format(request.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Date range
          _DetailSection(
            icon: Icons.calendar_today_outlined,
            title: 'Ngày xin nghỉ',
            content: dateRange,
          ),

          const SizedBox(height: 16),

          // Reason
          _DetailSection(
            icon: Icons.notes_outlined,
            title: 'Lý do',
            content: request.reason,
          ),

          // Feedback (if any)
          if (request.feedback != null && request.feedback!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DetailSection(
              icon: Icons.feedback_outlined,
              title: 'Phản hồi từ trung tâm',
              content: request.feedback!,
              highlight: true,
            ),
          ],

          const SizedBox(height: 24),

          // Affected sessions
          Text(
            'Buổi học bị ảnh hưởng',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          if (request.affectedSessions.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Không có buổi học nào bị ảnh hưởng',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            )
          else
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < request.affectedSessions.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.school_outlined),
                      title: Text(request.affectedSessions[i].className),
                      subtitle: Text(
                        '${request.affectedSessions[i].date} · ${request.affectedSessions[i].time}',
                      ),
                    ),
                  ],
                ],
              ),
            ),

          const SizedBox(height: 32),

          // Withdraw button (only for pending)
          if (request.status == 'pending')
            OutlinedButton.icon(
              onPressed: _withdrawing ? null : _withdraw,
              icon: _withdrawing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.undo_outlined),
              label: const Text('Rút đơn'),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.error,
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.title,
    required this.content,
    this.highlight = false,
  });
  final IconData icon;
  final String title;
  final String content;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight
            ? cs.primaryContainer.withValues(alpha: 0.3)
            : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: highlight ? cs.primary : cs.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
