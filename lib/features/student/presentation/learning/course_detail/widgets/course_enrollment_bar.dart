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
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.6),
                width: 0.8,
              ),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.favorite_outline_rounded,
                color: cs.slate600,
              ),
            ),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded, size: 20),
              label: const Text(
                'Tải tài liệu khóa học',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: cs.blue600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
