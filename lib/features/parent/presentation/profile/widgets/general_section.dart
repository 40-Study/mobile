import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class GeneralSection extends StatelessWidget {
  const GeneralSection({
    super.key,
    required this.onSettingsTap,
    required this.onHelpTap,
    required this.onAboutTap,
  });

  final VoidCallback onSettingsTap;
  final VoidCallback onHelpTap;
  final VoidCallback onAboutTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.general,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          AppSpacing.vGap12,
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: AppRadius.borderLg,
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                GeneralTile(
                  icon: Icons.settings_outlined,
                  iconColor: AchievementColors.green,
                  title: l10n.settingsTitle,
                  value: l10n.appearanceTitle,
                  onTap: onSettingsTap,
                ),
                GeneralTile(
                  icon: Icons.help_outline_rounded,
                  iconColor: cs.blue500,
                  title: l10n.helpCenter,
                  value: l10n.faqAndSupport,
                  onTap: onHelpTap,
                ),
                GeneralTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: cs.slate400,
                  title: l10n.aboutSettingsItem,
                  value: l10n.version('1.2.0'),
                  onTap: onAboutTap,
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GeneralTile extends StatelessWidget {
  const GeneralTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: tt.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        value,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 68),
            child: Divider(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
      ],
    );
  }
}
