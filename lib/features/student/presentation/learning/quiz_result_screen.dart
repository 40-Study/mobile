import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/repository/student_repository.dart';
import 'package:study/theme/theme.dart';

import 'quiz_screen.dart';
import 'widgets/quiz/question_review_card.dart';
import 'widgets/quiz/score_circle.dart';
import 'widgets/quiz/stat_card.dart';

enum QuizReviewFilter { total, correct, wrong }

/// Result screen sau khi hoàn thành quiz với bộ lọc tương tác câu đúng/sai
class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({
    super.key,
    required this.title,
    required this.correct,
    required this.total,
    required this.score,
    this.quizId,
    this.attemptId,
    this.duration,
    this.questions = const [],
    this.userAnswers = const {},
    this.reviewItems = const [],
  });

  final String title;
  final int correct;
  final int total;
  final double score;
  final String? quizId;
  final String? attemptId;
  final int? duration;
  final List<QuizQuestionModel> questions;
  final Map<int, dynamic> userAnswers;
  final List<QuizReviewItemModel> reviewItems;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with SingleTickerProviderStateMixin {
  QuizReviewFilter _selectedFilter = QuizReviewFilter.total;
  late final AnimationController _celebrationController;

  late int _correct;
  late int _total;
  late double _score;
  List<QuizReviewItemModel> _reviewItems = [];
  bool _isLoadingReview = false;
  String? _reviewError;

  bool get _hasReviewItems => _reviewItems.isNotEmpty;

  List<QuizReviewItemModel> get _filteredReviewItems {
    return _reviewItems.where((item) {
      return switch (_selectedFilter) {
        QuizReviewFilter.total => true,
        QuizReviewFilter.correct => item.isCorrect,
        QuizReviewFilter.wrong => !item.isCorrect,
      };
    }).toList();
  }

  List<MapEntry<int, QuizQuestionModel>> get _filteredQuestions {
    return widget.questions.asMap().entries.where((entry) {
      final index = entry.key;
      final q = entry.value;
      final userAns = widget.userAnswers[index];
      final isCorrect = userAns != null &&
          (userAns == q.correctAnswer ||
              (userAns is Set && userAns.contains(q.correctAnswer)));

      return switch (_selectedFilter) {
        QuizReviewFilter.total => true,
        QuizReviewFilter.correct => isCorrect,
        QuizReviewFilter.wrong => !isCorrect,
      };
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _correct = widget.correct;
    _total = widget.total;
    _score = widget.score;

    if (widget.reviewItems.isNotEmpty) {
      _reviewItems = List.from(widget.reviewItems);
    } else if (widget.quizId != null && widget.quizId!.isNotEmpty) {
      _loadReviewDetails();
    }

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    final percent = widget.score.round();
    if (percent >= 70) {
      _celebrationController.forward();
    }
  }

  Future<void> _loadReviewDetails() async {
    if (!diContainer.isRegistered<StudentRepository>()) {
      return;
    }

    setState(() {
      _isLoadingReview = true;
      _reviewError = null;
    });

    try {
      final repo = diContainer<StudentRepository>();
      final result = await repo.getQuizReviewDetails(
        widget.quizId!,
        attemptId: widget.attemptId,
      );

      if (!mounted) return;

      result.when(
        success: (items) {
          setState(() {
            _reviewItems = items;
            _isLoadingReview = false;
            if (items.isNotEmpty) {
              _total = items.length;
              _correct = items.where((e) => e.isCorrect).length;
              _score = (_correct / _total) * 100;
            }
          });
        },
        failure: (failure) {
          setState(() {
            _isLoadingReview = false;
            _reviewError =
                failure.message ?? 'Không thể tải chi tiết bài làm';
          });
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingReview = false;
        _reviewError = 'Đã có lỗi xảy ra khi tải bài làm';
      });
    }
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final percent = _score.round();
    final passed = percent >= 70;
    final wrong = _total - _correct;

    final String headline;
    final String subtitle;
    if (percent >= 90) {
      headline = 'Xuất sắc! 🎉';
      subtitle = 'Bạn đã nắm rất vững kiến thức của bài học!';
    } else if (percent >= 70) {
      headline = 'Chúc mừng bạn đã đạt! 👏';
      subtitle = 'Bạn đã hoàn thành tốt bài kiểm tra này.';
    } else if (percent >= 50) {
      headline = 'Cần cố gắng thêm! 💪';
      subtitle = 'Bạn gần đạt rồi, hãy ôn tập lại và thử lại nhé.';
    } else {
      headline = 'Chưa đạt yêu cầu 📚';
      subtitle = 'Hãy xem lại bài giảng và làm lại bài kiểm tra nhé.';
    }

    final statusColor =
        passed ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final statusBg =
        passed ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);

    final hasContent = _hasReviewItems ||
        widget.questions.isNotEmpty ||
        _isLoadingReview ||
        _reviewError != null;


    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Đóng',
                      ),
                      Expanded(
                        child: Text(
                          'Kết quả bài kiểm tra',
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
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
                        ScoreCircle(percent: percent, passed: passed),

                        AppSpacing.vGap24,

                        // Message
                        Text(
                          headline,
                          style: tt.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.vGap8,
                        Text(
                          subtitle,
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        // Passing threshold info
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                passed
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.info_outline_rounded,
                                size: 18,
                                color: statusColor,
                              ),
                              AppSpacing.hGap8,
                              Text(
                                passed
                                    ? 'Đạt yêu cầu (≥70%)'
                                    : 'Chưa đạt yêu cầu (cần ≥70%)',
                                style: tt.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        AppSpacing.vGap24,

                        // Micro-copy guidance
                        if (hasContent)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.touch_app_outlined,
                                  size: 16,
                                  color: cs.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Chạm vào từng thẻ bên dưới để lọc chi tiết bài làm:',
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Interactive Stat cards
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                icon: Icons.check_circle_rounded,
                                iconColor: const Color(0xFF059669),
                                label: 'Câu đúng',
                                value: '$_correct',
                                isSelected:
                                    _selectedFilter == QuizReviewFilter.correct,
                                onTap: () {
                                  setState(() {
                                    _selectedFilter = QuizReviewFilter.correct;
                                  });
                                },
                              ),
                            ),
                            AppSpacing.hGap8,
                            Expanded(
                              child: StatCard(
                                icon: Icons.cancel_rounded,
                                iconColor: const Color(0xFFDC2626),
                                label: 'Câu sai',
                                value: '$wrong',
                                isSelected:
                                    _selectedFilter == QuizReviewFilter.wrong,
                                onTap: () {
                                  setState(() {
                                    _selectedFilter = QuizReviewFilter.wrong;
                                  });
                                },
                              ),
                            ),
                            AppSpacing.hGap8,
                            Expanded(
                              child: StatCard(
                                icon: Icons.assignment_rounded,
                                iconColor: cs.primary,
                                label: 'Tổng câu',
                                value: '$_total',
                                isSelected:
                                    _selectedFilter == QuizReviewFilter.total,
                                onTap: () {
                                  setState(() {
                                    _selectedFilter = QuizReviewFilter.total;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        AppSpacing.vGap16,

                        // Active filter indicator banner
                        if (hasContent) ...[
                          if (!_isLoadingReview && _reviewError == null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest.withValues(
                                  alpha: 0.6,
                                ),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.filter_list_rounded,
                                    size: 16,
                                    color: cs.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    switch (_selectedFilter) {
                                      QuizReviewFilter.total =>
                                        'Đang xem: Tất cả $_total câu',
                                      QuizReviewFilter.correct =>
                                        'Đang xem: $_correct câu trả lời đúng',
                                      QuizReviewFilter.wrong =>
                                        'Đang xem: $wrong câu chưa đúng',
                                    },
                                    style: tt.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_selectedFilter != QuizReviewFilter.total)
                                    GestureDetector(
                                      onTap: () => setState(() {
                                        _selectedFilter =
                                            QuizReviewFilter.total;
                                      }),
                                      child: Text(
                                        'Xem tất cả',
                                        style: tt.labelSmall?.copyWith(
                                          color: cs.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          AppSpacing.vGap16,

                          // Question review list, Loading Skeleton, or Error state
                          if (_isLoadingReview)
                            _buildSkeletonReviewCards(cs)
                          else if (_reviewError != null)
                            _buildReviewError(cs, tt)
                          else if (_hasReviewItems) ...[
                            if (_filteredReviewItems.isEmpty)
                              _buildEmptyReviewState(cs, tt)
                            else
                              ..._filteredReviewItems.map((item) {
                                return QuestionReviewCard(
                                  index: item.index,
                                  reviewItem: item,
                                );
                              }),
                          ] else ...[
                            if (_filteredQuestions.isEmpty)
                              _buildEmptyReviewState(cs, tt)
                            else
                              ..._filteredQuestions.map((entry) {
                                final questionIndex = entry.key + 1;
                                final question = entry.value;
                                final userAns = widget.userAnswers[entry.key];
                                int? userAnsInt;
                                if (userAns is int) {
                                  userAnsInt = userAns;
                                } else if (userAns is Iterable) {
                                  final first = userAns.firstOrNull;
                                  if (first is int) userAnsInt = first;
                                }
                                return QuestionReviewCard(
                                  index: questionIndex,
                                  question: question,
                                  userAnswerIndex: userAnsInt,
                                );
                              }),
                          ],
                        ],


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
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          label: const Text('Quay về bài học'),
                        ),
                      ),
                      if (widget.quizId != null) ...[
                        AppSpacing.hGap12,
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                  builder: (_) => QuizScreen(
                                    quizId: widget.quizId!,
                                    title: widget.title,
                                    duration: widget.duration ?? 5,
                                  ),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            icon: const Icon(Icons.replay_rounded, size: 18),
                            label: const Text('Làm lại bài kiểm tra'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Celebratory Confetti Animation
            if (passed)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _celebrationController,
                    builder: (context, _) {
                      if (_celebrationController.value == 0 ||
                          _celebrationController.value == 1) {
                        return const SizedBox.shrink();
                      }
                      return CustomPaint(
                        painter: _CelebrationParticlesPainter(
                          progress: _celebrationController.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonReviewCards(ColorScheme cs) {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 70,
                    height: 22,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 22,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 16,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 180,
                height: 16,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                3,
                (i) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  height: 42,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReviewError(ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: cs.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: cs.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _reviewError!,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: _loadReviewDetails,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReviewState(ColorScheme cs, TextTheme tt) {

    final isWrongFilter = _selectedFilter == QuizReviewFilter.wrong;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            isWrongFilter
                ? Icons.emoji_events_rounded
                : Icons.auto_awesome_rounded,
            size: 48,
            color: isWrongFilter ? const Color(0xFFF59E0B) : cs.primary,
          ),
          AppSpacing.vGap12,
          Text(
            isWrongFilter
                ? 'Tuyệt vời! Bạn không làm sai câu nào cả! 🎉'
                : 'Chưa có câu trả lời đúng. Hãy ôn bài và thử lại nhé! 💪',
            style: tt.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.slate900,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vGap4,
          Text(
            isWrongFilter
                ? 'Bạn đã đạt điểm số tối đa cho toàn bộ câu hỏi.'
                : 'Xem lại bài giảng để củng cố kiến thức tốt hơn.',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Lightweight celebration confetti painter
class _CelebrationParticlesPainter extends CustomPainter {
  _CelebrationParticlesPainter({required this.progress});

  final double progress;

  static final List<Color> _colors = [
    const Color(0xFF2563EB),
    const Color(0xFF059669),
    const Color(0xFFF59E0B),
    const Color(0xFFEC4899),
    const Color(0xFF8B5CF6),
    const Color(0xFF10B981),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(42);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (int i = 0; i < 45; i++) {
      final initialX = rand.nextDouble() * size.width;
      final initialY = -20.0 + rand.nextDouble() * 40;
      final speedY = 180 + rand.nextDouble() * 260;
      final wobbleSpeed = 2 + rand.nextDouble() * 4;
      final wobbleAmplitude = 15.0 + rand.nextDouble() * 25;

      final currentY = initialY + speedY * progress;
      final currentX =
          initialX + math.sin(progress * wobbleSpeed * math.pi) * wobbleAmplitude;

      if (currentY > size.height) continue;

      final color = _colors[i % _colors.length].withValues(alpha: opacity * 0.9);
      final paint = Paint()..color = color;

      final particleSize = 6.0 + rand.nextDouble() * 5;
      final rotation = progress * math.pi * 3 * (rand.nextBool() ? 1 : -1);

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(rotation);
      if (i % 3 == 0) {
        canvas.drawCircle(Offset.zero, particleSize / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particleSize,
            height: particleSize * 0.6,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
