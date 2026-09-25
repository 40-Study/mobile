import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class CourseEnrollmentBar extends StatelessWidget {
  const CourseEnrollmentBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.favorite_outline_rounded, color: cs.onSurfaceVariant),
            ),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded),
              label: const Text('Tải tài liệu khóa học'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
