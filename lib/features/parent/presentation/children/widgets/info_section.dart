import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class InfoSection extends StatelessWidget {
  const InfoSection({super.key, required this.title, required this.items});

  final String title;
  final List<InfoItem> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            title,
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return InfoTile(
                icon: item.icon,
                label: item.label,
                value: item.value,
                showDivider: index < items.length - 1,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class InfoItem {
  const InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: cs.onSurfaceVariant),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    AppSpacing.vGap4,
                    Text(
                      value,
                      style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Divider(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
      ],
    );
  }
}
