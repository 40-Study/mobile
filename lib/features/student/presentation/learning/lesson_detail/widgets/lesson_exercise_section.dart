import 'package:flutter/material.dart';
import 'package:study/features/student/bloc/lesson/lesson_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/quiz_result_storage.dart';
import 'package:study/features/student/presentation/learning/widgets/exercise/exercise_widgets.dart';
import 'package:study/features/student/presentation/learning/widgets/lesson_detail/quiz_card_from_model.dart';
import 'package:study/theme/theme.dart';

/// Exercise tab hiển thị bài tập và quiz
class LessonExerciseSection extends StatelessWidget {
  const LessonExerciseSection({
    super.key,
    required this.state,
    required this.onQuizComplete,
  });

  final LessonSuccess state;
  final VoidCallback onQuizComplete;

  @override
  Widget build(BuildContext context) {
    final quizzes = state.quizzes;
    final total = quizzes.length;

    if (total == 0) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ExerciseProgressCard(completed: 0, total: 0, percent: 100),
            AppSpacing.vGap24,
            const _EmptyExercises(),
            AppSpacing.vGap32,
          ],
        ),
      );
    }

    return FutureBuilder<int>(
      future: _countCompletedQuizzes(quizzes),
      builder: (context, snapshot) {
        final completed = snapshot.data ?? 0;
        final percent = (completed / total * 100).round();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExerciseProgressCard(completed: completed, total: total, percent: percent),
              AppSpacing.vGap24,
              if (quizzes.isNotEmpty)
                ExerciseSection(
                  icon: Icons.quiz_outlined,
                  title: 'Quiz',
                  subtitle: 'Tra loi cau hoi trac nghiem',
                  children: quizzes.asMap().entries.map((entry) {
                    return QuizCardFromModel(
                      index: entry.key + 1,
                      quiz: entry.value,
                      onComplete: onQuizComplete,
                    );
                  }).toList(),
                ),
              if (quizzes.isEmpty) const _EmptyExercises(),
              AppSpacing.vGap32,
            ],
          ),
        );
      },
    );
  }

  Future<int> _countCompletedQuizzes(List<QuizModel> quizzes) async {
    var count = 0;
    for (final quiz in quizzes) {
      if (await QuizResultStorage.hasResult(quiz.id)) count++;
    }
    return count;
  }
}

class _EmptyExercises extends StatelessWidget {
  const _EmptyExercises();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
          AppSpacing.vGap16,
          Text('Chua co bai tap', style: tt.titleSmall?.copyWith(color: cs.onSurfaceVariant)),
          AppSpacing.vGap8,
          Text(
            'Bai hoc nay chua co bai tap hoac quiz',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
