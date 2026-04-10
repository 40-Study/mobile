import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/app_colors.dart';

class AssignmentDetailScreen extends StatelessWidget {
  const AssignmentDetailScreen({
    super.key,
    required this.assignment,
  });

  final ChildAssignmentModel assignment;

  Color _statusColor(ColorScheme cs) {
    switch (assignment.status) {
      case AssignmentStatus.completed:
        return Colors.green;
      case AssignmentStatus.missing:
        return Colors.red;
      case AssignmentStatus.late:
        return Colors.orange;
      case AssignmentStatus.pending:
        return cs.primary;
    }
  }

  String get _statusText {
    switch (assignment.status) {
      case AssignmentStatus.completed:
        return 'Hoàn thành';
      case AssignmentStatus.missing:
        return 'Thiếu';
      case AssignmentStatus.late:
        return 'Nộp muộn';
      case AssignmentStatus.pending:
        return 'Đang chờ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = _statusColor(cs);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Chi tiết bài tập'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppLayout.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      assignment.status == AssignmentStatus.completed
                          ? Icons.check_circle
                          : assignment.status == AssignmentStatus.missing
                              ? Icons.cancel
                              : Icons.access_time,
                      color: statusColor,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (assignment.score != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${assignment.score}/${assignment.maxScore ?? 10}',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Assignment Info
            Text(
              'Thông tin bài tập',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.assignment,
                    label: 'Tên bài tập',
                    value: assignment.title,
                  ),
                  const Divider(height: AppSpacing.xl),
                  if (assignment.className != null)
                    _InfoRow(
                      icon: Icons.class_,
                      label: 'Lớp',
                      value: assignment.className!,
                    ),
                  if (assignment.className != null)
                    const Divider(height: AppSpacing.xl),
                  _InfoRow(
                    icon: Icons.category,
                    label: 'Loại',
                    value: assignment.type.name == 'assignment'
                        ? 'Bài tập'
                        : assignment.type.name == 'project'
                            ? 'Dự án'
                            : 'Bài kiểm tra',
                  ),
                  if (assignment.dueDate != null) ...[
                    const Divider(height: AppSpacing.xl),
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: 'Hạn nộp',
                      value: assignment.dueDate!,
                    ),
                  ],
                  if (assignment.submittedAt != null) ...[
                    const Divider(height: AppSpacing.xl),
                    _InfoRow(
                      icon: Icons.check_circle_outline,
                      label: 'Ngày nộp',
                      value: assignment.submittedAt!,
                    ),
                  ],
                ],
              ),
            ),

            // Teacher Feedback
            if (assignment.teacherFeedback != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Nhận xét của giáo viên',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: cs.primary,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        assignment.teacherFeedback!,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: cs.primary, size: 20),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: cs.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
