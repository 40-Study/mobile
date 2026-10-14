import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_homework_model.dart';

class HomeworkOverviewCard extends StatelessWidget {
  const HomeworkOverviewCard({super.key, required this.detail});

  final ParentHomeworkDetailModel detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusBgColor(detail.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  detail.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _getStatusTextColor(detail.status),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    detail.timeRemainingText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            detail.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Môn: ${detail.subjectName} · GV: ${detail.teacherName}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                'Hạn nộp: ${detail.dueDateText}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusBgColor(ParentHomeworkStatus status) {
    switch (status) {
      case ParentHomeworkStatus.urgent:
        return const Color(0xFFFEE2E2);
      case ParentHomeworkStatus.inProgress:
        return const Color(0xFFFEF3C7);
      case ParentHomeworkStatus.graded:
        return const Color(0xFFDCFCE7);
      case ParentHomeworkStatus.submitted:
        return const Color(0xFFEFF6FF);
      case ParentHomeworkStatus.overdue:
        return const Color(0xFFFEE2E2);
    }
  }

  Color _getStatusTextColor(ParentHomeworkStatus status) {
    switch (status) {
      case ParentHomeworkStatus.urgent:
        return const Color(0xFFDC2626);
      case ParentHomeworkStatus.inProgress:
        return const Color(0xFFD97706);
      case ParentHomeworkStatus.graded:
        return const Color(0xFF15803D);
      case ParentHomeworkStatus.submitted:
        return const Color(0xFF2563EB);
      case ParentHomeworkStatus.overdue:
        return const Color(0xFFDC2626);
    }
  }
}
