import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_homework_model.dart';

/// Thẻ hiển thị một bài tập về nhà theo thiết kế chuẩn
class HomeworkItemCard extends StatelessWidget {
  const HomeworkItemCard({
    super.key,
    required this.item,
    required this.onTapDetail,
    this.onTapRemindChild,
  });

  final ParentHomeworkItem item;
  final VoidCallback onTapDetail;
  final VoidCallback? onTapRemindChild;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTapDetail,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon ký hiệu môn học
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _getSubjectBgColor(item.subjectCode),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        item.subjectCode,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _getSubjectTextColor(item.subjectCode),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Thông tin bài tập
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.subjectName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Giáo viên: ${item.teacherName}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Tag hạn nộp
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: item.dueTagBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.dueTagLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: item.dueTagTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Hàng dưới: Thời gian còn lại & Nút theo dõi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 15,
                          color: item.isUrgent
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.timeRemainingText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: item.isUrgent
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (onTapRemindChild != null && item.isUrgent) ...[
                          InkWell(
                            onTap: onTapRemindChild,
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFFECACA),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.notifications_active_outlined,
                                    size: 13,
                                    color: Color(0xFFDC2626),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Nhắc con',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const Text(
                          'Chi tiết bài tập',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Color(0xFF2563EB),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getSubjectBgColor(String code) {
    switch (code) {
      case 'Σ':
        return const Color(0xFFEFF6FF);
      case 'En':
        return const Color(0xFFFFF7ED);
      case 'Sc':
        return const Color(0xFFF0FDFA);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getSubjectTextColor(String code) {
    switch (code) {
      case 'Σ':
        return const Color(0xFF2563EB);
      case 'En':
        return const Color(0xFFEA580C);
      case 'Sc':
        return const Color(0xFF0D9488);
      default:
        return const Color(0xFF475569);
    }
  }
}
