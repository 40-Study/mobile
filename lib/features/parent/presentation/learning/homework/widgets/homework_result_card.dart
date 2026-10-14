import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_homework_model.dart';

class HomeworkResultCard extends StatelessWidget {
  const HomeworkResultCard({super.key, required this.detail});

  final ParentHomeworkDetailModel detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.stars_rounded, color: Color(0xFF16A34A), size: 20),
                  SizedBox(width: 6),
                  Text(
                    'KẾT QUẢ ĐÃ CHẤM',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF15803D),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Text(
                '${detail.score!.toStringAsFixed(1)} / ${detail.maxScore.toInt()}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF15803D),
                ),
              ),
            ],
          ),
          if (detail.teacherFeedback != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFDCFCE7)),
            const SizedBox(height: 10),
            const Text(
              'Lời phê của giáo viên:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF166534),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              detail.teacherFeedback!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF166534),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
