import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_event.dart';
import 'package:study/features/student/bloc/quiz/quiz_state.dart';
import 'package:study/theme/theme.dart';

/// Bottom Nav Dock cho quiz (Câu trước / Palette Trigger / Câu tiếp / Nộp bài)
/// Cân xứng, thanh thoát, màu sắc học thuật chuẩn mực
class QuizBottomBar extends StatelessWidget {
  const QuizBottomBar({
    super.key,
    required this.state,
    this.onOpenPalette,
  });

  final QuizReady state;
  final VoidCallback? onOpenPalette;

  void _confirmSubmit(BuildContext context) {
    final unanswered = state.questions.length - state.answers.length;
    final flagged = state.flaggedQuestions.length;

    if (unanswered > 0 || flagged > 0) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.help_outline_rounded,
                  color: Color(0xFFD97706), size: 22),
              SizedBox(width: 8),
              Text('Xác nhận nộp bài',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            ],
          ),
          content: Text(
            unanswered > 0
                ? 'Bạn còn $unanswered câu chưa trả lời${flagged > 0 ? " và $flagged câu đang đánh dấu xem lại" : ""}.\n\nBạn có chắc chắn muốn nộp bài thi ngay bây giờ?'
                : 'Bạn đang có $flagged câu đánh dấu xem lại.\n\nBạn có chắc chắn muốn nộp bài thi ngay bây giờ?',
            style: const TextStyle(height: 1.45, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Làm tiếp'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<QuizBloc>().add(const QuizSubmitted());
              },
              child: const Text('Nộp bài ngay'),
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(
            color: cs.slate200.withValues(alpha: 0.8),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          // Nút Câu trước
          if (!state.isFirstQuestion)
            OutlinedButton.icon(
              onPressed: () => bloc.add(const QuizPreviousQuestion()),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Trước'),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.slate700,
                side: BorderSide(color: cs.slate300, width: 0.8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            )
          else
            const SizedBox(width: 80),

          const Spacer(),

          // Nút giữa: [ ☷ 03/10 ] Trigger Palette
          InkWell(
            onTap: onOpenPalette,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: cs.slate100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: cs.slate200.withValues(alpha: 0.8),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.grid_view_rounded, size: 13, color: cs.slate500),
                  const SizedBox(width: 5),
                  Text(
                    '${state.currentIndex + 1}/${state.questions.length}',
                    style: tt.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.slate800,
                      fontSize: 12,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Nút Câu tiếp hoặc Nộp bài
          if (state.isLastQuestion)
            FilledButton.icon(
              onPressed: () => _confirmSubmit(context),
              icon: const Icon(Icons.check_circle_rounded, size: 16),
              label: const Text('Nộp bài'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB), // Academic Royal Blue
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                textStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            )
          else
            FilledButton.icon(
              onPressed: () => bloc.add(const QuizNextQuestion()),
              label: Text(
                state.currentAnswer != null ? 'Tiếp tục' : 'Bỏ qua',
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              style: FilledButton.styleFrom(
                backgroundColor: state.currentAnswer != null
                    ? const Color(0xFF2563EB)
                    : cs.slate100,
                foregroundColor: state.currentAnswer != null
                    ? Colors.white
                    : cs.slate700,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                textStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}
