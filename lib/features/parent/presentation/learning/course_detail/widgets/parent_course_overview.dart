import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_course_recommendation_models.dart';

class ParentCourseOverview extends StatelessWidget {
  const ParentCourseOverview({
    super.key,
    required this.course,
    required this.childName,
  });
  final ParentRecommendedCourseDetailModel course;
  final String childName;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Tag trên cùng
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                course.subjectTag,
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 13,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Gợi ý riêng cho ${childName}',
                    style: const TextStyle(
                      color: Color(0xFFD97706),
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 2. Tên khóa học & mô tả phụ
        Text(
          course.courseName,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 22,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          course.subtitle,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),

        // 3. Đánh giá sao & số học viên
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
            const SizedBox(width: 4),
            Text(
              course.rating.toStringAsFixed(1),
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
              ),
            ),
            Text(
              ' (${course.reviewCount} đánh giá) • ',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const Icon(
              Icons.people_outline_rounded,
              size: 16,
              color: Color(0xFF64748B),
            ),
            const SizedBox(width: 4),
            Text(
              '${course.studentCount} học viên đang theo học',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}
