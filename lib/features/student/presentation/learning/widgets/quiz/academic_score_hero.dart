import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study/theme/theme.dart';

/// Thành phần Vinh danh Điểm số & Con dấu Thẩm định Học thuật (Academic Score Hero)
/// Bố cục phẳng liền mạch (Seamless Canvas) - Không dùng Card đóng hộp
class AcademicScoreHero extends StatefulWidget {
  const AcademicScoreHero({
    super.key,
    required this.score,
    required this.correctCount,
    required this.totalCount,
    this.passingPercentage = 70.0,
    this.enableHaptics = true,
  });

  final double score;
  final int correctCount;
  final int totalCount;
  final double passingPercentage;
  final bool enableHaptics;

  @override
  State<AcademicScoreHero> createState() => _AcademicScoreHeroState();
}

class _AcademicScoreHeroState extends State<AcademicScoreHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scoreAnimation;
  late final Animation<double> _stampScaleAnimation;
  late final Animation<double> _glowAnimation;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // 1. Score Counter: 0.0 -> target score (0 - 1000ms)
    _scoreAnimation = Tween<double>(begin: 0.0, end: widget.score).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.70, curve: Curves.easeOutExpo),
      ),
    );

    // 2. Aurora Glow Breathing (0 - 1600ms)
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.9, curve: Curves.easeInOut),
      ),
    );

    // 3. Stamp Stamp Drop & Spring Bounce (700ms - 1200ms)
    _stampScaleAnimation = Tween<double>(begin: 1.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 1.0, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();

    // Haptic feedback sequence
    _triggerHaptics();
  }

  void _triggerHaptics() {
    if (!widget.enableHaptics) return;
    _scheduleTimer(
      const Duration(milliseconds: 300),
      HapticFeedback.selectionClick,
    );
    _scheduleTimer(
      const Duration(milliseconds: 700),
      HapticFeedback.selectionClick,
    );
    _scheduleTimer(const Duration(milliseconds: 1050), () {
      if (widget.score >= widget.passingPercentage) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    });
  }

  void _scheduleTimer(Duration duration, VoidCallback callback) {
    final timer = Timer(duration, () {
      if (!mounted) return;
      callback();
    });
    _timers.add(timer);
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final percent = widget.score.round();
    final isPassed = percent >= widget.passingPercentage;
    final isMastery = percent >= 90;

    // Academic Color Tones
    final Color primaryColor;
    final Color stampBg;
    final Color stampBorder;
    final String stampText;

    if (isMastery) {
      primaryColor = const Color(0xFF1D4ED8); // Royal Navy Blue
      stampBg = isDark
          ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
          : const Color(0xFFEFF6FF);
      stampBorder = const Color(0xFF2563EB);
      stampText = '★ CHỨNG NHẬN XUẤT SẮC ★';
    } else if (isPassed) {
      primaryColor = const Color(0xFF059669); // Emerald Green
      stampBg = isDark
          ? const Color(0xFF064E3B).withValues(alpha: 0.3)
          : const Color(0xFFECFDF5);
      stampBorder = const Color(0xFF059669);
      stampText = '✓ ĐẠT YÊU CẦU CHUẨN';
    } else {
      primaryColor = const Color(0xFFD97706); // Amber Slate
      stampBg = isDark
          ? const Color(0xFF78350F).withValues(alpha: 0.3)
          : const Color(0xFFFFFBEB);
      stampBorder = const Color(0xFFD97706);
      stampText = '⚑ CẦN BỔ SUNG KIẾN THỨC';
    }

    // Personalized Pedagogical Feedback
    final String feedbackTitle;
    final String feedbackSubtitle;
    if (percent == 100) {
      feedbackTitle = 'Tuyệt đối 100%! Năng lực hoàn hảo';
      feedbackSubtitle =
          'Bạn đã nắm trọn vẹn toàn bộ kiến thức chuyên sâu của học phần này.';
    } else if (percent >= 90) {
      feedbackTitle = 'Xuất sắc! Nắm rất vững kiến thức';
      feedbackSubtitle =
          'Bạn thể hiện tư duy học thuật vượt trội và sẵn sàng cho bài tiếp theo.';
    } else if (percent >= 70) {
      feedbackTitle = 'Chúc mừng bạn đã đạt! 👏';
      feedbackSubtitle =
          'Nền tảng kiến thức bài học được hoàn thành đạt chuẩn học vụ.';
    } else if (percent >= 50) {
      feedbackTitle = 'Cần cố gắng thêm một chút nữa!';
      feedbackSubtitle =
          'Bạn chỉ còn thiếu một chút để đạt 70%. Hãy ôn lại câu sai và thử lại nhé.';
    } else {
      feedbackTitle = 'Chưa đạt yêu cầu học vụ';
      feedbackSubtitle =
          'Hãy dành ít phút xem lại bài giảng lý thuyết trước khi làm lại bài.';
    }

    return Column(
      children: [
        const SizedBox(height: 12),

        // Hero Score Center with Subtle Aurora Glow
        Stack(
          alignment: Alignment.center,
          children: [
            // Ambient Radial Aurora Glow (Thở nhẹ, khuếch tán mềm)
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, _) {
                final glowOpacity = 0.08 * _glowAnimation.value;
                return Container(
                  width: 220,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primaryColor.withValues(alpha: glowOpacity),
                        primaryColor.withValues(alpha: 0.0),
                      ],
                      radius: 0.8,
                    ),
                  ),
                );
              },
            ),

            // Animated Rolling Score Figures (Monospace Tabular Figures)
            AnimatedBuilder(
              animation: _scoreAnimation,
              builder: (context, _) {
                final currentScore = _scoreAnimation.value;
                final current10 = ((currentScore / 100) * 10).toStringAsFixed(1);
                final currentPercent = currentScore.round();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          current10,
                          style: tt.displayLarge?.copyWith(
                            fontSize: 54,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                            color: cs.slate900,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ 10',
                          style: tt.titleMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: cs.slate400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tỉ lệ đạt: $currentPercent%',
                      style: tt.labelMedium?.copyWith(
                        color: cs.slate500,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Academic Stamp of Mastery (Dập nảy nhẹ, phong cách văn bằng)
        ScaleTransition(
          scale: _stampScaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: stampBg,
              borderRadius: BorderRadius.circular(6), // Bo góc 6px sắc sảo
              border: Border.all(
                color: stampBorder.withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
            child: Text(
              stampText,
              style: tt.labelMedium?.copyWith(
                color: stampBorder,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Personalized Pedagogical Feedback (Thoáng đãng, không đóng hộp)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Text(
                feedbackTitle,
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16.5,
                  color: cs.slate900,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                feedbackSubtitle,
                style: tt.bodySmall?.copyWith(
                  color: cs.slate500,
                  fontSize: 13,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Academic Benchmark Line (Thước đo chuẩn học vụ mỏng 4px)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _AcademicBenchmarkLine(
            score: widget.score,
            passingPercentage: widget.passingPercentage,
          ),
        ),
      ],
    );
  }
}

/// Thước đo chuẩn học vụ (Academic Passing Benchmark Line)
class _AcademicBenchmarkLine extends StatelessWidget {
  const _AcademicBenchmarkLine({
    required this.score,
    required this.passingPercentage,
  });

  final double score;
  final double passingPercentage;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final percent = score.clamp(0.0, 100.0);
    final benchmark = passingPercentage.clamp(0.0, 100.0);
    final diff = percent - benchmark;
    final isAbove = diff >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Đạt yêu cầu (≥${benchmark.round()}%)',
              style: tt.labelSmall?.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: cs.slate400,
                letterSpacing: 0.4,
              ),
            ),
            Text(
              isAbove
                  ? '+${diff.round()}% vượt chuẩn'
                  : '${diff.abs().round()}% còn thiếu',
              style: tt.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isAbove
                    ? const Color(0xFF059669)
                    : const Color(0xFFD97706),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final benchmarkPos = (benchmark / 100) * width;
            final scorePos = (percent / 100) * width;

            return SizedBox(
              height: 18,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  // Track background
                  Container(
                    width: width,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.slate200.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Filled progress line
                  Container(
                    width: scorePos,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isAbove
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Benchmark Marker pin (70%)
                  Positioned(
                    left: benchmarkPos - 1,
                    top: -1,
                    child: Container(
                      width: 2,
                      height: 6,
                      color: cs.slate700,
                    ),
                  ),

                  // Current Score Indicator Head
                  Positioned(
                    left: (scorePos - 5).clamp(0.0, width - 10),
                    top: -3,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isAbove
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
