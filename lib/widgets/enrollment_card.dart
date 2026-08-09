import 'package:flutter/material.dart';

class EnrollmentCard extends StatelessWidget {
  const EnrollmentCard({
    super.key,
    required this.courseName,
    required this.progress,
    this.courseDescription,
    this.instructorName,
    this.lastLearned,
    this.onTap,
    this.onContinueTap,
    this.compact = false,
  });

  final String courseName;
  final double progress;
  final String? courseDescription;
  final String? instructorName;
  final String? lastLearned;
  final VoidCallback? onTap;
  final VoidCallback? onContinueTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final progressValue = (progress / 100).clamp(0.0, 1.0);
    final isCompleted = progress >= 100;

    if (compact) {
      return SizedBox(
        width: 180,
        child: Card(
          elevation: 0,
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: onTap ?? onContinueTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 32,
                        color: cs.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    courseName,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: cs.surfaceContainerHighest,
                      color: cs.primary,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: tt.labelSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 36,
                    color: cs.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courseName,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (instructorName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        instructorName!,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                    if (courseDescription != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        courseDescription!,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progressValue,
                              backgroundColor: cs.surfaceContainerHighest,
                              color: cs.primary,
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${progress.toStringAsFixed(0)}%',
                          style: tt.labelMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Hoc lan cuoi: ${lastLearned ?? "Chua bat dau"}',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const Spacer(),
                        if (isCompleted)
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Hoan thanh',
                                style: tt.labelSmall?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: onContinueTap,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: const Text('Tiep tuc'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
