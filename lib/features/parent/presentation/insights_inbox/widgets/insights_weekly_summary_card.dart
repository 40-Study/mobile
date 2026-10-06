import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Thẻ tóm tắt báo cáo tuần trên màn hình Family Insights Inbox
class InsightsWeeklySummaryCard extends StatelessWidget {
  const InsightsWeeklySummaryCard({
    super.key,
    this.weekNumber = 42,
    this.needAttentionCount = 2,
    this.positiveMilestoneCount = 1,
    this.onTap,
  });

  final int weekNumber;
  final int needAttentionCount;
  final int positiveMilestoneCount;
  final VoidCallback? onTap;

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
              color: cs.shadow.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.borderLg,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: AppRadius.borderMd,
                      border: Border.all(
                        color: const Color(0xFFDCFCE7),
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_graph_rounded,
                      color: Color(0xFF16A34A),
                      size: 22,
                    ),
                  ),
                  AppSpacing.hGap12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Báo cáo tuần $weekNumber hoàn tất',
                          style: tt.titleSmall?.copyWith(
                            color: cs.slate900,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$needAttentionCount chủ đề cần chú ý • '
                          '$positiveMilestoneCount cột mốc tích cực',
                          style: tt.bodySmall?.copyWith(
                            color: cs.slate500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: cs.slate400,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
