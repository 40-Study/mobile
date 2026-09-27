import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/bloc/theme/app_theme.dart';
import 'package:study/bloc/theme/theme_cubit.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/app_header_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _scheduleReminders = true;
  bool _autoplay = false;
  bool _wifiDownloads = true;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppHeaderBar(
        title: l10n.settingsTitle,
        showBackButton: true,
        showNotification: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.sm,
          AppSpacing.screenPadding,
          AppSpacing.xxl,
        ),
        children: [
          _SectionTitle(title: l10n.settingsAppearance),
          _SettingsCard(
            children: [
              const _ThemeToggle(),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.language,
                title: l10n.settingsLanguage,
                trailing: Text(l10n.settingsLanguageVietnamese, style: tt.bodySmall),
                onTap: () {},
              ),
            ],
          ),
          AppSpacing.vGap24,

          _SectionTitle(title: l10n.settingsNotifications),
          _SettingsCard(
            children: [
              _SettingsSwitch(
                icon: Icons.notifications_active,
                title: l10n.settingsPushNotifications,
                value: _pushNotifications,
                onChanged: (value) =>
                    setState(() => _pushNotifications = value),
              ),
              const Divider(height: 1),
              _SettingsSwitch(
                icon: Icons.email,
                title: l10n.settingsEmailNotifications,
                value: _emailNotifications,
                onChanged: (value) =>
                    setState(() => _emailNotifications = value),
              ),
              const Divider(height: 1),
              _SettingsSwitch(
                icon: Icons.calendar_today,
                title: l10n.settingsScheduleReminders,
                value: _scheduleReminders,
                onChanged: (value) =>
                    setState(() => _scheduleReminders = value),
              ),
            ],
          ),
          AppSpacing.vGap24,

          _SectionTitle(title: l10n.settingsLearning),
          _SettingsCard(
            children: [
              _SettingsSwitch(
                icon: Icons.play_circle,
                title: l10n.settingsAutoplayVideo,
                value: _autoplay,
                onChanged: (value) => setState(() => _autoplay = value),
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.speed,
                title: l10n.settingsPlaybackSpeed,
                trailing: Text('1.0x', style: tt.bodySmall),
                onTap: () {},
              ),
              const Divider(height: 1),
              _SettingsSwitch(
                icon: Icons.download,
                title: l10n.settingsWifiDownload,
                value: _wifiDownloads,
                onChanged: (value) => setState(() => _wifiDownloads = value),
              ),
            ],
          ),
          AppSpacing.vGap24,

          _SectionTitle(title: l10n.settingsOther),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.storage,
                title: l10n.settingsClearCache,
                trailing: Text('24 MB', style: tt.bodySmall),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.settingsCacheCleared)),
                  );
                },
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.info_outline,
                title: l10n.settingsVersion,
                trailing: Text('1.0.0', style: tt.bodySmall),
                onTap: () {},
              ),
            ],
          ),
          AppSpacing.vGap32,
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
      child: Text(
        title,
        style: tt.labelLarge?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: cs.outline),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      leading: Icon(icon, color: cs.onSurfaceVariant, size: 22),
      title: Text(title, style: tt.bodyMedium),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?trailing,
          AppSpacing.hGap8,
          Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      leading: Icon(icon, color: cs.onSurfaceVariant, size: 22),
      title: Text(title, style: tt.bodyMedium),
      trailing: Switch.adaptive(value: value, onChanged: onChanged),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final themeCubit = context.watch<ThemeCubit>();
    final isDark = themeCubit.state.themeMode == ThemeMode.dark;

    return ListTile(
      leading: Icon(
        isDark ? Icons.dark_mode : Icons.light_mode,
        color: cs.onSurfaceVariant,
        size: 22,
      ),
      title: Text(l10n.settingsDarkTheme, style: tt.bodyMedium),
      trailing: Switch.adaptive(
        value: isDark,
        onChanged: (v) =>
            themeCubit.setThemeMode(v ? AppThemeMode.dark : AppThemeMode.light),
      ),
    );
  }
}
