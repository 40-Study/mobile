import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_learning_insights_model.dart';
import 'package:study/theme/theme.dart';

/// Widget hiển thị phân tích sư phạm chuyên sâu 3 bước:
/// 1. Quan sát thực tế (Observation)
/// 2. Đánh giá nguyên nhân (Interpretation)
/// 3. Khuyến nghị hành động (Action)
/// Kèm liên kết bằng chứng minh bạch (Evidence Link).
class PedagogicalAnalysisCard extends StatelessWidget {
  const PedagogicalAnalysisCard({
    super.key,
    required this.insights,
    this.onTapEvidence,
  });

  final ParentLearningInsightsModel insights;
  final VoidCallback? onTapEvidence;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nhãn phụ màu cam amber
        Text(
          'PHÂN TÍCH SƯ PHẠM CHUYÊN SÂU',
          style: tt.labelSmall?.copyWith(
            color: const Color(0xFFD97706),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),

        // Tiêu đề + Badge "1 trọng tâm"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Điểm cần cải thiện',
              style: tt.titleMedium?.copyWith(
                color: cs.slate900,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                insights.improvementFocusBadge,
                style: const TextStyle(
                  color: Color(0xFFB45309),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Khối 3 bước sư phạm
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bước 1: OBSERVATION
            _buildStepBlock(
              lineColor: const Color(0xFF94A3B8),
              stepTitle: '1. QUAN SÁT THỰC TẾ (OBSERVATION)',
              titleColor: const Color(0xFF475569),
              contentWidget: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                  children: [
                    TextSpan(text: 'Minh hoàn thành '),
                    TextSpan(
                      text: '3/5 bài',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextSpan(
                      text: ' dạng phân số & rút gọn biểu thức trong 2 buổi '
                          'gần nhất (tỷ lệ đúng ',
                    ),
                    TextSpan(
                      text: '60%',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextSpan(text: ').'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Bước 2: INTERPRETATION
            _buildStepBlock(
              lineColor: const Color(0xFFF59E0B),
              stepTitle: '2. ĐÁNH GIÁ NGUYÊN NHÂN (INTERPRETATION)',
              titleColor: const Color(0xFFB45309),
              contentWidget: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                  children: [
                    TextSpan(text: 'Thấp hơn mức trung bình đại số của Minh ('),
                    TextSpan(
                      text: '85%+',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextSpan(
                      text: '). Em thường vấp lỗi nhầm dấu khi quy đồng đa '
                          'thức phức tạp.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Bước 3: ACTION
            _buildStepBlock(
              lineColor: const Color(0xFF2563EB),
              stepTitle: '3. KHUYẾN NGHỊ HÀNH ĐỘNG (ACTION)',
              titleColor: const Color(0xFF1D4ED8),
              contentWidget: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                  children: [
                    TextSpan(text: 'Nhắc Minh xem lại bài giảng '),
                    TextSpan(
                      text: 'Buổi 8',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextSpan(text: '; kết nối trực tiếp với '),
                    TextSpan(
                      text: 'Cô Lan (GV Toán)',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextSpan(
                      text: ' để nhận 3 bài tập củng cố cá nhân hoá.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Liên kết bằng chứng minh bạch (Evidence Link)
        InkWell(
          onTap: onTapEvidence,
          borderRadius: AppRadius.borderSm,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  insights.evidenceActionText,
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepBlock({
    required Color lineColor,
    required String stepTitle,
    required Color titleColor,
    required Widget contentWidget,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: lineColor,
            width: 3.5,
          ),
        ),
      ),
      padding: const EdgeInsets.only(left: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stepTitle,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          contentWidget,
        ],
      ),
    );
  }
}
