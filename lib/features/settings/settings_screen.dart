import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/bloc/theme/app_theme.dart';
import 'package:study/generated/l10n.dart';
import 'package:study/index.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).settingsTitle)),
      body: ListView(
        children: <Widget>[
          BlocConsumer<ThemeCubit, AppThemeSettings>(
            builder: (context, state) => SettingCell.icon(
              icon: AppIcons.settingsTheme,
              title: S.of(context).themeTitle,
              onTap: () async => showBottomSheetDialog(
                context: context,
                padding: EdgeInsets.zero,
                children: [
                  ThemeDialogCell<AppThemeSettings>(
                    title: S.of(context).lightThemeTitle,
                    groupValue: state,
                    value: AppThemeSettings(
                      darkTheme: DarkThemePreference(
                        darkThemeValue: DarkThemePreference.off,
                      ),
                      appTheme: AppTheme.light,
                    ),
                    onChanged: (value) => updateTheme(context, value),
                  ),
                  ThemeDialogCell<AppThemeSettings>(
                    title: S.of(context).darkThemeTitle,
                    groupValue: state,
                    value: AppThemeSettings(
                      darkTheme: DarkThemePreference(
                        darkThemeValue: DarkThemePreference.on,
                      ),
                      appTheme: AppTheme.dark,
                    ),
                    onChanged: (value) => updateTheme(context, value),
                  ),
                  ThemeDialogCell<AppThemeSettings>(
                    title: S.of(context).systemThemeTitle,
                    groupValue: state,
                    value: AppThemeSettings(
                      darkTheme: DarkThemePreference(
                        darkThemeValue: DarkThemePreference.followSystem,
                      ),
                      appTheme: AppTheme.system,
                    ),
                    onChanged: (value) => updateTheme(context, value),
                  ),
                ],
              ),
            ),
            listener: (context, state) {},
          ),
          SettingItem(
            key: const Key('appearance'),
            title: context.appearanceSettingsItem,
            description: context.appearanceSettingsItemDescription,
            icon: Icons.color_lens_outlined,
            onClick: () {
              NavigationService.of(context).navigateTo(Routes.appearance);
            },
          ),
          SettingItem(
            key: const Key('about'),
            title: context.aboutSettingsItem,
            description: context.aboutSettingsItemDescription,
            icon: Icons.info_outline,
            onClick: () {},
          ),
        ],
      ),
    );
  }

  void updateTheme(BuildContext context, AppThemeSettings value) =>
      context.read<ThemeCubit>().updateTheme(value);
}
