import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart' show SingleChildWidget;
import 'package:study/di/di_container.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/data/session_expired_notifier.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/repository/onboarding_repository.dart';
import 'package:study/repository/theme_repository.dart';
import 'package:study/routes/router.dart';

abstract class AppRepositoryProviders {
  static List<SingleChildWidget> providers() {
    final navigatorKey = diContainer.get<GlobalKey<NavigatorState>>();

    return [
      RepositoryProvider<NavigationService>(
        create: (context) => NavigationService(navigatorKey: navigatorKey),
      ),
      RepositoryProvider<GlobalKey<NavigatorState>>.value(value: navigatorKey),
      RepositoryProvider<AuthRepository>(
        create: (context) => diContainer.get<AuthRepository>(),
      ),
      RepositoryProvider<AuthStorage>(
        create: (context) => diContainer.get<AuthStorage>(),
      ),
      RepositoryProvider<SessionExpiredNotifier>(
        create: (context) => diContainer.get<SessionExpiredNotifier>(),
      ),
      RepositoryProvider<OnboardingRepository>(
        create: (context) => diContainer.get<OnboardingRepository>(),
      ),
      RepositoryProvider<ThemeRepository>(
        create: (context) => diContainer.get<ThemeRepository>(),
      ),
    ];
  }
}
