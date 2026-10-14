import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class EmptyAnalyticsCard extends StatelessWidget {
  const EmptyAnalyticsCard({super.key, this.onViewLearning});

  final VoidCallback? onViewLearning;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
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
        children: [
          Icon(Icons.analytics_outlined, size: 40, color: cs.slate300),
          AppSpacing.vGap12,
          Text(
            'Chưa có dữ liệu phân tích tuần này',
            style: tt.titleSmall?.copyWith(
              color: cs.slate900,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vGap8,
          Text(
            'Dữ liệu học tập, điểm số trung bình và nhận xét chi tiết sẽ tự '
            'động hiển thị sau khi con nộp bài tập và hoàn thành các bài kiểm '
            'tra đầu tiên.',
            style: tt.bodySmall?.copyWith(color: cs.slate500, height: 1.5),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vGap12,
          InkWell(
            onTap: onViewLearning,
            borderRadius: AppRadius.borderSm,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Xem bảng điểm các kỳ trước',
                    style: tt.labelMedium?.copyWith(
                      color: cs.blue600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: cs.blue600,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
