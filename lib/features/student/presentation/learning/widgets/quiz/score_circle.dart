import 'package:flutter/material.dart';

/// Score ring cho result screen
class ScoreCircle extends StatelessWidget {
  const ScoreCircle({super.key, required this.percent, required this.passed});

  final int percent;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = passed ? cs.primary : cs.error;

    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 12,
              backgroundColor: cs.outlineVariant.withValues(alpha: 0.2),
              color: cs.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          // Progress ring
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: 12,
              backgroundColor: Colors.transparent,
              color: color,
              strokeCap: StrokeCap.round,
            ),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
                style: tt.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                'Điểm số',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
