import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_event.dart';
import 'package:study/features/student/bloc/quiz/quiz_state.dart';
import 'package:study/theme/theme.dart';

/// Bottom nav bar cho quiz (prev/next/submit)
class QuizBottomBar extends StatelessWidget {
  const QuizBottomBar({super.key, required this.state});

  final QuizReady state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bloc = context.read<QuizBloc>();

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          if (!state.isFirstQuestion)
            OutlinedButton.icon(
              onPressed: () => bloc.add(const QuizPreviousQuestion()),
              icon: const Icon(Icons.chevron_left_rounded, size: 20),
              label: const Text('Trước'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              ),
            )
          else
            const SizedBox(width: 100),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Text(
              '${state.currentIndex + 1}/${state.questions.length}',
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
          if (state.isLastQuestion)
            FilledButton.icon(
              onPressed: state.currentAnswer != null
                  ? () => bloc.add(const QuizSubmitted())
                  : null,
              icon: const Icon(Icons.check_rounded, size: 20),
              label: const Text('Nộp bài'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              ),
            )
          else
            FilledButton.icon(
              onPressed: state.currentAnswer != null
                  ? () => bloc.add(const QuizNextQuestion())
                  : null,
              label: const Text('Tiếp'),
              icon: const Icon(Icons.chevron_right_rounded, size: 20),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              ),
            ),
        ],
      ),
    );
  }
}
