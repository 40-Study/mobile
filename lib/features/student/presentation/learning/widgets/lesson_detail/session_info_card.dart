import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Card hiển thị thông tin session/buổi học và progress
class SessionInfoCard extends StatelessWidget {
  const SessionInfoCard({
    super.key,
    required this.sessionNumber,
    required this.lessonInSection,
    required this.sessionTitle,
    required this.progress,
    required this.currentTime,
    required this.totalTime,
  });

  final int sessionNumber;
  final int lessonInSection;
  final String sessionTitle;
  final double progress;
  final String currentTime;
  final String totalTime;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Buổi $sessionNumber',
                style: tt.labelLarge?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text('Tiến độ bài học', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              AppSpacing.hGap4,
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: tt.titleMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          AppSpacing.vGap4,
          Row(
            children: [
              Expanded(
                child: Text(
                  sessionTitle,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$currentTime / $totalTime',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          AppSpacing.vGap12,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHighest,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}
