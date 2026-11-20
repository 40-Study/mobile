import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Vai trò của người dạy
    final role = session.json['teacher_role']?.toString();
    final roleLabel = switch (role) {
      'main' => 'Chính',
      'substitute' => 'Dạy thay',
      'assistant' => 'Trợ giảng',
      _ => null,
    };

    // Sĩ số
    final studentCount = session.json['student_count'] ?? 0;

    // Link phòng học
    final roomLink = session.json['room_link']?.toString();
    final hasRoom = roomLink != null && roomLink.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer,
            cs.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.borderLg,
      ),
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: cs.onPrimaryContainer,
                  size: 20,
                ),
                AppSpacing.hGap8,
                Text(
                  'Buổi tiếp theo',
                  style: tt.labelMedium?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (roleLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: 0.5),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Text(
                      roleLabel,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
            AppSpacing.vGap12,
            Text(
              session.classData.name,
              style: tt.titleMedium?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.vGap4,
            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 16,
                  color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                ),
                AppSpacing.hGap4,
                Text(
                  '${session.start}–${session.end}',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
                AppSpacing.hGap16,
                Icon(
                  Icons.people_outline,
                  size: 16,
                  color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                ),
                AppSpacing.hGap4,
                Text(
                  '$studentCount học viên',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            if (session.topic.isNotEmpty) ...[
              AppSpacing.vGap8,
              Text(
                session.topic,
                style: tt.bodySmall?.copyWith(
                  color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            AppSpacing.vGap16,
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: hasRoom
                        ? () => _openRoom(context, roomLink)
                        : null,
                    icon: const Icon(Icons.videocam_outlined),
                    label: const Text('Vào lớp'),
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                    ),
                  ),
                ),
                AppSpacing.hGap12,
                OutlinedButton(
                  onPressed: () => _openDetail(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.onPrimaryContainer,
                    side: BorderSide(
                      color: cs.onPrimaryContainer.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Text('Chi tiết'),
                ),
              ],
            ),
          ],
        ),
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
    final cs = Theme.of(context).colorScheme;
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

/// Mở URL bằng trình duyệt hệ thống
void launchTeacherUrl(String url) {
  // TODO: Implement using url_launcher package
  // For now, this is a placeholder
  debugPrint('Opening URL: $url');
}
