import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/bloc/theme/app_theme.dart';
import 'package:study/bloc/theme/theme_cubit.dart';
import 'package:study/theme/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cai dat')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Giao dien
          _SectionTitle(title: 'Giao dien'),
          _SettingsCard(
            children: [
              _ThemeToggle(),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.language,
                title: 'Ngon ngu',
                trailing: Text('Tieng Viet', style: tt.bodySmall),
                onTap: () {},
              ),
            ],
          ),
          AppSpacing.vGap24,

          // Thong bao
          _SectionTitle(title: 'Thong bao'),
          _SettingsCard(
            children: [
              _SettingsSwitch(
                icon: Icons.notifications_active,
                title: 'Thong bao push',
                value: true,
                onChanged: (v) {},
              ),
              const Divider(height: 1),
              _SettingsSwitch(
                icon: Icons.email,
                title: 'Thong bao email',
                value: false,
                onChanged: (v) {},
              ),
              const Divider(height: 1),
              _SettingsSwitch(
                icon: Icons.calendar_today,
                title: 'Nhac lich hoc',
                value: true,
                onChanged: (v) {},
              ),
            ],
          ),
          AppSpacing.vGap24,

          // Hoc tap
          _SectionTitle(title: 'Hoc tap'),
          _SettingsCard(
            children: [
              _SettingsSwitch(
                icon: Icons.play_circle,
                title: 'Tu dong phat video',
                value: false,
                onChanged: (v) {},
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.speed,
                title: 'Toc do phat mac dinh',
                trailing: Text('1.0x', style: tt.bodySmall),
                onTap: () {},
              ),
              const Divider(height: 1),
              _SettingsSwitch(
                icon: Icons.download,
                title: 'Tai xuong qua WiFi',
                value: true,
                onChanged: (v) {},
              ),
            ],
          ),
          AppSpacing.vGap24,

          // Khac
          _SectionTitle(title: 'Khac'),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.storage,
                title: 'Xoa cache',
                trailing: Text('24 MB', style: tt.bodySmall),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Da xoa cache')),
                  );
                },
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'Phien ban',
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
          color: cs.onSurface.withValues(alpha: 0.6),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
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
      leading: Icon(icon, color: cs.primary, size: 22),
      title: Text(title, style: tt.bodyMedium),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) trailing!,
          AppSpacing.hGap8,
          Icon(Icons.chevron_right, color: cs.outline, size: 20),
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
      leading: Icon(icon, color: cs.primary, size: 22),
      title: Text(title, style: tt.bodyMedium),
      trailing: Switch.adaptive(value: value, onChanged: onChanged),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final themeCubit = context.watch<ThemeCubit>();
    final isDark = themeCubit.state.themeMode == ThemeMode.dark;

    return ListTile(
      leading: Icon(
        isDark ? Icons.dark_mode : Icons.light_mode,
        color: cs.primary,
        size: 22,
      ),
      title: Text('Giao dien toi', style: tt.bodyMedium),
      trailing: Switch.adaptive(
        value: isDark,
        onChanged: (v) => themeCubit.setThemeMode(
          v ? AppThemeMode.dark : AppThemeMode.light,
        ),
      ),
    );
  }
}
