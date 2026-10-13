import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Notes tab hiển thị ghi chú của học viên
class LessonNotesSection extends StatelessWidget {
  const LessonNotesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 22, color: cs.primary),
              AppSpacing.hGap8,
              Text(
                'Ghi chú của bạn',
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.slate900,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.cloud_done_rounded,
                    size: 16,
                    color: Color(0xFF059669),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Đã lưu tự động',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.vGap12,
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md + 2),
              decoration: BoxDecoration(
                color: isLight ? Colors.white : cs.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.6),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                maxLines: null,
                expands: true,
                decoration: InputDecoration.collapsed(
                  hintText: 'Viết ghi chú bài học của bạn tại đây...',
                  hintStyle: tt.bodyMedium?.copyWith(
                    color: cs.slate400,
                  ),
                ),
                style: tt.bodyMedium?.copyWith(color: cs.slate900),
              ),
            ),
          ),
          AppSpacing.vGap12,
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã lưu ghi chú thành công'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Lưu ghi chú'),
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
