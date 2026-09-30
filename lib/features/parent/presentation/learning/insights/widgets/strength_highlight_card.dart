import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_learning_insights_model.dart';
import 'package:study/theme/theme.dart';

/// Widget hiển thị phần Năng khiếu vượt trội — Thế mạnh nổi bật của con
class StrengthHighlightCard extends StatelessWidget {
  const StrengthHighlightCard({
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
        // Nhãn phụ màu xanh lá
        Text(
          'NĂNG KHIẾU VƯỢT TRỘI',
          style: tt.labelSmall?.copyWith(
            color: const Color(0xFF15803D),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),

        // Tiêu đề + Trạng thái phát huy tốt
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Thế mạnh nổi bật',
              style: tt.titleMedium?.copyWith(
                color: cs.slate900,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              insights.strengthBadge,
              style: const TextStyle(
                color: Color(0xFF16A34A),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Khối nội dung thế mạnh với viền xanh lá
        Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Color(0xFF16A34A),
                width: 3.5,
              ),
            ),
          ),
          padding: const EdgeInsets.only(left: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                insights.strengthTitle,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 4),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                  children: [
                    TextSpan(
                      text: 'Phản xạ xuất sắc ở đồ thị hàm số và bài toán '
                          'liên môn (đạt ',
                    ),
                    TextSpan(
                      text: '95% điểm tuyệt đối',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D),
                      ),
                    ),
                    TextSpan(
                      text: ' trong đợt kiểm tra 15 phút vừa qua).',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
