import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

import 'package:study/features/student/bloc/portfolio/portfolio_state.dart';
import 'portfolio_section_header.dart';

class IntroSection extends StatelessWidget {
  const IntroSection({
    super.key,
    required this.stats,
    required this.isEditMode,
    required this.visible,
    required this.onToggleVisibility,
  });

  final PortfolioStats stats;
  final bool isEditMode;
  final bool visible;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: Column(
        children: [
          PortfolioSectionHeader(
            title: l10n.introduction,
            visible: visible,
            isEditMode: isEditMode,
            onToggleVisibility: onToggleVisibility,
          ),
          if (visible) ...[
            AppSpacing.vGap12,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: AppRadius.borderLg,
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    _StatItem(
                      icon: Icons.work_outline,
                      iconColor: cs.primary,
                      value: stats.yearsExperience,
                      label: l10n.yearsExperience,
                    ),
                    _StatDivider(),
                    _StatItem(
                      icon: Icons.folder_outlined,
                      iconColor: AchievementColors.green,
                      value: stats.projectsCompleted.toString(),
                      label: l10n.projectsCompleted,
                    ),
                    _StatDivider(),
                    _StatItem(
                      icon: Icons.emoji_events_outlined,
                      iconColor: AchievementColors.orange,
                      value: stats.certificates.toString(),
                      label: l10n.certificate,
                    ),
                    _StatDivider(),
                    _StatItem(
                      icon: Icons.favorite_outline,
                      iconColor: Colors.pink,
                      value: '${stats.followers}+',
                      label: l10n.followers,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          AppSpacing.vGap8,
          Text(
            value,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            label,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 1,
      height: 40,
      color: cs.outlineVariant.withValues(alpha: 0.5),
    );
  }
}
