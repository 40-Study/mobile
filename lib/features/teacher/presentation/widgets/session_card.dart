import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_live_sessions_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// Highlights the next session in the agenda.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final roomLink = session.json['room_link']?.toString().trim() ?? '';
    final liveId =
        session.json['livestream_session_id']?.toString().trim() ?? '';
    final hasRoom = liveId.isNotEmpty || roomLink.isNotEmpty;
    final topic = session.topic.trim();
    final time = '${session.start}–${session.end}';
    final showDate = !DateUtils.isSameDay(session.date, DateTime.now());
    final timeLabel = showDate
        ? '${DateFormat('dd/MM').format(session.date)} · $time'
        : time;
    final metadataStyle = tt.labelMedium?.copyWith(
      color: cs.onPrimaryContainer,
      fontWeight: FontWeight.w600,
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderLg,
        side: BorderSide(color: cs.primary.withValues(alpha: 0.16)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            hint: 'Mở chi tiết buổi dạy',
            child: InkWell(
              onTap: () => _openDetail(context),
              child: Padding(
                padding: AppSpacing.paddingLg,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: AppSpacing.md,
                            runSpacing: AppSpacing.xs,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                session.status == 'in_progress'
                                    ? 'Đang dạy'
                                    : 'Buổi tiếp theo',
                                style: metadataStyle,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: 0.10),
                                  borderRadius: AppRadius.borderSm,
                                ),
                                child: Text(timeLabel, style: metadataStyle),
                              ),
                            ],
                          ),
                          AppSpacing.vGap8,
                          Text(
                            session.classData.name,
                            style: tt.titleMedium?.copyWith(
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (topic.isNotEmpty) ...[
                            AppSpacing.vGap4,
                            Text(
                              topic,
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onPrimaryContainer,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    AppSpacing.hGap8,
                    Icon(
                      Icons.chevron_right,
                      size: AppIconSize.lg,
                      color: cs.onPrimaryContainer,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (hasRoom)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: FilledButton.icon(
                onPressed: () {
                  if (liveId.isNotEmpty) {
                    teacherPush<void>(
                      context,
                      TeacherLiveSessionScreen(api: api, sessionId: liveId),
                    );
                  } else {
                    launchTeacherUrl(context, roomLink);
                  }
                },
                icon: const Icon(Icons.videocam_outlined),
                label: const Text('Vào phòng'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openDetail(BuildContext context) async {
    final changed = await teacherPush<bool>(
      context,
      TeacherSessionScreen(
        api: api,
        classId: session.classId,
        sessionId: session.sessionId,
        occurrence: session,
        workplaceLabel: workplaceLabel,
      ),
    );
    if (changed == true && context.mounted) onChanged?.call();
  }
}

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
              Icon(Icons.chevron_right, color: AchievementColors.red, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mở URL bằng trình duyệt in-app (Custom Tabs / SFSafariViewController).
/// Theo spec: KHÔNG gắn token của app vào URL.
Future<void> launchTeacherUrl(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null &&
      (uri.scheme == 'https' || uri.scheme == 'http') &&
      uri.host.isNotEmpty) {
    for (final mode in [
      LaunchMode.inAppBrowserView,
      LaunchMode.externalApplication,
    ]) {
      try {
        if (await launchUrl(uri, mode: mode)) return;
      } catch (_) {
        // Try the next available browser mode.
      }
    }
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không mở được link phòng học.')),
    );
  }
}
