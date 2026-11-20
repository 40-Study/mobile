import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class CourseLessonRow extends StatelessWidget {
  const CourseLessonRow({
    super.key,
    required this.lesson,
    required this.index,
    required this.onOpen,
    this.controls,
  });
  final Map<String, dynamic> lesson;
  final int index;
  final VoidCallback onOpen;
  final Widget? controls;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme, tt = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: AppSpacing.paddingLg,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: AppRadius.borderMd,
        ),
        child: Icon(Icons.play_lesson_outlined, color: cs.primary, size: 22),
      ),
      title: Text(
        '${index + 1}. ${lesson['title']}',
        style: tt.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Text(
          [
            if (lesson['duration_minutes'] != null)
              '${lesson['duration_minutes']} phút',
            if (lesson['is_preview'] == true) 'Xem trước',
            if (lesson['duration_minutes'] == null &&
                lesson['is_preview'] != true)
              'Mở nội dung bài học',
          ].join(' · '),
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ),
      onTap: onOpen,
      trailing: controls == null
          ? Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                controls!,
              ],
            ),
    );
  }
}
