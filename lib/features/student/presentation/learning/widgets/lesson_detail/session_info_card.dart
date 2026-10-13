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
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'Buổi $sessionNumber',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Tiến độ bài học',
                style: tt.labelSmall?.copyWith(color: cs.slate500),
              ),
              const SizedBox(width: 6),
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: tt.titleSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          AppSpacing.vGap8,
          Row(
            children: [
              Expanded(
                child: Text(
                  sessionTitle,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.slate900,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$currentTime / $totalTime',
                style: tt.bodySmall?.copyWith(color: cs.slate500),
              ),
            ],
          ),
          AppSpacing.vGap12,
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 6,
              backgroundColor: cs.outlineVariant.withValues(alpha: 0.25),
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
          ),
        ],
      ),
    );
  }
}
