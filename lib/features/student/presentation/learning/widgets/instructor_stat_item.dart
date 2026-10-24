import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class InstructorStatItem extends StatelessWidget {
  const InstructorStatItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: cs.primary, size: 20),
          ),
          AppSpacing.vGap4,
          Text(
            value,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
