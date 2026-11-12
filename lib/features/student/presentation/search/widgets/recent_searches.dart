import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Danh sách các từ khóa tìm kiếm gần đây
class RecentSearches extends StatelessWidget {
  const RecentSearches({
    super.key,
    required this.searches,
    required this.onTap,
    required this.onClear,
    this.onRemove,
  });

  final List<String> searches;
  final ValueChanged<String> onTap;
  final VoidCallback onClear;
  final ValueChanged<String>? onRemove;

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) return const SizedBox.shrink();

    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 17,
                    color: cs.slate500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tìm kiếm gần đây',
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.slate900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onClear,
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    'Xóa tất cả',
                    style: TextStyle(
                      color: isDark ? cs.primary : const Color(0xFF2563EB),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: searches.map((s) {
              return Material(
                color: isDark
                    ? cs.surfaceContainerHigh
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: InkWell(
                  onTap: () => onTap(s),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
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
                          Icons.access_time_rounded,
                          size: 13,
                          color: cs.slate400,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          s,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.slate800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (onRemove != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => onRemove!(s),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: cs.slate400,
                              ),
                            ),
                          ),
                        ],
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
