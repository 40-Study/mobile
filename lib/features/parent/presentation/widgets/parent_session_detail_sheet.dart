import 'package:flutter/material.dart';

import 'package:study/features/parent/data/models/parent_schedule_session.dart';
import 'package:study/features/parent/presentation/schedule/parent_session_detail_screen.dart';
import 'package:study/theme/theme.dart';

/// Mở màn hình xem chi tiết ca học dành cho Phụ huynh.
/// Dùng chung cho cả màn hình Trang chủ (Home) và Tab Lịch học (Schedule).
///
/// Phụ huynh chỉ có vai trò quan sát, xem thông tin bài học, giáo viên, phòng.
/// Tuyệt đối KHÔNG có nút vào lớp học hay các hành động của học sinh.
void showParentSessionDetailSheet(
  BuildContext context, {
  required ParentScheduleSession session,
}) {
  ParentSessionDetailScreen.open(context, session: session);
}

class ParentSessionDetailSheet extends StatelessWidget {
  const ParentSessionDetailSheet({
    super.key,
    required this.session,
  });

  final ParentScheduleSession session;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle bo tròn
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cs.slate300,
                borderRadius: AppRadius.borderFull,
              ),
            ),
          ),
          // Tiêu đề & Nút đóng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHI TIẾT BUỔI HỌC',
                style: tt.labelLarge?.copyWith(
                  color: cs.slate900,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  fontSize: 14,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const Divider(height: 20),

          // Header con + môn học
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: session.childBadgeColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  session.childInitial,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: cs.slate800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${session.childName} — ${session.subjectName}',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.slate900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Giờ học to rõ + Status
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_filled_rounded,
                  color: cs.blue600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  session.timeRangeText,
                  style: tt.titleMedium?.copyWith(
                    color: cs.blue700,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  session.statusLabel,
                  style: tt.labelMedium?.copyWith(
                    color: cs.blue700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Khối nội dung bài học
          Container(
            width: double.infinity,
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NỘI DUNG BÀI HỌC',
                  style: tt.labelSmall?.copyWith(
                    color: cs.slate500,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.lessonTopic.isNotEmpty
                      ? session.lessonTopic
                      : 'Chưa cập nhật nội dung bài học',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.slate900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Giáo viên & Hình thức học
          Row(
            children: [
              Expanded(
                child: _buildDetailTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Giáo viên',
                  value: session.instructorName,
                  cs: cs,
                  tt: tt,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDetailTile(
                  icon: Icons.meeting_room_outlined,
                  label: 'Hình thức / Phòng',
                  value: session.roomOrPlatform ?? 'Trực tuyến',
                  cs: cs,
                  tt: tt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Ghi chú nhắc nhở phụ huynh (đúng vai trò giám sát)
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFD97706),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Phụ huynh lưu ý nhắc con chuẩn bị tài liệu trước giờ học.',
                    style: tt.bodySmall?.copyWith(
                      color: const Color(0xFF92400E),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Nút đóng
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: cs.slate900,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderMd,
                ),
              ),
              child: const Text('Đóng'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: cs.slate500),
              const SizedBox(width: 4),
              Text(
                label,
                style: tt.labelSmall?.copyWith(
                  color: cs.slate500,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: tt.bodySmall?.copyWith(
              color: cs.slate800,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
