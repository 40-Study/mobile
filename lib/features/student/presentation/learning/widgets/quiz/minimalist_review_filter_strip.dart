import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

enum QuizReviewFilterType { total, correct, wrong }

/// Bộ lọc phân tích câu hỏi phẳng tối giản (Minimalist Review Filter Strip)
/// Loại bỏ hoàn toàn hộp nhựa viền màu, hiển thị dạng Segmented Tabs phẳng
class MinimalistReviewFilterStrip extends StatelessWidget {
  const MinimalistReviewFilterStrip({
    super.key,
    required this.selectedFilter,
    required this.totalCount,
    required this.correctCount,
    required this.wrongCount,
    required this.onFilterChanged,
  });

  final QuizReviewFilterType selectedFilter;
  final int totalCount;
  final int correctCount;
  final int wrongCount;
  final ValueChanged<QuizReviewFilterType> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: cs.slate200.withValues(alpha: 0.8),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildFilterTab(
            tt,
            cs,
            type: QuizReviewFilterType.total,
            label: 'Tổng câu',
            count: '$totalCount',
          ),
          _buildFilterTab(
            tt,
            cs,
            type: QuizReviewFilterType.correct,
            label: 'Câu đúng',
            count: '$correctCount',
            activeColor: const Color(0xFF059669),
          ),
          _buildFilterTab(
            tt,
            cs,
            type: QuizReviewFilterType.wrong,
            label: 'Câu sai',
            count: '$wrongCount',
            activeColor: const Color(0xFFDC2626),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(
    TextTheme tt,
    ColorScheme cs, {
    required QuizReviewFilterType type,
    required String label,
    required String count,
    Color? activeColor,
  }) {
    final isSelected = selectedFilter == type;
    final color = isSelected
        ? (activeColor ?? const Color(0xFF2563EB))
        : cs.slate500;

    return Expanded(
      child: InkWell(
        onTap: () => onFilterChanged(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? (activeColor ?? const Color(0xFF2563EB))
                    : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: tt.labelMedium?.copyWith(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (activeColor ?? const Color(0xFF2563EB))
                          .withValues(alpha: 0.1)
                      : cs.slate100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  count,
                  style: tt.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
