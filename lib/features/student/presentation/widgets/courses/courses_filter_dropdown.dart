import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/theme/app_colors.dart';

class CoursesFilterDropdown extends StatelessWidget {
  const CoursesFilterDropdown({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  String get _label {
    switch (selectedFilter) {
      case 'active':
        return 'Dang hoc';
      case 'completed':
        return 'Hoan thanh';
      case 'pending':
        return 'Doi khai giang';
      default:
        return 'LOC';
    }
  }

  IconData get _icon {
    switch (selectedFilter) {
      case 'active':
        return Icons.play_circle_outline_rounded;
      case 'completed':
        return Icons.check_circle_outline_rounded;
      case 'pending':
        return Icons.schedule_rounded;
      default:
        return Icons.filter_list_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return PopupMenuButton<String>(
      onSelected: onFilterChanged,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      color: cs.surfaceContainerLowest,
      elevation: 3,
      itemBuilder: (_) => [
        _filterItem(context, 'all', 'Tat ca',
            Icons.apps_rounded),
        _filterItem(context, 'active', 'Dang hoc',
            Icons.play_circle_outline_rounded),
        _filterItem(context, 'pending', 'Doi khai giang',
            Icons.schedule_rounded),
        _filterItem(context, 'completed', 'Da hoan thanh',
            Icons.check_circle_outline_rounded),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceTintedPrimary,
          borderRadius: AppRadius.borderXxl,
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.12),
          ),
          boxShadow: cs.shadowCard,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: AppIconSize.xs, color: cs.primary),
            SizedBox(width: AppSpacing.xs),
            Text(
              _label,
              style: tt.labelMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: AppSpacing.xxs),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: AppIconSize.sm,
              color: cs.primary,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _filterItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = selectedFilter == value;

    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: AppIconSize.md,
            color: isSelected ? cs.primary : cs.onSurfaceVariant,
          ),
          SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? cs.primary : cs.onSurface,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            Icon(
              Icons.check_rounded,
              size: AppIconSize.sm,
              color: cs.primary,
            ),
          ],
        ],
      ),
    );
  }
}
