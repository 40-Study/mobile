import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class EmptyGoals extends StatelessWidget {
  const EmptyGoals({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: cs.outline),
          AppSpacing.hGap12,
          Expanded(
            child: Text(
              'Chưa có mục tiêu. Thêm ngay!',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: onAdd,
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}
