import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class TrendingKeywordsSection extends StatelessWidget {
  const TrendingKeywordsSection({
    super.key,
    required this.keywords,
    required this.onTap,
  });

  final List<String> keywords;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (keywords.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                size: 17,
                color: Color(0xFFEA580C),
              ),
              const SizedBox(width: 6),
              Text(
                'Xu hướng tìm kiếm',
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.slate900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: keywords.map((k) {
              return Material(
                color: isDark
                    ? cs.surfaceContainerHigh
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: InkWell(
                  onTap: () => onTap(k),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6.5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: isDark
                            ? cs.outlineVariant.withValues(alpha: 0.35)
                            : const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          size: 14,
                          color: isDark ? cs.primary : const Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          k,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cs.slate800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
