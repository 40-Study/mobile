import 'package:flutter/material.dart';
import 'package:study/features/student/presentation/learning/quiz_screen.dart';
import 'package:study/theme/theme.dart';

// =============================================================================
// Exercise Tab Components
// =============================================================================

class ExerciseProgressCard extends StatelessWidget {
  const ExerciseProgressCard({
    super.key,
    required this.completed,
    required this.total,
    required this.percent,
  });

  final int completed;
  final int total;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.emoji_events_outlined, color: cs.primary, size: 28),
          ),
          AppSpacing.hGap16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoàn thành bài tập để nắm vững kiến thức',
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                AppSpacing.vGap4,
                Text(
                  'Bạn cần đạt ít nhất 70% để hoàn thành bài học',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          AppSpacing.hGap12,
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percent / 100,
                  strokeWidth: 5,
                  backgroundColor: cs.surfaceContainerHighest,
                  color: cs.primary,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percent%',
                      style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary),
                    ),
                    Text(
                      '$completed/$total bài',
                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseSection extends StatelessWidget {
  const ExerciseSection({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
    this.titleSuffix,
    this.infoText,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? titleSuffix;
  final String? infoText;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: cs.onSurface),
            AppSpacing.hGap8,
            Text(title, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            if (titleSuffix != null) ...[
              AppSpacing.hGap4,
              Text(titleSuffix!, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ],
        ),
        AppSpacing.vGap4,
        Text(subtitle, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        AppSpacing.vGap12,
        ...children,
        if (infoText != null) ...[
          AppSpacing.vGap12,
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: cs.onSurfaceVariant),
                AppSpacing.hGap8,
                Expanded(
                  child: Text(
                    infoText!,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge({super.key, required this.text, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final badgeColor = color ?? cs.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        text,
        style: tt.labelSmall?.copyWith(color: badgeColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class CodeExerciseCard extends StatelessWidget {
  const CodeExerciseCard({
    super.key,
    required this.index,
    required this.title,
    required this.difficulty,
    required this.description,
    required this.duration,
    required this.points,
    required this.completionRate,
  });

  final int index;
  final String title;
  final String difficulty;
  final String description;
  final int duration;
  final int points;
  final int completionRate;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.code_rounded, color: cs.primary, size: 24),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$index. $title',
                          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        AppSpacing.hGap8,
                        DifficultyBadge(text: difficulty),
                      ],
                    ),
                    AppSpacing.vGap4,
                    Text(
                      description,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    AppSpacing.vGap8,
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: cs.onSurfaceVariant),
                        AppSpacing.hGap4,
                        Text('$duration phút', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                        AppSpacing.hGap12,
                        Icon(Icons.bar_chart_rounded, size: 14, color: cs.onSurfaceVariant),
                        AppSpacing.hGap4,
                        Text('$points điểm', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                        AppSpacing.hGap12,
                        Icon(Icons.check_circle_outline_rounded, size: 14, color: cs.onSurfaceVariant),
                        AppSpacing.hGap4,
                        Text('$completionRate% hoàn thành', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vGap12,
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Làm bài trên web'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuizCard extends StatelessWidget {
  const QuizCard({
    super.key,
    required this.index,
    required this.title,
    required this.difficulty,
    required this.questions,
    required this.duration,
    required this.points,
    this.difficultyColor,
  });

  final int index;
  final String title;
  final String difficulty;
  final Color? difficultyColor;
  final int questions;
  final int duration;
  final int points;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.help_outline_rounded, color: cs.primary, size: 20),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '$index. $title',
                        style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSpacing.hGap8,
                    DifficultyBadge(text: difficulty, color: difficultyColor),
                  ],
                ),
                AppSpacing.vGap4,
                Text(
                  '$questions câu hỏi • $duration phút • $points điểm',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          AppSpacing.hGap8,
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuizScreen(
                    quizId: 'quiz-$index',
                    title: title,
                    totalQuestions: questions,
                    duration: duration,
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
            child: const Text('Làm bài'),
          ),
        ],
      ),
    );
  }
}

class EssayCard extends StatelessWidget {
  const EssayCard({
    super.key,
    required this.index,
    required this.title,
    required this.difficulty,
    required this.description,
    required this.points,
  });

  final int index;
  final String title;
  final String difficulty;
  final String description;
  final int points;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.assignment_outlined, color: cs.primary, size: 20),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '$index. $title',
                        style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSpacing.hGap8,
                    DifficultyBadge(text: difficulty),
                  ],
                ),
                AppSpacing.vGap4,
                Text(
                  description,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vGap4,
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: cs.onSurfaceVariant),
                    AppSpacing.hGap4,
                    Text('Không giới hạn', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                    AppSpacing.hGap12,
                    Icon(Icons.bar_chart_rounded, size: 14, color: cs.onSurfaceVariant),
                    AppSpacing.hGap4,
                    Text('$points điểm', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.hGap8,
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );
  }
}

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    super.key,
    required this.index,
    required this.title,
    required this.difficulty,
    required this.description,
    required this.duration,
    required this.points,
    this.difficultyColor,
  });

  final int index;
  final String title;
  final String difficulty;
  final Color? difficultyColor;
  final String description;
  final int duration;
  final int points;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.emoji_events_rounded, color: Colors.amber.shade700, size: 20),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '$index. $title',
                        style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSpacing.hGap8,
                    DifficultyBadge(text: difficulty, color: difficultyColor),
                  ],
                ),
                AppSpacing.vGap4,
                Text(
                  description,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vGap4,
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: cs.onSurfaceVariant),
                    AppSpacing.hGap4,
                    Text('$duration phút', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                    AppSpacing.hGap12,
                    Icon(Icons.bar_chart_rounded, size: 14, color: cs.onSurfaceVariant),
                    AppSpacing.hGap4,
                    Text('$points điểm', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.hGap8,
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
            child: const Text('Làm bài'),
          ),
        ],
      ),
    );
  }
}
