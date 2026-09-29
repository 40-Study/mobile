import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Skeleton loading khi đang tải dữ liệu trong Family Insights Inbox
class InsightsInboxSkeleton extends StatelessWidget {
  const InsightsInboxSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          for (var i = 0; i < 3; i++) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.borderLg,
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cs.slate100,
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppSpacing.hGap12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
                              height: 14,
                              decoration: BoxDecoration(
                                color: cs.slate100,
                                borderRadius: AppRadius.borderXs,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 160,
                              height: 11,
                              decoration: BoxDecoration(
                                color: cs.slate100,
                                borderRadius: AppRadius.borderXs,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 70,
                        height: 22,
                        decoration: BoxDecoration(
                          color: cs.slate100,
                          borderRadius: AppRadius.borderFull,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: cs.slate100,
                      borderRadius: AppRadius.borderXs,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 220,
                    height: 12,
                    decoration: BoxDecoration(
                      color: cs.slate100,
                      borderRadius: AppRadius.borderXs,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: cs.slate100,
                            borderRadius: AppRadius.borderMd,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: cs.slate100,
                            borderRadius: AppRadius.borderMd,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
