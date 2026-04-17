import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/presentation/widgets/courses/courses_filter_dropdown.dart';
import 'package:study/theme/app_colors.dart';

class CoursesHeader extends StatelessWidget {
  const CoursesHeader({
    super.key,
    required this.activeCount,
    required this.completedCount,
    required this.pendingCount,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final int activeCount;
  final int completedCount;
  final int pendingCount;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final textColor = cs.onSurface;
    final textColorSecondary = cs.onSurface.withValues(alpha: 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Khoa hoc cua toi',
          style: tt.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: tt.bodyMedium?.copyWith(
                    color: textColorSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'Ban dang co '),
                    TextSpan(
                      text: '$activeCount',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                    const TextSpan(text: ' khoa dang tien hanh'),
                  ],
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            CoursesFilterDropdown(
              selectedFilter: selectedFilter,
              onFilterChanged: onFilterChanged,
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            StatChip(
              icon: Icons.play_circle_rounded,
              label: '$activeCount Dang hoc',
              color: cs.primary,
              bg: cs.surfaceTintedPrimary,
            ),
            SizedBox(width: AppSpacing.sm),
            if (pendingCount > 0) ...[
              StatChip(
                icon: Icons.schedule_rounded,
                label: '$pendingCount Doi khai giang',
                color: cs.secondary,
                bg: cs.surfaceTintedSecondary,
              ),
              SizedBox(width: AppSpacing.sm),
            ],
            StatChip(
              icon: Icons.check_circle_rounded,
              label: '$completedCount Hoan thanh',
              color: cs.tertiary,
              bg: cs.surfaceTintedTertiary,
            ),
          ],
        ),
      ],
    );
  }
}

class StatChip extends StatelessWidget {
  const StatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.borderXxl,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSize.xs, color: color),
          SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
