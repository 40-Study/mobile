import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/models/assignment_model.dart';

class _AssignmentColors {
  static const urgent = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const normal = Color(0xFF10B981);
  static const code = Color(0xFF6366F1);
  static const quiz = Color(0xFF8B5CF6);
  static const essay = Color(0xFFEC4899);
}

class PendingAssignmentCard extends StatelessWidget {
  const PendingAssignmentCard({
    super.key,
    required this.assignment,
    this.onTap,
  });

  final AssignmentModel assignment;
  final VoidCallback? onTap;

  Color get _typeColor {
    // Check if it's a coding assignment based on available languages
    if (assignment.languages.isNotEmpty) {
      return _AssignmentColors.code;
    }
    final diff = assignment.difficulty?.toLowerCase() ?? '';
    if (diff.contains('easy') || diff.contains('de')) {
      return _AssignmentColors.normal;
    }
    if (diff.contains('hard') || diff.contains('kho')) {
      return _AssignmentColors.urgent;
    }
    return _AssignmentColors.quiz;
  }

  IconData get _typeIcon {
    // Check if it's a coding assignment based on available languages
    if (assignment.languages.isNotEmpty) {
      return Icons.code;
    }
    return Icons.assignment;
  }

  Color get _urgencyColor {
    if (assignment.dueDate == null) return _AssignmentColors.normal;
    final due = DateTime.tryParse(assignment.dueDate!);
    if (due == null) return _AssignmentColors.normal;
    final diff = due.difference(DateTime.now()).inDays;
    if (diff < 0) return _AssignmentColors.urgent;
    if (diff <= 1) return _AssignmentColors.urgent;
    if (diff <= 3) return _AssignmentColors.warning;
    return _AssignmentColors.normal;
  }

  String get _dueDisplay {
    if (assignment.dueDate == null) return '';
    final due = DateTime.tryParse(assignment.dueDate!);
    if (due == null) return '';
    final diff = due.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Qua han ${-diff} ngay';
    if (diff == 0) return 'Het han hom nay';
    if (diff == 1) return 'Het han ngay mai';
    return 'Con $diff ngay';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: _urgencyColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _urgencyColor.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _typeIcon,
                  color: _typeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (assignment.className != null) ...[
                          Icon(
                            Icons.class_,
                            size: 12,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              assignment.className!,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color: _urgencyColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _dueDisplay,
                            style: tt.bodySmall?.copyWith(
                              color: _urgencyColor,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
