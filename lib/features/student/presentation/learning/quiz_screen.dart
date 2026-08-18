import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.quizId,
    required this.title,
    this.totalQuestions = 5,
    this.duration = 5,
  });

  final String quizId;
  final String title;
  final int totalQuestions;
  final int duration;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  final Map<int, int> _answers = {};

  // Mock questions
  final List<_QuizQuestion> _questions = [
    const _QuizQuestion(
      question: 'Python là ngôn ngữ lập trình thuộc loại nào?',
      options: [
        'Ngôn ngữ biên dịch (Compiled)',
        'Ngôn ngữ thông dịch (Interpreted)',
        'Ngôn ngữ máy (Machine)',
        'Ngôn ngữ assembly',
      ],
      correctAnswer: 1,
    ),
    const _QuizQuestion(
      question: 'Cú pháp nào đúng để khai báo biến trong Python?',
      options: [
        'var x = 5',
        'int x = 5',
        'x = 5',
        'let x = 5',
      ],
      correctAnswer: 2,
    ),
    const _QuizQuestion(
      question: 'Hàm print() trong Python dùng để làm gì?',
      options: [
        'Nhập dữ liệu từ bàn phím',
        'In dữ liệu ra màn hình',
        'Đọc file',
        'Ghi file',
      ],
      correctAnswer: 1,
    ),
    const _QuizQuestion(
      question: 'Kiểu dữ liệu nào sau đây KHÔNG có trong Python?',
      options: [
        'int',
        'float',
        'char',
        'str',
      ],
      correctAnswer: 2,
    ),
    const _QuizQuestion(
      question: 'Comment trong Python bắt đầu bằng ký tự gì?',
      options: [
        '//',
        '/*',
        '#',
        '--',
      ],
      correctAnswer: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final question = _questions[_currentQuestion];

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Progress
            _buildProgress(context),

            // Question content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question card
                    _QuestionCard(
                      questionNumber: _currentQuestion + 1,
                      totalQuestions: _questions.length,
                      question: question.question,
                    ),
                    AppSpacing.vGap24,

                    // Answer options
                    ...question.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isSelected = _selectedAnswer == index;

                      return _AnswerOption(
                        index: index,
                        text: option,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedAnswer = index),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom navigation
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 16, color: cs.primary),
                AppSpacing.hGap4,
                Text(
                  '04:32',
                  style: tt.labelLarge?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          AppSpacing.hGap8,
        ],
      ),
    );
  }

  Widget _buildProgress(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: List.generate(_questions.length, (index) {
          final isAnswered = _answers.containsKey(index);
          final isCurrent = index == _currentQuestion;

          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < _questions.length - 1 ? 4 : 0),
              decoration: BoxDecoration(
                color: isAnswered
                    ? cs.primary
                    : isCurrent
                        ? cs.primary.withValues(alpha: 0.5)
                        : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isFirst = _currentQuestion == 0;
    final isLast = _currentQuestion == _questions.length - 1;

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
          // Prev button
          if (!isFirst)
            OutlinedButton.icon(
              onPressed: _goToPrevious,
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

          // Question indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Text(
              '${_currentQuestion + 1}/${_questions.length}',
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),

          const Spacer(),

          // Next/Submit button
          if (isLast)
            FilledButton.icon(
              onPressed: _selectedAnswer != null ? _submitQuiz : null,
              icon: const Icon(Icons.check_rounded, size: 20),
              label: const Text('Nộp bài'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              ),
            )
          else
            FilledButton.icon(
              onPressed: _selectedAnswer != null ? _goToNext : null,
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

  void _goToPrevious() {
    if (_currentQuestion > 0) {
      setState(() {
        _currentQuestion--;
        _selectedAnswer = _answers[_currentQuestion];
      });
    }
  }

  void _goToNext() {
    if (_selectedAnswer != null) {
      _answers[_currentQuestion] = _selectedAnswer!;
    }
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = _answers[_currentQuestion];
      });
    }
  }

  void _submitQuiz() {
    if (_selectedAnswer != null) {
      _answers[_currentQuestion] = _selectedAnswer!;
    }

    // Calculate score
    var correct = 0;
    for (var i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i].correctAnswer) {
        correct++;
      }
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          title: widget.title,
          correct: correct,
          total: _questions.length,
          answers: _answers,
          questions: _questions,
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tiếp tục làm'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
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

// =============================================================================
// Quiz Result Screen
// =============================================================================

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.title,
    required this.correct,
    required this.total,
    required this.answers,
    required this.questions,
  });

  final String title;
  final int correct;
  final int total;
  final Map<int, int> answers;
  final List<_QuizQuestion> questions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final percent = (correct / total * 100).round();
    final passed = percent >= 70;

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
                      'Kết quả',
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  children: [
                    // Result card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: passed
                              ? [cs.primary, cs.primary.withValues(alpha: 0.8)]
                              : [cs.error, cs.error.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            passed ? Icons.emoji_events_rounded : Icons.refresh_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                          AppSpacing.vGap16,
                          Text(
                            passed ? 'Xuất sắc!' : 'Cố gắng hơn nhé!',
                            style: tt.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          AppSpacing.vGap8,
                          Text(
                            'Bạn đã trả lời đúng $correct/$total câu hỏi',
                            style: tt.bodyMedium?.copyWith(color: Colors.white70),
                          ),
                          AppSpacing.vGap24,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _ResultStat(label: 'Điểm số', value: '$percent%'),
                              Container(
                                width: 1,
                                height: 40,
                                margin: const EdgeInsets.symmetric(horizontal: 24),
                                color: Colors.white24,
                              ),
                              const _ResultStat(label: 'Thời gian', value: '03:28'),
                              Container(
                                width: 1,
                                height: 40,
                                margin: const EdgeInsets.symmetric(horizontal: 24),
                                color: Colors.white24,
                              ),
                              _ResultStat(label: 'Đúng', value: '$correct câu'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.vGap24,

                    // Review section
                    Row(
                      children: [
                        Icon(Icons.assignment_outlined, size: 20, color: cs.onSurface),
                        AppSpacing.hGap8,
                        Text(
                          'Xem lại đáp án',
                          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    AppSpacing.vGap12,

                    // Questions review
                    ...questions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final q = entry.value;
                      final userAnswer = answers[index];
                      final isCorrect = userAnswer == q.correctAnswer;

                      return _QuestionReviewCard(
                        questionNumber: index + 1,
                        question: q.question,
                        options: q.options,
                        correctAnswer: q.correctAnswer,
                        userAnswer: userAnswer,
                        isCorrect: isCorrect,
                      );
                    }),

                    AppSpacing.vGap24,
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
                border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                      ),
                      child: const Text('Quay lại bài học'),
                    ),
                  ),
                  AppSpacing.hGap12,
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => QuizScreen(
                              quizId: 'retry',
                              title: title,
                            ),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                      ),
                      child: const Text('Làm lại'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Components
// =============================================================================

class _QuizQuestion {
  const _QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  final String question;
  final List<String> options;
  final int correctAnswer;
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
    final labels = ['A', 'B', 'C', 'D'];

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
                  labels[index],
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
          style: tt.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: tt.bodySmall?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

class _QuestionReviewCard extends StatelessWidget {
  const _QuestionReviewCard({
    required this.questionNumber,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.userAnswer,
    required this.isCorrect,
  });

  final int questionNumber;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final int? userAnswer;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final labels = ['A', 'B', 'C', 'D'];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isCorrect
              ? Colors.green.withValues(alpha: 0.5)
              : cs.error.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green : cs.error,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCorrect ? Icons.check_rounded : Icons.close_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    AppSpacing.hGap4,
                    Text(
                      'Câu $questionNumber',
                      style: tt.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                isCorrect ? 'Đúng' : 'Sai',
                style: tt.labelMedium?.copyWith(
                  color: isCorrect ? Colors.green : cs.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          AppSpacing.vGap12,
          Text(
            question,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          AppSpacing.vGap12,

          // Options
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isCorrectAnswer = index == correctAnswer;
            final isUserAnswer = index == userAnswer;

            Color? bgColor;
            Color? borderColor;
            if (isCorrectAnswer) {
              bgColor = Colors.green.withValues(alpha: 0.1);
              borderColor = Colors.green;
            } else if (isUserAnswer && !isCorrect) {
              bgColor = cs.error.withValues(alpha: 0.1);
              borderColor = cs.error;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor ?? cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: borderColor != null ? Border.all(color: borderColor) : null,
              ),
              child: Row(
                children: [
                  Text(
                    '${labels[index]}.',
                    style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  AppSpacing.hGap8,
                  Expanded(
                    child: Text(option, style: tt.bodySmall),
                  ),
                  if (isCorrectAnswer)
                    const Icon(Icons.check_circle_rounded, size: 18, color: Colors.green)
                  else if (isUserAnswer && !isCorrect)
                    Icon(Icons.cancel_rounded, size: 18, color: cs.error),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
