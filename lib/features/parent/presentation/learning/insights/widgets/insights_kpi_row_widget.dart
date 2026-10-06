import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_learning_insights_model.dart';
import 'package:study/theme/theme.dart';

/// Widget hiển thị 3 chỉ số học tập trọng yếu và mức độ tập trung & tương tác
class InsightsKpiRowWidget extends StatelessWidget {
  const InsightsKpiRowWidget({
    super.key,
    required this.insights,
  });

  final ParentLearningInsightsModel insights;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nhãn phụ UPPERCASE
        Text(
          'CHỈ SỐ HỌC TẬP TRỌNG YẾU',
          style: tt.labelSmall?.copyWith(
            color: cs.slate500,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),

        // Tiêu đề phần + Badge tuần
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              insights.overviewTitle,
              style: tt.titleMedium?.copyWith(
                color: cs.slate900,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    insights.weekBadge,
                    style: const TextStyle(
                      color: Color(0xFF15803D),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Card chỉ số
        Container(
          padding: AppSpacing.paddingLg,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // 3 Cột chỉ số chính
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cột 1: Tham dự lớp
                  Expanded(
                    child: _buildKpiColumn(
                      title: 'Tham dự lớp',
                      value: '${insights.attendanceRatePercent}%',
                      valueColor: cs.slate900,
                      highlightText: '+4%',
                      highlightColor: const Color(0xFF16A34A),
                      subtext: ' (23/25 buổi)',
                    ),
                  ),
                  _buildDivider(),

                  // Cột 2: Hoàn thành bài
                  Expanded(
                    child: _buildKpiColumn(
                      title: 'Hoàn thành bài',
                      value: '${insights.homeworkCompletionPercent}%',
                      valueColor: cs.slate900,
                      highlightText: 'Đúng hạn',
                      highlightColor: const Color(0xFF2563EB),
                      subtext: ' (17/20)',
                    ),
                  ),
                  _buildDivider(),

                  // Cột 3: Điểm trung bình
                  Expanded(
                    child: _buildKpiColumn(
                      title: 'Điểm trung bình',
                      value: insights.averageGrade.toStringAsFixed(1),
                      valueColor: const Color(0xFF2563EB),
                      highlightText: '+0.8',
                      highlightColor: const Color(0xFF16A34A),
                      subtext: ' với đầu kỳ',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              Divider(
                color: cs.outlineVariant.withValues(alpha: 0.35),
                height: 1,
              ),
              const SizedBox(height: 12),

              // Dòng chân card: Mức độ tập trung & tương tác trên lớp
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mức độ tập trung & tương tác trên lớp',
                      style: TextStyle(
                        color: cs.slate700,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${insights.focusAndInteractionPercent}% ',
                          style: TextStyle(
                            color: cs.slate900,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                        TextSpan(
                          text: '(${insights.focusAndInteractionStatus})',
                          style: TextStyle(
                            color: cs.slate500,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiColumn({
    required String title,
    required String value,
    required Color valueColor,
    required String highlightText,
    required Color highlightColor,
    required String subtext,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            children: [
              TextSpan(
                text: highlightText,
                style: TextStyle(
                  color: highlightColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              TextSpan(
                text: subtext,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 48,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: const Color(0xFFE2E8F0),
    );
  }
}
