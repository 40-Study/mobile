import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_analytics_data.dart';
import 'package:study/theme/theme.dart';
import 'child_analytics_section.dart';

class MultiChildAnalyticsContent extends StatelessWidget {
  const MultiChildAnalyticsContent({
    super.key,
    required this.analyticsList,
    this.onViewDetailForChild,
    this.onViewDetail,
    this.onViewAllReports,
  });

  final List<ParentAnalyticsData> analyticsList;
  final ValueChanged<String?>? onViewDetailForChild;
  final VoidCallback? onViewDetail;
  final VoidCallback? onViewAllReports;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < analyticsList.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
            ChildAnalyticsSection(
              analytics: analyticsList[i],
              onViewDetail: () {
                if (onViewDetailForChild != null) {
                  onViewDetailForChild!(analyticsList[i].childId);
                } else if (onViewDetail != null) {
                  onViewDetail!();
                }
              },
            ),
          ],
          AppSpacing.vGap16,
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng hợp toàn bộ con',
                  style: tt.bodySmall?.copyWith(
                    color: cs.slate500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InkWell(
                  onTap: onViewAllReports,
                  borderRadius: AppRadius.borderSm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tất cả phân tích >',
                          style: tt.labelMedium?.copyWith(
                            color: cs.blue600,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
