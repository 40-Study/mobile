import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Khối tư vấn định hướng lộ trình 1-1 và gọi điện trực tiếp
class CourseConsultationCard extends StatelessWidget {
  const CourseConsultationCard({
    super.key,
    required this.childName,
    required this.onBookConsultation,
    required this.onCallHotline,
  });

  final String childName;
  final VoidCallback onBookConsultation;
  final VoidCallback onCallHotline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF0F172A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cần định hướng lộ trình học cho $childName?',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Đặt lịch tư vấn 1–1 cùng Cố vấn học tập để xếp lịch phù '
                      'hợp với thời khóa biểu trường.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Nút Tư vấn lộ trình học cho con (Màu đen)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onBookConsultation,
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Tư vấn lộ trình học cho con',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderMd,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Nút gọi điện
              InkWell(
                onTap: onCallHotline,
                borderRadius: AppRadius.borderMd,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: const Icon(
                    Icons.phone_outlined,
                    color: Color(0xFF0F172A),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
