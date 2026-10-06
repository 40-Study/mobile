import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Thẻ gợi ý phương pháp đồng hành cùng con ở cuối màn hình Inbox
class InsightsCoachTipCard extends StatelessWidget {
  const InsightsCoachTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: AppRadius.borderMd,
              ),
              child: const Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFF2563EB),
                size: 20,
              ),
            ),
            AppSpacing.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gợi ý đồng hành cùng con',
                    style: tt.titleSmall?.copyWith(
                      color: cs.slate900,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Khen ngợi nỗ lực cụ thể thay vì chỉ tập trung vào điểm số '
                    'giúp con tự tin hơn trong các bài luận và rèn luyện thói '
                    'quen tự học bền vững.',
                    style: tt.bodySmall?.copyWith(
                      color: cs.slate600,
                      height: 1.4,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
