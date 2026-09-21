import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class ChildrenLoading extends StatelessWidget {
  const ChildrenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 3,
      separatorBuilder: (_, __) => AppSpacing.vGap12,
      itemBuilder: (_, __) => const ChildCardSkeleton(),
    );
  }
}

class ChildCardSkeleton extends StatelessWidget {
  const ChildCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: AppRadius.borderLg,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
          ),
          AppSpacing.hGap16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: AppRadius.borderSm,
                  ),
                ),
                AppSpacing.vGap8,
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: AppRadius.borderSm,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
