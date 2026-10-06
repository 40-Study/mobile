import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Notes tab hiển thị ghi chú của học viên
class LessonNotesSection extends StatelessWidget {
  const LessonNotesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 20, color: cs.primary),
              AppSpacing.hGap8,
              Text('Ghi chu cua ban', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          AppSpacing.vGap12,
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: TextField(
                maxLines: null,
                expands: true,
                decoration: InputDecoration.collapsed(
                  hintText: 'Viet ghi chu...',
                  hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                ),
                style: tt.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
