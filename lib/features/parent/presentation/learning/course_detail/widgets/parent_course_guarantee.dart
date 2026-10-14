import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_course_recommendation_models.dart';

class ParentCourseGuarantee extends StatelessWidget {
  const ParentCourseGuarantee({super.key, required this.course});

  final ParentRecommendedCourseDetailModel course;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 20,
            color: Color(0xFF16A34A),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFF166534),
                  fontSize: 12.5,
                  height: 1.45,
                ),
                children: [
                  const TextSpan(
                    text: 'Cam kết 40Study: ',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: course.guaranteeNote),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
