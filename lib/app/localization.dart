import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show
        GlobalCupertinoLocalizations,
        GlobalMaterialLocalizations,
        GlobalWidgetsLocalizations;
import 'package:study/l10n/app_localizations.dart';

const appSupportedLocales = <Locale>[
  Locale('en', ''),
  Locale('vi', ''),
  Locale('de', ''),
  Locale('pt', ''),
  Locale('uk', ''),
];

const appLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];
