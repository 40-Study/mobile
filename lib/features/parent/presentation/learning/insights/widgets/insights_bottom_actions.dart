import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class InsightsBottomActions extends StatelessWidget {
  const InsightsBottomActions({
    super.key,
    required this.onContactTeacher,
    required this.onRecommendations,
  });

  final VoidCallback onContactTeacher;
  final VoidCallback onRecommendations;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Nút 1: Nhắn GVCN (Chiếm ~40%)
            Expanded(
              flex: 4,
              child: OutlinedButton.icon(
                onPressed: onContactTeacher,
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 18,
                  color: Color(0xFF0F172A),
                ),
                label: const Text(
                  'Nhắn GVCN',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderMd,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Nút 2: Xem lộ trình cải thiện → (Chiếm ~60%)
            Expanded(
              flex: 6,
              child: ElevatedButton(
                onPressed: onRecommendations,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderMd,
                  ),
                ),
                child: const Text(
                  'Xem lộ trình cải thiện →',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
