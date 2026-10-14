import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_course_recommendation_models.dart';
import 'package:study/theme/theme.dart';

class ParentCourseSpecifications extends StatelessWidget {
  const ParentCourseSpecifications({super.key, required this.course});

  final ParentRecommendedCourseDetailModel course;

  @override
  Widget build(BuildContext context) {
    final specs = [
      {
        'icon': Icons.school_outlined,
        'label': 'Độ tuổi & Trình độ',
        'value': course.targetGrade,
        'isHighlight': false,
      },
      {
        'icon': Icons.hourglass_empty_rounded,
        'label': 'Thời lượng',
        'value': course.durationText,
        'isHighlight': false,
      },
      {
        'icon': Icons.calendar_today_outlined,
        'label': 'Lịch học cố định',
        'value': course.scheduleFixed,
        'isHighlight': true,
      },
      {
        'icon': Icons.laptop_chromebook_rounded,
        'label': 'Hình thức học',
        'value': course.formatText,
        'isHighlight': false,
      },
      {
        'icon': Icons.menu_book_rounded,
        'label': 'Giáo trình & Hỗ trợ',
        'value': course.materialsText,
        'isHighlight': false,
      },
      {
        'icon': Icons.person_outline_rounded,
        'label': 'Giảng viên phụ trách',
        'value': course.teacherName,
        'isHighlight': false,
        'isTeacher': true,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'THÔNG SỐ CHI TIẾT LỚP HỌC',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: specs.map((item) {
              final isHighlight = item['isHighlight'] as bool;
              final isTeacher = item['isTeacher'] as bool? ?? false;

              return Padding(
                padding: AppSpacing.paddingVerticalSm,
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 18,
                      color: const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Text(
                        item['label'] as String,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              item['value'] as String,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: isHighlight
                                    ? const Color(0xFF1D4ED8)
                                    : const Color(0xFF0F172A),
                                fontWeight: isHighlight
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (isTeacher) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              size: 15,
                              color: Color(0xFF2563EB),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
