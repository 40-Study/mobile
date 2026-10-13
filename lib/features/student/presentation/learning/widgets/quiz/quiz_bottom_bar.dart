import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_event.dart';
import 'package:study/features/student/bloc/quiz/quiz_state.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

/// Bottom nav bar cho quiz (prev/next/submit)
class QuizBottomBar extends StatelessWidget {
  const QuizBottomBar({super.key, required this.state});

  final QuizReady state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
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
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!state.isFirstQuestion)
            OutlinedButton.icon(
              onPressed: () => bloc.add(const QuizPreviousQuestion()),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Câu trước'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
            )
          else
            const SizedBox(width: 90),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Text(
              '${state.currentIndex + 1}/${state.questions.length}',
              style: tt.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ),
          const Spacer(),
          if (state.isLastQuestion)
            FilledButton.icon(
              onPressed: state.currentAnswer != null
                  ? () => bloc.add(const QuizSubmitted())
                  : null,
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: const Text('Nộp bài'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
            )
          else
            FilledButton.icon(
              onPressed: state.currentAnswer != null
                  ? () => bloc.add(const QuizNextQuestion())
                  : null,
              label: const Text('Câu tiếp'),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
            ),
        ],
      ),
    );
  }
}
