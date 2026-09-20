import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_event.dart';
import 'package:study/features/student/bloc/quiz/quiz_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/repository/student_repository.dart';
import 'package:study/di/di_container.dart';
import 'package:study/theme/theme.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({
    super.key,
    required this.quizId,
    required this.title,
    this.duration = 5,
  });

  final String quizId;
  final String title;
  final int duration;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizBloc(diContainer<StudentRepository>())
        ..add(QuizStarted(quizId)),
      child: _QuizView(quizId: quizId, title: title, duration: duration),
    );
  }
}

class _QuizView extends StatelessWidget {
  const _QuizView({
    required this.quizId,
    required this.title,
    required this.duration,
  });

  final String quizId;
  final String title;
  final int duration;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: BlocConsumer<QuizBloc, QuizState>(
          listener: (context, state) {
            if (state is QuizCompleted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => QuizResultScreen(
                    title: title,
                    correct: state.correctCount,
                    total: state.totalCount,
                    score: state.score,
                    quizId: quizId,
                    duration: state.timeLimitMinutes,
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is QuizLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is QuizFailure) {
              final isMaxAttempts = state.message.contains('hết lượt');
              return _QuizErrorView(
                title: title,
                message: state.message,
                isMaxAttempts: isMaxAttempts,
              );
            }

            if (state is QuizReady) {
              return _QuizContent(
                state: state,
                title: title,
              );
            }

            if (state is QuizSubmitting) {
              return const Center(child: CircularProgressIndicator());
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _QuizErrorView extends StatelessWidget {
  const _QuizErrorView({
    required this.title,
    required this.message,
    required this.isMaxAttempts,
  });

  final String title;
  final String message;
  final bool isMaxAttempts;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),

            const Spacer(),

            // Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: isMaxAttempts
                          ? cs.tertiary.withValues(alpha: 0.1)
                          : cs.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isMaxAttempts ? Icons.block_rounded : Icons.error_outline_rounded,
                      size: 48,
                      color: isMaxAttempts ? cs.tertiary : cs.error,
                    ),
                  ),
                  AppSpacing.vGap24,
                  Text(
                    isMaxAttempts ? 'Đã hết lượt làm bài' : 'Không thể tải bài kiểm tra',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.vGap12,
                  Text(
                    message,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  if (isMaxAttempts) ...[
                    AppSpacing.vGap16,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, size: 16, color: cs.onSurfaceVariant),
                          AppSpacing.hGap8,
                          Text(
                            'Mỗi bài kiểm tra giới hạn 5 lượt',
                            style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Spacer(),

            // Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                child: const Text('Quay lại bài học'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizContent extends StatelessWidget {
  const _QuizContent({
    required this.state,
    required this.title,
  });

  final QuizReady state;
  final String title;

  @override
  Widget build(BuildContext context) {
    final question = state.currentQuestion;

    return Column(
      children: [
        _QuizHeader(
          title: title,
          duration: state.timeLimitMinutes,
          totalQuestions: state.questions.length,
          onTimeUp: () => context.read<QuizBloc>().add(const QuizSubmitted()),
        ),
        _QuizProgress(
          questionsCount: state.questions.length,
          currentIndex: state.currentIndex,
          answers: state.answers,
          onQuestionTap: (index) => context.read<QuizBloc>().add(QuizGoToQuestion(index)),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _QuestionCard(
                  questionNumber: state.currentIndex + 1,
                  totalQuestions: state.questions.length,
                  question: question.question,
                ),
                AppSpacing.vGap24,
                ...question.options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final isSelected = state.currentAnswer == index;

                  return _AnswerOption(
                    index: index,
                    text: option,
                    isSelected: isSelected,
                    onTap: () => context.read<QuizBloc>().add(
                          QuizAnswerSelected(state.currentIndex, index),
                        ),
                  );
                }),
              ],
            ),
          ),
        ),
        _QuizBottomBar(state: state),
      ],
    );
  }
}

class _QuizHeader extends StatefulWidget {
  const _QuizHeader({
    required this.title,
    required this.duration,
    required this.totalQuestions,
    required this.onTimeUp,
  });

  final String title;
  final int duration;
  final int totalQuestions;
  final VoidCallback onTimeUp;

  @override
  State<_QuizHeader> createState() => _QuizHeaderState();
}

class _QuizHeaderState extends State<_QuizHeader> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.duration * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        widget.onTimeUp();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get _isLowTime => _remainingSeconds <= 60;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final timerColor = _isLowTime ? cs.error : cs.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _showExitDialog(context),
            icon: const Icon(Icons.close_rounded),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.title,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.totalQuestions} câu hỏi • ${widget.duration} phút',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: timerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 16, color: timerColor),
                AppSpacing.hGap4,
                Text(
                  _formattedTime,
                  style: tt.labelLarge?.copyWith(
                    color: timerColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hGap8,
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            AppSpacing.hGap8,
            Text('Thoát bài kiểm tra?'),
          ],
        ),
        content: const Text('Tiến độ làm bài của bạn sẽ không được lưu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tiếp tục làm'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
  }
}

class _QuizProgress extends StatelessWidget {
  const _QuizProgress({
    required this.questionsCount,
    required this.currentIndex,
    required this.answers,
    required this.onQuestionTap,
  });

  final int questionsCount;
  final int currentIndex;
  final Map<int, int> answers;
  final void Function(int index) onQuestionTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final answeredCount = answers.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      padding: const EdgeInsets.all(AppSpacing.md),
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
              Icon(Icons.fact_check_outlined, size: 18, color: cs.primary),
              AppSpacing.hGap8,
              Text(
                'Tiến độ: $answeredCount/$questionsCount câu',
                style: tt.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${(answeredCount / questionsCount * 100).round()}%',
                  style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vGap12,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(questionsCount, (index) {
                final isAnswered = answers.containsKey(index);
                final isCurrent = index == currentIndex;

                return Padding(
                  padding: EdgeInsets.only(right: index < questionsCount - 1 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => onQuestionTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? cs.primary
                            : isAnswered
                                ? cs.primary.withValues(alpha: 0.12)
                                : cs.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrent
                              ? cs.primary
                              : isAnswered
                                  ? cs.primary
                                  : cs.outlineVariant,
                          width: isCurrent ? 2 : 1.5,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: cs.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: isAnswered && !isCurrent
                          ? Icon(Icons.check, size: 18, color: cs.primary)
                          : Text(
                              '${index + 1}',
                              style: tt.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isCurrent
                                    ? cs.onPrimary
                                    : isAnswered
                                        ? cs.primary
                                        : cs.onSurfaceVariant,
                              ),
                            ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizBottomBar extends StatelessWidget {
  const _QuizBottomBar({required this.state});

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

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.questionNumber,
    required this.totalQuestions,
    required this.question,
  });

  final int questionNumber;
  final int totalQuestions;
  final String question;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              'Câu $questionNumber',
              style: tt.labelSmall?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.w600),
            ),
          ),
          AppSpacing.vGap12,
          Text(
            question,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.index,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final int index;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final labels = ['A', 'B', 'C', 'D', 'E', 'F'];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isSelected ? cs.primary.withValues(alpha: 0.1) : cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? cs.primary : cs.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[index % labels.length],
                  style: tt.labelLarge?.copyWith(
                    color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AppSpacing.hGap16,
              Expanded(
                child: Text(
                  text,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: cs.primary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Quiz Result Screen
// =============================================================================

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.title,
    required this.correct,
    required this.total,
    required this.score,
    this.quizId,
    this.duration,
  });

  final String title;
  final int correct;
  final int total;
  final double score;
  final String? quizId;
  final int? duration;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final percent = score.round();
    final passed = percent >= 70;
    final wrong = total - correct;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  Expanded(
                    child: Text(
                      'Kết quả bài kiểm tra',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Column(
                  children: [
                    AppSpacing.vGap16,

                    // Score circle
                    _ScoreCircle(
                      percent: percent,
                      passed: passed,
                    ),

                    AppSpacing.vGap24,

                    // Message
                    Text(
                      passed ? 'Xuất sắc!' : 'Cần cố gắng thêm!',
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: passed ? cs.primary : cs.error,
                      ),
                    ),
                    AppSpacing.vGap8,
                    Text(
                      passed
                          ? 'Bạn đã hoàn thành tốt bài kiểm tra'
                          : 'Hãy ôn tập và thử lại nhé',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),

                    AppSpacing.vGap32,

                    // Stats cards
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.check_circle_rounded,
                            iconColor: cs.primary,
                            label: 'Câu đúng',
                            value: '$correct',
                          ),
                        ),
                        AppSpacing.hGap12,
                        Expanded(
                          child: _StatCard(
                            icon: Icons.cancel_rounded,
                            iconColor: cs.error,
                            label: 'Câu sai',
                            value: '$wrong',
                          ),
                        ),
                        AppSpacing.hGap12,
                        Expanded(
                          child: _StatCard(
                            icon: Icons.quiz_rounded,
                            iconColor: cs.tertiary,
                            label: 'Tổng câu',
                            value: '$total',
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.vGap24,

                    // Progress bar
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tỷ lệ đúng',
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '$correct/$total câu',
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: passed ? cs.primary : cs.error,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.vGap12,
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: total > 0 ? correct / total : 0,
                              backgroundColor: cs.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                              color: passed ? cs.primary : cs.error,
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Passing threshold info
                    AppSpacing.vGap16,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: (passed ? cs.primary : cs.error).withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            passed
                                ? Icons.check_circle_outline_rounded
                                : Icons.info_outline_rounded,
                            size: 18,
                            color: passed ? cs.primary : cs.error,
                          ),
                          AppSpacing.hGap8,
                          Text(
                            passed
                                ? 'Đạt yêu cầu (≥70%)'
                                : 'Chưa đạt yêu cầu (cần ≥70%)',
                            style: tt.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: passed ? cs.primary : cs.error,
                            ),
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.vGap32,
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.md,
                AppSpacing.screenPadding,
                AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(
                  top: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      child: const Text('Quay lại bài học'),
                    ),
                  ),
                  if (quizId != null) ...[
                    AppSpacing.hGap12,
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => QuizScreen(
                                quizId: quizId!,
                                title: title,
                                duration: duration ?? 5,
                              ),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        label: const Text('Làm lại'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Score circle with animated ring
class _ScoreCircle extends StatelessWidget {
  const _ScoreCircle({required this.percent, required this.passed});

  final int percent;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = passed ? cs.primary : cs.error;

    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 12,
              backgroundColor: cs.outlineVariant.withValues(alpha: 0.2),
              color: cs.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          // Progress ring
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: percent / 100,
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
              Text(
                '$percent%',
                style: tt.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                'Điểm số',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Stat card widget
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          AppSpacing.vGap8,
          Text(
            value,
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          AppSpacing.vGap4,
          Text(
            label,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          value,
          style: tt.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: tt.bodySmall?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}
