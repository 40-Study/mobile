import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/theme/app_colors.dart';

class DashboardAssignmentCard extends StatelessWidget {
  const DashboardAssignmentCard({
    super.key,
    required this.category,
    required this.title,
    required this.daysLeft,
    required this.avatarCount,
    this.onSubmit,
    this.onTap,
  });

  final String category;
  final String title;
  final int daysLeft;
  final int avatarCount;
  final VoidCallback? onSubmit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceTintedSecondary,
        borderRadius: AppRadius.borderXl,
        border: Border.all(
          color: cs.secondary.withValues(alpha: 0.12),
        ),
        boxShadow: cs.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.secondary.withValues(alpha: 0.15),
                      cs.secondaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.borderSm,
                  boxShadow: [
                    BoxShadow(
                      color: cs.secondary.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: cs.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppLayout.gutter),
              Text(
                'DO AN CUOI KY',
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title.isNotEmpty ? title : category,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.circle, color: cs.error, size: AppSpacing.sm),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Con $daysLeft ngay',
                style: tt.bodySmall?.copyWith(
                  color: cs.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              if (avatarCount > 0) ...[
                SizedBox(
                  width: 16.0 * (avatarCount.clamp(1, 3) - 1) + 28,
                  height: 28,
                  child: Stack(
                    children: List.generate(
                      avatarCount.clamp(0, 3),
                      (i) => Positioned(
                        left: i * 16.0,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: [
                            cs.primary,
                            cs.tertiary,
                            cs.error,
                          ][i % 3],
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: cs.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (avatarCount > 3)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      '+${avatarCount - 3}',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
              const Spacer(),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: cs.gradientPrimary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onSubmit,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Text(
                        'Nop bai',
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}

class MiniAssignmentCard extends StatelessWidget {
  const MiniAssignmentCard({
    super.key,
    required this.label,
    required this.title,
    required this.deadline,
    this.onTap,
  });

  final String label;
  final String title;
  final String deadline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppLayout.cardPadding,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
          boxShadow: cs.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                label,
                style: tt.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              deadline,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
