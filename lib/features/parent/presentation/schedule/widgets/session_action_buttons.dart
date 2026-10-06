import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Sticky Bottom Action Bar cho màn hình chi tiết ca học
class SessionDetailBottomBar extends StatelessWidget {
  const SessionDetailBottomBar({
    super.key,
    required this.isCompleted,
    required this.onTeacherChat,
    required this.onReminder,
    required this.onAbsenceRequest,
  });

  final bool isCompleted;
  final VoidCallback onTeacherChat;
  final VoidCallback onReminder;
  final VoidCallback onAbsenceRequest;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
          boxShadow: [
            BoxShadow(color: Color(0x0A0F172A), blurRadius: 10, offset: Offset(0, -3)),
          ],
        ),
        child: isCompleted ? _buildCompletedActions(cs) : _buildUpcomingActions(cs),
      ),
    );
  }

  Widget _buildCompletedActions(ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: onTeacherChat,
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
              label: const Text(
                'Nhắn tin',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.slate700,
                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 46,
            child: FilledButton.icon(
              onPressed: onReminder,
              icon: const Icon(Icons.notifications_active_rounded, size: 17),
              label: const Text(
                'Nhắc con ôn luyện',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingActions(ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: onAbsenceRequest,
              icon: const Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: Color(0xFFD97706),
              ),
              label: const Text(
                'Xin vắng / Muộn',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.slate700,
                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 46,
            child: FilledButton.icon(
              onPressed: onTeacherChat,
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
              label: const Text(
                'Nhắn tin giáo viên',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
