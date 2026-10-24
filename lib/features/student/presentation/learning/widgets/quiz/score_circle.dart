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
    final color = passed ? const Color(0xFF059669) : const Color(0xFFDC2626);

    return SizedBox(
      width: 164,
      height: 164,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft circle
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.05),
            ),
          ),
          // Background ring
          SizedBox(
            width: 164,
            height: 164,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 12,
              backgroundColor: cs.outlineVariant.withValues(alpha: 0.2),
              color: cs.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          // Progress ring
          SizedBox(
            width: 164,
            height: 164,
            child: CircularProgressIndicator(
              value: percent.clamp(0, 100) / 100,
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
              Icon(
                passed ? Icons.emoji_events_rounded : Icons.replay_rounded,
                size: 24,
                color: color,
              ),
              const SizedBox(height: 2),
              Text(
                '$percent%',
                style: tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Điểm số',
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
