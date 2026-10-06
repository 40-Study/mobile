import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_schedule_session.dart';
import 'package:study/features/parent/data/models/parent_session_detail_model.dart';
import 'package:study/theme/theme.dart';

/// Card định danh con + Badge trạng thái ca học
class SessionChildIdentityCard extends StatelessWidget {
  const SessionChildIdentityCard({
    super.key,
    required this.detail,
  });

  final ParentSessionDetail detail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: detail.session.childBadgeColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              detail.session.childInitial,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: cs.slate800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.session.childName,
                  style: tt.titleSmall?.copyWith(
                    color: cs.slate900,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail.studentMajor ??
                      (detail.studentCode != null
                          ? 'Mã HS: ${detail.studentCode}'
                          : 'Học sinh'),
                  style: tt.bodySmall?.copyWith(
                    color: cs.slate500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _SessionStatusBadge(status: detail.session.status),
        ],
      ),
    );
  }
}

class _SessionStatusBadge extends StatelessWidget {
  const _SessionStatusBadge({required this.status});

  final ParentSessionStatus status;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case ParentSessionStatus.upcoming:
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFB45309);
        label = '• Sắp diễn ra';
      case ParentSessionStatus.inProgress:
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF15803D);
        label = '• Đang học';
      case ParentSessionStatus.completed:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        label = 'Đã kết thúc';
      case ParentSessionStatus.rescheduled:
        bgColor = const Color(0xFFFFEDD5);
        textColor = const Color(0xFFC2410C);
        label = 'Đã đổi lịch';
      case ParentSessionStatus.cancelled:
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFB91C1C);
        label = 'Đã hủy';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Banner thông báo khi ca học bị dời lịch hoặc hủy
class SessionRescheduleBanner extends StatelessWidget {
  const SessionRescheduleBanner({
    super.key,
    required this.detail,
  });

  final ParentSessionDetail detail;

  @override
  Widget build(BuildContext context) {
    final isCancelled = detail.session.status == ParentSessionStatus.cancelled;

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: isCancelled ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB),
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isCancelled ? const Color(0xFFFECACA) : const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCancelled ? Icons.cancel_outlined : Icons.info_outline_rounded,
            color: isCancelled
                ? const Color(0xFFDC2626)
                : const Color(0xFFD97706),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              detail.rescheduleReason ??
                  (isCancelled
                      ? 'Buổi học đã được hủy theo kế hoạch của trung tâm.'
                      : 'Buổi học đã được dời lịch giảng dạy.'),
              style: TextStyle(
                color: isCancelled
                    ? const Color(0xFF991B1B)
                    : const Color(0xFF92400E),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Khối thông tin buổi học cốt lõi (Môn, Khung giờ, Bài học, Meta)
class SessionHeroCard extends StatelessWidget {
  const SessionHeroCard({
    super.key,
    required this.detail,
    required this.onTeacherChatTap,
  });

  final ParentSessionDetail detail;
  final VoidCallback onTeacherChatTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge môn học và mã buổi học
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: AppRadius.borderSm,
                  border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
                ),
                child: Text(
                  detail.session.subjectName.toUpperCase(),
                  style: TextStyle(
                    color: cs.blue700,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const Spacer(),
              if (detail.sessionCode != null)
                Text(
                  detail.sessionCode!,
                  style: tt.labelSmall?.copyWith(
                    color: cs.slate400,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Khung giờ học
          Text(
            detail.session.timeRangeText,
            style: tt.headlineMedium?.copyWith(
              color: cs.slate900,
              fontWeight: FontWeight.w800,
              fontSize: 28,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDateFull(detail.session.startTime),
            style: tt.bodySmall?.copyWith(
              color: cs.slate500,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // Tên bài học
          Text(
            detail.session.lessonTopic.isNotEmpty
                ? detail.session.lessonTopic
                : 'Chưa cập nhật nội dung bài học',
            style: tt.titleMedium?.copyWith(
              color: cs.slate900,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1.35,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            detail.session.subjectName,
            style: tt.bodySmall?.copyWith(color: cs.slate500, fontSize: 13),
          ),
          const Divider(height: 24),

          // Meta: Hình thức học
          _MetaRow(
            icon: Icons.computer_rounded,
            label: 'Hình thức',
            valueWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 8, color: Color(0xFF16A34A)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    detail.session.roomOrPlatform ?? 'Trực tuyến (Google Meet)',
                    style: TextStyle(
                      color: cs.slate800,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Meta: Giáo viên
          _MetaRow(
            icon: Icons.person_outline_rounded,
            label: 'Giáo viên',
            valueWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        detail.teacherInfo?.displayTitleWithName ??
                            detail.session.instructorName,
                        style: TextStyle(
                          color: cs.slate900,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (detail.teacherInfo?.school != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          detail.teacherInfo!.school!,
                          style: TextStyle(color: cs.slate500, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onTeacherChatTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFDBEAFE)),
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 15,
                      color: cs.blue600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Meta: Điểm danh
          _MetaRow(
            icon: Icons.access_time_rounded,
            label: 'Điểm danh',
            valueWidget: Text(
              detail.attendanceInfo?.statusLabel ?? 'Chưa có thông tin điểm danh',
              textAlign: TextAlign.end,
              style: TextStyle(
                color: _getAttendanceColor(detail.attendanceInfo?.status),
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateFull(DateTime date) {
    const weekdays = ['', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'];
    final wd = weekdays[date.weekday];
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year;
    return '$wd, $d/$m/$y';
  }

  Color _getAttendanceColor(String? status) {
    switch (status) {
      case 'present':
        return const Color(0xFF16A34A);
      case 'late':
        return const Color(0xFFD97706);
      case 'absent_excused':
      case 'absent_unexcused':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF475569);
    }
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.valueWidget,
  });

  final IconData icon;
  final String label;
  final Widget valueWidget;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: cs.slate400),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: cs.slate500,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Align(alignment: Alignment.centerRight, child: valueWidget),
        ),
      ],
    );
  }
}
