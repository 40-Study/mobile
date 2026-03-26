import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/theme/app_colors.dart';

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSpacing.massive * 2,
              height: AppSpacing.massive * 2,
              decoration: BoxDecoration(
                color: cs.surfaceTintedPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppIconSize.hero,
                color: cs.onSurfaceVariant.withValues(alpha: 0.35),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              message,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
