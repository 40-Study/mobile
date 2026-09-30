import 'package:flutter/material.dart';

import 'package:study/features/parent/data/models/parent_schedule_session.dart';
import 'package:study/theme/theme.dart';

/// Thẻ ca học chuẩn dùng chung cho cả Màn hình Home và Tab Lịch học.
///
/// Thiết kế 4 tầng thông tin rõ ràng:
/// 1. Header: Avatar con + Tên con — Môn học + Status badge
/// 2. Thời gian: Icon đồng hồ + Giờ to rõ (vd 09:00 — 10:00)
/// 3. Khối bài học: Box bo góc xám nhạt hiển thị nội dung bài học
/// 4. Footer: Giáo viên / phòng học + "Xem chi tiết buổi học >"
///
/// Phụ huynh chỉ có quyền xem, không vào lớp học.
class ParentScheduleCard extends StatelessWidget {
  const ParentScheduleCard({
    super.key,
    required this.session,
    this.onTap,
  });

  final ParentScheduleSession session;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderLg,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, cs, tt),
                const SizedBox(height: 10),
                _buildTimeRow(context, cs, tt),
                const SizedBox(height: 10),
                _buildLessonBox(context, cs, tt),
                const SizedBox(height: 12),
                _buildFooter(context, cs, tt),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // TẦNG 1: HEADER (CON, MÔN, STATUS BADGE)
  // =========================================================================
  Widget _buildHeader(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final childTextColor = _deriveDarkerColor(session.childBadgeColor);

    return Row(
      children: [
        // Avatar tròn nhỏ chữ cái đầu của con
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: session.childBadgeColor,
            shape: BoxShape.circle,
          ),
          child: Text(
            session.childInitial.isNotEmpty
                ? session.childInitial
                : (session.childName.isNotEmpty
                    ? session.childName.characters.first
                    : 'C'),
            style: TextStyle(
              color: childTextColor,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Tên con — Môn học
        Expanded(
          child: Text(
            '${session.childName} — ${session.subjectName}',
            style: tt.titleSmall?.copyWith(
              color: cs.slate900,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        // Badge trạng thái
        _buildStatusBadge(cs, tt),
      ],
    );
  }

  Widget _buildStatusBadge(ColorScheme cs, TextTheme tt) {
    Color bg;
    Color border;
    Color text;
    Widget? dot;

    switch (session.status) {
      case ParentSessionStatus.inProgress:
        bg = const Color(0xFFECFDF5);
        border = const Color(0xFFA7F3D0);
        text = const Color(0xFF059669);
        dot = Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 5),
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
        );
      case ParentSessionStatus.upcoming:
        bg = const Color(0xFFEFF6FF);
        border = const Color(0xFFBFDBFE);
        text = const Color(0xFF2563EB);
      case ParentSessionStatus.completed:
        bg = const Color(0xFFF1F5F9);
        border = const Color(0xFFE2E8F0);
        text = const Color(0xFF64748B);
      case ParentSessionStatus.cancelled:
        bg = const Color(0xFFFEF2F2);
        border = const Color(0xFFFECACA);
        text = const Color(0xFFDC2626);
      case ParentSessionStatus.rescheduled:
        bg = const Color(0xFFFFFBEB);
        border = const Color(0xFFFDE68A);
        text = const Color(0xFFD97706);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?dot,
          Text(
            session.statusLabel,
            style: tt.labelSmall?.copyWith(
              color: text,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TẦNG 2: THỜI GIAN (GIỜ TO RÕ)
  // =========================================================================
  Widget _buildTimeRow(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return Row(
      children: [
        Icon(
          Icons.access_time_rounded,
          size: 16,
          color: cs.blue600,
        ),
        const SizedBox(width: 6),
        Text(
          session.timeRangeText,
          style: tt.titleMedium?.copyWith(
            color: cs.slate900,
            fontWeight: FontWeight.w700,
            fontSize: 15.5,
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // TẦNG 3: BÀI HỌC (BOX BO GÓC XÁM NHẠT)
  // =========================================================================
  Widget _buildLessonBox(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final topic = session.lessonTopic.isNotEmpty
        ? session.lessonTopic
        : 'Chưa cập nhật nội dung bài học';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Bài học: ',
              style: tt.bodySmall?.copyWith(
                color: cs.slate700,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            TextSpan(
              text: topic,
              style: tt.bodySmall?.copyWith(
                color: cs.slate800,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // TẦNG 4: FOOTER (GIÁO VIÊN/PHÒNG + XEM CHI TIẾT)
  // =========================================================================
  Widget _buildFooter(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final hasRoom = session.roomOrPlatform != null &&
        session.roomOrPlatform!.isNotEmpty;
    final teacherInfo = hasRoom
        ? '${session.instructorName} · ${session.roomOrPlatform}'
        : session.instructorName;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Giáo viên / Địa điểm bên trái
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 15,
                color: cs.slate500,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  teacherInfo,
                  style: tt.bodySmall?.copyWith(
                    color: cs.slate600,
                    fontSize: 12.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Nút text xem chi tiết bên phải (chỉ xem, không vào học)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Xem chi tiết buổi học',
              style: tt.labelMedium?.copyWith(
                color: cs.blue600,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.chevron_right_rounded,
              size: 17,
              color: cs.blue600,
            ),
          ],
        ),
      ],
    );
  }

  /// Tự động sinh màu chữ đậm hơn tương phản với màu nền badge pastel
  Color _deriveDarkerColor(Color bg) {
    final hsl = HSLColor.fromColor(bg);
    return hsl
        .withLightness((hsl.lightness - 0.45).clamp(0.15, 0.4))
        .withSaturation((hsl.saturation + 0.3).clamp(0.5, 1.0))
        .toColor();
  }
}
