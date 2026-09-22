import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Error view khi quiz load fail hoặc hết lượt
class QuizErrorView extends StatelessWidget {
  const QuizErrorView({
    super.key,
    required this.title,
    required this.message,
    required this.isMaxAttempts,
  });

  final String title;
  final String message;
  final bool isMaxAttempts;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),

            const Spacer(),

            // Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: isMaxAttempts
                          ? cs.tertiary.withValues(alpha: 0.1)
                          : cs.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isMaxAttempts ? Icons.block_rounded : Icons.error_outline_rounded,
                      size: 48,
                      color: isMaxAttempts ? cs.tertiary : cs.error,
                    ),
                  ),
                  AppSpacing.vGap24,
                  Text(
                    isMaxAttempts ? 'Đã hết lượt làm bài' : 'Không thể tải bài kiểm tra',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.vGap12,
                  Text(
                    message,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  if (isMaxAttempts) ...[
                    AppSpacing.vGap16,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, size: 16, color: cs.onSurfaceVariant),
                          AppSpacing.hGap8,
                          Text(
                            'Mỗi bài kiểm tra giới hạn 5 lượt',
                            style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Spacer(),

            // Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                child: const Text('Quay lại bài học'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
