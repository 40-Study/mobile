import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Dải đo 4 chỉ số học thuật phẳng không viền hộp (Frameless Metric Strip)
/// Ngăn cách bằng Hairline Vertical Divider mỏng, loại bỏ hoàn toàn Card lơ lửng
class FramelessMetricStrip extends StatelessWidget {
  const FramelessMetricStrip({
    super.key,
    required this.correctCount,
    required this.totalCount,
    required this.timeSpentSeconds,
    this.totalDurationMinutes = 10,
    this.xpReward = 50,
    this.streakDays = 5,
  });

  final int correctCount;
  final int totalCount;
  final int timeSpentSeconds;
  final int totalDurationMinutes;
  final int xpReward;
  final int streakDays;

  String _formatTime(int seconds) {
    if (seconds <= 0) return '--:--';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _calculatePace(int seconds, int questions) {
    if (seconds <= 0 || questions <= 0) return '~20s/câu';
    final pace = (seconds / questions).round();
    return '${pace}s/câu';
  }

  String _paceEvaluation(int seconds, int questions) {
    if (seconds <= 0 || questions <= 0) return 'Nhịp độ ổn';
    final pace = (seconds / questions).round();
    if (pace < 15) return 'Tốc độ nhanh';
    if (pace <= 45) return 'Nhịp độ chuẩn';
    return 'Cẩn trọng';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final timeStr = _formatTime(timeSpentSeconds);
    final paceStr = _calculatePace(timeSpentSeconds, totalCount);
    final paceEval = _paceEvaluation(timeSpentSeconds, totalCount);

    final percent = totalCount > 0 ? (correctCount / totalCount * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: cs.slate200.withValues(alpha: 0.8),
            width: 0.8,
          ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // 1. Thời gian
            Expanded(
              child: _buildMetricItem(
                tt,
                cs,
                title: 'THỜI GIAN',
                value: timeStr,
                subtitle: '${totalDurationMinutes}p tối đa',
                valueColor: cs.slate900,
              ),
            ),
            _buildDivider(cs),

            // 2. Tốc độ
            Expanded(
              child: _buildMetricItem(
                tt,
                cs,
                title: 'TỐC ĐỘ',
                value: paceStr,
                subtitle: paceEval,
                subtitleColor: const Color(0xFF059669),
                valueColor: cs.slate900,
              ),
            ),
            _buildDivider(cs),

            // 3. Độ chính xác
            Expanded(
              child: _buildMetricItem(
                tt,
                cs,
                title: 'CHÍNH XÁC',
                value: '${correctCount.toString().padLeft(2, '0')}/$totalCount',
                subtitle: 'Đúng $percent%',
                valueColor: cs.slate900,
              ),
            ),
            _buildDivider(cs),

            // 4. Phần thưởng
            Expanded(
              child: _buildMetricItem(
                tt,
                cs,
                title: 'PHẦN THƯỞNG',
                value: '+$xpReward XP',
                subtitle: '🔥 Chuỗi $streakDays ngày',
                valueColor: const Color(0xFF2563EB),
                subtitleColor: const Color(0xFFD97706),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(ColorScheme cs) {
    return VerticalDivider(
      width: 1,
      thickness: 0.8,
      color: cs.slate200.withValues(alpha: 0.8),
    );
  }

  Widget _buildMetricItem(
    TextTheme tt,
    ColorScheme cs, {
    required String title,
    required String value,
    required String subtitle,
    Color? valueColor,
    Color? subtitleColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: tt.labelSmall?.copyWith(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: cs.slate400,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: tt.titleMedium?.copyWith(
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
            color: valueColor ?? cs.slate900,
            letterSpacing: -0.3,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: tt.bodySmall?.copyWith(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: subtitleColor ?? cs.slate500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
