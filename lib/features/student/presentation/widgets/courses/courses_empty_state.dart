import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/theme/app_colors.dart';

class CoursesEmptyState extends StatelessWidget {
  const CoursesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: cs.surfaceTintedPrimary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: AppIconSize.hero,
              color: cs.primary.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Text(
            'Chua co khoa hoc nao',
            style: tt.titleMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Bat dau kham pha va dang ky khoa hoc ngay!',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: AppSpacing.xxl),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.explore_rounded),
            label: const Text('Kham pha khoa hoc'),
          ),
        ],
      ),
    );
  }
}
