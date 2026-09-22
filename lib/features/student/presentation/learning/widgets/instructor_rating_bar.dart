import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class InstructorRatingBar extends StatelessWidget {
  const InstructorRatingBar({
    super.key,
    required this.stars,
    required this.count,
    required this.total,
  });
  final int stars;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ratio = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: Text(
              '$stars',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
          AppSpacing.hGap8,
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
            ),
          ),
          AppSpacing.hGap8,
          SizedBox(
            width: 28,
            child: Text(
              '$count',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
