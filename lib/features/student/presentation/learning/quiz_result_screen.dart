import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/repository/student_repository.dart';
import 'package:study/theme/theme.dart';

import 'quiz_screen.dart';
import 'widgets/quiz/academic_score_hero.dart';
import 'widgets/quiz/frameless_metric_strip.dart';
import 'widgets/quiz/milestone_unlock_strip.dart';
import 'widgets/quiz/minimalist_review_filter_strip.dart';
import 'widgets/quiz/question_review_card.dart';

/// Màn hình Kết quả Bài kiểm tra - Bảng điểm Học thuật Liền mạch (Seamless Academic Transcript)
/// Thay thế hoàn toàn Card Fatigue bằng Editorial Layout, đầy đủ thông tin, hiệu ứng kích hoạt hứng thú
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
    this.timeSpentSeconds = 0,
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
  final int timeSpentSeconds;
  final List<QuizQuestionModel> questions;
  final Map<int, dynamic> userAnswers;
  final List<QuizReviewItemModel> reviewItems;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  QuizReviewFilterType _selectedFilter = QuizReviewFilterType.total;

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
        QuizReviewFilterType.total => true,
        QuizReviewFilterType.correct => item.isCorrect,
        QuizReviewFilterType.wrong => !item.isCorrect,
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
        QuizReviewFilterType.total => true,
        QuizReviewFilterType.correct => isCorrect,
        QuizReviewFilterType.wrong => !isCorrect,
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

  void _shareTranscript(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã tạo bản chụp bảng điểm học thuật để chia sẻ!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final percent = _score.round();
    final passed = percent >= 70;
    final wrong = _total - _correct;

    final hasContent = _hasReviewItems ||
        widget.questions.isNotEmpty ||
        _isLoadingReview ||
        _reviewError != null;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar (Tối giản, trang nhã)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 22),
                    tooltip: 'Đóng',
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Kết quả bài kiểm tra',
                          style: tt.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            fontSize: 11.5,
                            color: cs.slate500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          widget.title,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: cs.slate900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _shareTranscript(context),
                    icon: const Icon(Icons.ios_share_rounded, size: 20),
                    tooltip: 'Khoe thành tích',
                    color: cs.slate600,
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 0.8,
              color: cs.slate200.withValues(alpha: 0.8),
            ),

            // Main Content: Seamless Academic Transcript
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  10,
                  AppSpacing.screenPadding,
                  30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Hero Score & Mastery Stamp (Animated Rolling Score + Glow)
                    AcademicScoreHero(
                      score: _score,
                      correctCount: _correct,
                      totalCount: _total,
                      passingPercentage: 70.0,
                    ),

                    const SizedBox(height: 24),

                    // 2. Frameless Metric Strip (4 chỉ số phẳng không hộp)
                    FramelessMetricStrip(
                      correctCount: _correct,
                      totalCount: _total,
                      timeSpentSeconds: widget.timeSpentSeconds,
                      totalDurationMinutes: widget.duration ?? 10,
                      xpReward: passed ? 50 : 20,
                      streakDays: 5,
                    ),

                    const SizedBox(height: 16),

                    // 3. Milestone Unlock Strip (Thông báo mở khóa học vụ)
                    MilestoneUnlockStrip(
                      isPassed: passed,
                      remainingAttempts: 2,
                    ),

                    const SizedBox(height: 24),

                    // 4. Detailed Question Analysis Section Header
                    if (_total > 0) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'PHÂN TÍCH CHI TIẾT BÀI LÀM',
                          style: tt.labelSmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: cs.slate500,
                          ),
                        ),
                      ),

                      // 5. Minimalist Segmented Tabs Filter
                      MinimalistReviewFilterStrip(
                        selectedFilter: _selectedFilter,
                        totalCount: _total,
                        correctCount: _correct,
                        wrongCount: wrong,
                        onFilterChanged: (newFilter) {
                          setState(() => _selectedFilter = newFilter);
                        },
                      ),
                    ],

                    // 6. Question Review Items, Loading Skeleton, or Error
                    if (hasContent) ...[
                      if (_isLoadingReview)
                        _buildSkeletonReviewItems(cs)
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
                  ],
                ),
              ),
            ),

            // Bottom Balanced Action Dock
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (widget.quizId != null) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => QuizScreen(
                                quizId: widget.quizId!,
                                title: widget.title,
                                duration: widget.duration ?? 10,
                              ),
                            ),
                          );
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.replay_rounded, size: 17),
                      label: const Text('Làm lại bài kiểm tra'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.slate700,
                        side: BorderSide(color: cs.slate300, width: 0.8),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded, size: 17),
                      label: const Text('Quay về bài học'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

  Widget _buildSkeletonReviewItems(ColorScheme cs) {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: cs.slate200.withValues(alpha: 0.6),
                width: 0.8,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32,
                    height: 16,
                    decoration: BoxDecoration(
                      color: cs.slate200.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 14,
                    decoration: BoxDecoration(
                      color: cs.slate200.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 15,
                decoration: BoxDecoration(
                  color: cs.slate200.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 180,
                height: 15,
                decoration: BoxDecoration(
                  color: cs.slate200.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                3,
                (_) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  height: 28,
                  decoration: BoxDecoration(
                    color: cs.slate100,
                    borderRadius: BorderRadius.circular(4),
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
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cs.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: cs.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _reviewError!,
              style: tt.bodySmall?.copyWith(
                color: cs.error,
                fontWeight: FontWeight.w600,
              ),
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
    final String label;
    final IconData icon;

    switch (_selectedFilter) {
      case QuizReviewFilterType.correct:
        label = 'Không có câu hỏi nào đúng';
        icon = Icons.cancel_outlined;
        break;
      case QuizReviewFilterType.wrong:
        label = 'Tuyệt vời! Bạn không làm sai câu nào cả 🎉';
        icon = Icons.check_circle_outline_rounded;
        break;
      case QuizReviewFilterType.total:
        label = 'Không có câu hỏi nào trong danh sách';
        icon = Icons.quiz_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(icon, size: 36, color: cs.slate400),
          const SizedBox(height: 10),
          Text(
            label,
            style: tt.bodyMedium?.copyWith(
              color: cs.slate500,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
