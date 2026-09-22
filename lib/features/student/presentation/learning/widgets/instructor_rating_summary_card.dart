import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

import 'instructor_rating_bar.dart';

class InstructorRatingSummaryCard extends StatelessWidget {
  const InstructorRatingSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          // Left: big rating
          Column(
            children: [
              Text(
                '4.9',
                style: tt.displaySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                ),
              ),
              AppSpacing.vGap4,
              Text(
                '(128 đánh giá)',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          AppSpacing.hGap24,

          // Right: breakdown bars
          const Expanded(
            child: Column(
              children: [
                InstructorRatingBar(stars: 5, count: 110, total: 128),
                InstructorRatingBar(stars: 4, count: 14, total: 128),
                InstructorRatingBar(stars: 3, count: 3, total: 128),
                InstructorRatingBar(stars: 2, count: 1, total: 128),
                InstructorRatingBar(stars: 1, count: 0, total: 128),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
