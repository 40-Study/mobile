import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_course_recommendation_models.dart';
import 'parent_course_currency.dart';

class ParentCourseTuition extends StatelessWidget {
  const ParentCourseTuition({super.key, required this.course});

  final ParentRecommendedCourseDetailModel course;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HỌC PHÍ TRỌN GÓI KỲ HỌC',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              formatParentCourseCurrency(course.tuitionFee),
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w800,
                fontSize: 28,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              formatParentCourseCurrency(course.originalFee),
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                course.discountLabel,
                style: const TextStyle(
                  color: Color(0xFF15803D),
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.verified_outlined,
              size: 16,
              color: Color(0xFF16A34A),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                course.feeSupportText,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
