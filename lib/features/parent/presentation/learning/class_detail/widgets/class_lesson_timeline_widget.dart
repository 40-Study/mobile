import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_class_detail_model.dart';

/// Widget danh sách Lộ trình & Danh sách buổi học dạng Timeline dọc
class ClassLessonTimelineWidget extends StatelessWidget {
  const ClassLessonTimelineWidget({
    super.key,
    required this.lessons,
    this.onTapLesson,
  });

  final List<ClassLessonItem> lessons;
  final void Function(ClassLessonItem item)? onTapLesson;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề header của section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'LỘ TRÌNH & DANH SÁCH BUỔI HỌC',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '${lessons.length} buổi',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Container màu trắng chứa Timeline
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF1F5F9),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final item = lessons[index];
              final isLast = index == lessons.length - 1;

              return _buildTimelineItem(context, item, isLast);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    ClassLessonItem item,
    bool isLast,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Cột Icon Node + Đường line dọc
          SizedBox(
            width: 20,
            child: Column(
              children: [
                const SizedBox(height: 4),
                _buildDotIndicator(item.status),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // 2. Nội dung thông tin buổi học
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hàng Tiêu đề buổi + Badge trạng thái
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: const Color(0xFF0F172A),
                            fontWeight: item.status ==
                                    ClassLessonStatus.completedToday
                                ? FontWeight.w800
                                : FontWeight.w600,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(item),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Dòng phụ đề tóm tắt buổi học
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _buildSubtitleText(item),
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Nút link Xem bài học (nếu có)
                  if (item.canViewLesson &&
                      item.status == ClassLessonStatus.completedToday) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => onTapLesson?.call(item),
                      child: const Text(
                        'Xem bài học →',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(ClassLessonStatus status) {
    switch (status) {
      case ClassLessonStatus.completedToday:
        return Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFF16A34A),
            shape: BoxShape.circle,
          ),
        );
      case ClassLessonStatus.completed:
        return Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Color(0xFF94A3B8),
            shape: BoxShape.circle,
          ),
        );
      case ClassLessonStatus.upcoming:
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFCBD5E1),
              width: 2,
            ),
          ),
        );
    }
  }

  Widget _buildStatusBadge(ClassLessonItem item) {
    switch (item.status) {
      case ClassLessonStatus.completedToday:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            item.statusLabel,
            style: const TextStyle(
              color: Color(0xFF15803D),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        );
      case ClassLessonStatus.completed:
        return Text(
          item.statusLabel,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        );
      case ClassLessonStatus.upcoming:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            item.statusLabel,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        );
    }
  }

  String _buildSubtitleText(ClassLessonItem item) {
    final parts = <String>[];
    if (item.timeSubtitle.isNotEmpty) {
      parts.add(item.timeSubtitle);
    }
    if (item.quizScoreText != null) {
      parts.add('Điểm quiz: ${item.quizScoreText}');
    }
    if (item.hasVideoRecording) {
      parts.add('Có video xem lại');
    }
    if (item.noteText != null) {
      parts.add(item.noteText!);
    }
    return parts.join(' · ');
  }
}
