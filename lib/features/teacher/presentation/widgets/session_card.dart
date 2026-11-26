import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// Card buổi dạy tiếp theo (T01+T03 theo spec).
/// Hiển thị thông tin buổi học sắp tới với nút Vào lớp và Chi tiết.
class NextSessionCard extends StatelessWidget {
  const NextSessionCard({
    super.key,
    required this.session,
    required this.api,
    required this.workplaceLabel,
    this.onChanged,
  });

  final TeacherOccurrence session;
  final TeacherApi api;
  final String workplaceLabel;
  final VoidCallback? onChanged;

  DateTime get _sessionStartTime {
    final parts = session.start.split(':');
    return DateTime(
      session.date.year,
      session.date.month,
      session.date.day,
      int.tryParse(parts.first) ?? 0,
      int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Vai trò của người dạy
    final role = session.json['teacher_role']?.toString();

    // Sĩ số
    final studentCount = session.json['student_count'] ?? 0;

    // Link phòng học
    final roomLink = session.json['room_link']?.toString();
    final hasRoom = roomLink != null && roomLink.isNotEmpty;

    // Check if session is today
    final now = DateTime.now();
    final isToday = session.date.year == now.year &&
        session.date.month == now.month &&
        session.date.day == now.day;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary,
            cs.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.layeredCard,
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isLight ? Colors.white : cs.onPrimary)
                    .withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Class icon
                    TeacherClassIcon(
                      className: session.classData.name,
                      size: 44,
                      color: cs.onPrimary,
                    ),
                    AppSpacing.hGap12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Buổi tiếp theo',
                                style: tt.labelMedium?.copyWith(
                                  color: cs.onPrimary.withValues(alpha: 0.85),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (role != null) ...[
                                AppSpacing.hGap8,
                                TeacherRoleBadge(role: role),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            session.classData.name,
                            style: tt.titleMedium?.copyWith(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGap16,
                // Time and countdown row
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: cs.onPrimary.withValues(alpha: 0.12),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 18,
                        color: cs.onPrimary,
                      ),
                      AppSpacing.hGap8,
                      Expanded(
                        child: Text(
                          isToday
                              ? '${session.start} – ${session.end}'
                              : '${DateFormat('dd/MM').format(session.date)} · ${session.start}',
                          style: tt.titleSmall?.copyWith(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TeacherCountdownBadge(
                        targetTime: _sessionStartTime,
                      ),
                    ],
                  ),
                ),
                AppSpacing.vGap12,
                // Info chips row
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _InfoChip(
                      icon: Icons.people_outline,
                      label: '$studentCount học viên',
                      color: cs.onPrimary,
                    ),
                    if (session.topic.isNotEmpty)
                      _InfoChip(
                        icon: Icons.topic_outlined,
                        label: session.topic,
                        color: cs.onPrimary,
                        maxWidth: 160,
                      ),
                  ],
                ),
                AppSpacing.vGap16,
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: hasRoom
                            ? () => _openRoom(context, roomLink)
                            : null,
                        icon: const Icon(Icons.videocam_outlined, size: 18),
                        label: const Text('Vào lớp'),
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.surface,
                          foregroundColor: cs.primary,
                          disabledBackgroundColor:
                              cs.surface.withValues(alpha: 0.5),
                          disabledForegroundColor:
                              cs.onSurface.withValues(alpha: 0.38),
                        ),
                      ),
                    ),
                    AppSpacing.hGap12,
                    OutlinedButton.icon(
                      onPressed: () => _openDetail(context),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Chi tiết'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.onPrimary,
                        side: BorderSide(
                          color: cs.onPrimary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openRoom(BuildContext context, String url) {
    // Mở link phòng bằng trình duyệt hệ thống
    // Theo spec: không gắn token của app vào URL
    launchTeacherUrl(url);
  }

  Future<void> _openDetail(BuildContext context) async {
    await teacherPush<void>(
      context,
      TeacherSessionScreen(
        api: api,
        classId: session.classId,
        sessionId: session.sessionId,
        occurrence: session,
        workplaceLabel: workplaceLabel,
      ),
    );
    onChanged?.call();
  }
}

/// Info chip trong NextSessionCard
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    this.maxWidth,
  });

  final IconData icon;
  final String label;
  final Color color;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      constraints: maxWidth != null
          ? BoxConstraints(maxWidth: maxWidth!)
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color.withValues(alpha: 0.8),
          ),
          AppSpacing.hGap4,
          Flexible(
            child: Text(
              label,
              style: tt.labelSmall?.copyWith(
                color: color.withValues(alpha: 0.85),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card hiển thị mục "Cần xử lý" (T01+T03 theo spec).
class NeedsAttentionCard extends StatelessWidget {
  const NeedsAttentionCard({
    super.key,
    required this.count,
    required this.label,
    required this.onTap,
  });

  final int count;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Material(
      color: AchievementColors.red.withValues(alpha: 0.1),
      borderRadius: AppRadius.borderMd,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AchievementColors.red,
                  borderRadius: AppRadius.borderSm,
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: tt.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Text(
                  label,
                  style: tt.bodyMedium?.copyWith(
                    color: AchievementColors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AchievementColors.red,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mở URL bằng trình duyệt in-app (Custom Tabs / SFSafariViewController).
/// Theo spec: KHÔNG gắn token của app vào URL.
Future<void> launchTeacherUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    debugPrint('Invalid URL: $url');
    return;
  }
  try {
    // Dùng inAppBrowserView cho Android Custom Tabs / iOS SFSafariViewController
    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  } catch (e) {
    // Fallback: mở bằng trình duyệt hệ thống
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Cannot open URL: $url - $e');
    }
  }
}
