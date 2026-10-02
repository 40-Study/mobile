import 'package:flutter/material.dart';

/// Card thông báo trạng thái tích cực All-Clear khi không có bài tập quá hạn
class HomeworkEmptyAllClearCard extends StatelessWidget {
  const HomeworkEmptyAllClearCard({
    super.key,
    required this.childName,
    required this.onTapViewAll,
  });

  final String childName;
  final VoidCallback onTapViewAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBBF7D0),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFF16A34A),
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Không có bài tập nào quá hạn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15803D),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            '$childName đang hoàn thành bài tập đúng hạn. Rất tuyệt vời!',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF166534),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onTapViewAll,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF86EFAC)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Xem tất cả bài tập',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF15803D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
