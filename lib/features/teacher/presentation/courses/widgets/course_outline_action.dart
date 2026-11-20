import 'package:flutter/material.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_surface.dart';
import 'package:study/theme/theme.dart';

class CourseOutlineAction extends StatelessWidget {
  const CourseOutlineAction({
    super.key,
    required this.writable,
    required this.onOpen,
  });
  final bool writable;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), cs = Theme.of(context).colorScheme;
    return TeacherSurface(
      padding: AppSpacing.paddingXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: AppSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: AppRadius.borderMd,
                ),
                child: Icon(
                  Icons.auto_stories_outlined,
                  color: cs.onPrimaryContainer,
                ),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giáo trình',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    AppSpacing.vGap4,
                    Text(
                      writable
                          ? 'Xây dựng từng chương, bài học và học liệu cho khóa của bạn.'
                          : 'Xem các chương, bài học và nội dung hiện có.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vGap16,
          FilledButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Mở giáo trình'),
          ),
        ],
      ),
    );
  }
}
