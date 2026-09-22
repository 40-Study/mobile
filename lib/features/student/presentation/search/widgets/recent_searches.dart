import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Recent search chips + empty state
class RecentSearches extends StatelessWidget {
  const RecentSearches({
    super.key,
    required this.searches,
    required this.onTap,
    required this.onClear,
  });

  final List<String> searches;
  final void Function(String) onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (searches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_rounded,
                size: 64,
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Tim kiem khoa hoc, bai hoc',
                style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tim kiem gan day',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: onClear,
                child: Text(
                  'Xoa tat ca',
                  style: tt.labelMedium?.copyWith(color: cs.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: searches.map((s) {
              return InkWell(
                onTap: () => onTap(s),
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history, size: 16, color: cs.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(s, style: tt.bodyMedium),
                    ],
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
