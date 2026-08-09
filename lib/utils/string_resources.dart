import 'package:flutter/widgets.dart';
import 'package:study/l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension StringResourcesExtension on BuildContext {
  String get appTitle => l10n.appTitle;

  String get appearanceTitle => l10n.appearanceTitle;

  String get darkThemeSettingsItemTitle => l10n.darkThemeSettingsItemTitle;

  String get darkThemeOnSettingsItemTitle => l10n.darkThemeOnSettingsItemTitle;

  String get darkThemeOffSettingsItemTitle =>
      l10n.darkThemeOffSettingsItemTitle;

  String get darkThemeFollowSystemSettingsItemTitle =>
      l10n.darkThemeFollowSystemSettingsItemTitle;

  String get settingsTitle => l10n.settingsTitle;

  String get emptyList => l10n.emptyList;

  String get tryAgainButton => l10n.tryAgainButton;

  String get aboutSettingsItem => l10n.aboutSettingsItem;

  String get languageTitle => l10n.languageTitle;
}
