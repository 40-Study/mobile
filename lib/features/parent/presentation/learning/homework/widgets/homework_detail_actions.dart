import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_homework_model.dart';

class HomeworkDetailActions extends StatelessWidget {
  const HomeworkDetailActions({
    super.key,
    required this.detail,
    required this.onRemind,
    required this.onContactTeacher,
  });

  final ParentHomeworkDetailModel detail;
  final VoidCallback onRemind;
  final VoidCallback onContactTeacher;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Nút nhắc con nộp bài (nếu chưa nộp hoặc cần nộp gấp)
            if (detail.status == ParentHomeworkStatus.urgent ||
                detail.status == ParentHomeworkStatus.inProgress)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRemind,
                  icon: const Icon(
                    Icons.notifications_active_outlined,
                    size: 18,
                    color: Color(0xFFDC2626),
                  ),
                  label: const Text(
                    'Nhắc con nộp',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    backgroundColor: const Color(0xFFFEF2F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            if (detail.status == ParentHomeworkStatus.urgent ||
                detail.status == ParentHomeworkStatus.inProgress)
              const SizedBox(width: 12),

            // Nút nhắn tin giáo viên
            Expanded(
              flex: detail.status == ParentHomeworkStatus.graded ? 2 : 1,
              child: ElevatedButton.icon(
                onPressed: onContactTeacher,
                icon: const Icon(Icons.chat_outlined, size: 18),
                label: const Text(
                  'Nhắn giáo viên',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: const Color(0xFF2563EB),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
