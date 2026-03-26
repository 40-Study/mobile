import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/models.dart';

class ChildCard extends StatelessWidget {
  const ChildCard({
    super.key,
    required this.child,
    this.onTap,
    this.onDetailTap,
    this.onScheduleTap,
    this.onAttendanceTap,
    this.onResultsTap,
  });

  final ChildModel child;
  final VoidCallback? onTap;
  final VoidCallback? onDetailTap;
  final VoidCallback? onScheduleTap;
  final VoidCallback? onAttendanceTap;
  final VoidCallback? onResultsTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with avatar and name
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: cs.primaryContainer,
                    backgroundImage: child.avatarUrl != null
                        ? NetworkImage(child.avatarUrl!)
                        : null,
                    child: child.avatarUrl == null
                        ? Icon(
                            Icons.person,
                            size: 28,
                            color: cs.onPrimaryContainer,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${child.displayGrade} - ${child.displaySchool}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stats row
              Row(
                children: [
                  _StatItem(
                    icon: Icons.check_circle_outline,
                    label: 'Chuyen can',
                    value: child.attendancePercentage,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 16),
                  _StatItem(
                    icon: Icons.trending_up,
                    label: 'Diem TB',
                    value: child.averageScoreDisplay,
                    color: cs.tertiary,
                  ),
                  const SizedBox(width: 16),
                  _StatItem(
                    icon: Icons.school_outlined,
                    label: 'Lop hoc',
                    value: '${child.classCount}',
                    color: cs.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Action buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ActionButton(
                      label: 'Xem chi tiet',
                      onTap: onDetailTap,
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      label: 'Lich hoc',
                      onTap: onScheduleTap,
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      label: 'Diem danh',
                      onTap: onAttendanceTap,
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      label: 'Ket qua',
                      onTap: onResultsTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(color: cs.outline.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}
