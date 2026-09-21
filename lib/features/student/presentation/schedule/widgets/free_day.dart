import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class FreeDay extends StatelessWidget {
  const FreeDay({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Icon(
            Icons.celebration_outlined,
            color: cs.onSecondaryContainer,
            size: 24,
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Text(
              'Hôm nay free! Nghỉ ngơi hoặc học thêm nhé.',
              style: tt.bodyMedium?.copyWith(
                color: cs.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
