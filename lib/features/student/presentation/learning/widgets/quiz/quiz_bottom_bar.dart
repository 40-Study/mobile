import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_event.dart';
import 'package:study/features/student/bloc/quiz/quiz_state.dart';
import 'package:study/theme/theme.dart';

/// Bottom nav bar cho quiz (prev/next/submit) với điều hướng tự do và xác nhận nộp bài
class QuizBottomBar extends StatelessWidget {
  const QuizBottomBar({super.key, required this.state});

  final QuizReady state;

  void _confirmSubmit(BuildContext context) {
    final unanswered = state.questions.length - state.answers.length;
    final flagged = state.flaggedQuestions.length;

    if (unanswered > 0 || flagged > 0) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.help_outline_rounded,
                  color: Color(0xFFF59E0B), size: 24),
              SizedBox(width: 8),
              Text('Xác nhận nộp bài',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            ],
          ),
          content: Text(
            unanswered > 0
                ? 'Bạn còn $unanswered câu chưa trả lời${flagged > 0 ? " và $flagged câu đang đánh dấu xem lại" : ""}.\n\nBạn có chắc chắn muốn nộp bài ngay bây giờ?'
                : 'Bạn đang có $flagged câu đánh dấu xem lại.\n\nBạn có chắc chắn muốn nộp bài ngay bây giờ?',
            style: const TextStyle(height: 1.4, fontSize: 14.5),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Làm tiếp'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<QuizBloc>().add(const QuizSubmitted());
              },
              child: const Text('Đồng ý nộp'),
            ),
          ],
        ),
      );
    } else {
      context.read<QuizBloc>().add(const QuizSubmitted());
    }
  }

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
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
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
              border:
                  Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
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
              onPressed: () => _confirmSubmit(context),
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: const Text('Nộp bài'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            )
          else
            FilledButton.icon(
              onPressed: () => bloc.add(const QuizNextQuestion()),
              label: Text(
                state.currentAnswer != null ? 'Câu tiếp' : 'Bỏ qua',
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
