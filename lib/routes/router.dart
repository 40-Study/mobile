import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/index.dart';

class Routes {
  static const app = 'home';
  static const appearance = 'appearance';
  static const darkTheme = 'darkTheme';
  static const settings = 'settings';
}

/// Navigator key from DI. Use after [initDI].
GlobalKey<NavigatorState> get appNavigatorKey =>
    diContainer.get<GlobalKey<NavigatorState>>();

class NavigationService {
  final _appRoutes = {
    Routes.app: (_) => const HomeScreen(),
    Routes.appearance: (_) => const AppearanceScreen(),
    Routes.darkTheme: (_) => const DarkThemeScreen(),
    Routes.settings: (_) => const SettingsScreen(),
  };

  final Set<String> _animatedRoutes = {
    Routes.appearance,
    Routes.darkTheme,
    Routes.settings,
  };

  /// Full-screen dialog routes (iOS style; no effect on Android).
  final Set<String> _fullScreenRoutes = {};

  /// Routes with slide-from-right transition (Cupertino).
  final Set<String> _cupertinoRoutes = {};

  static NavigationService of(BuildContext context) =>
      RepositoryProvider.of<NavigationService>(context);

  Future<dynamic> navigateTo(
    String routeName, [
    Object? arguments,
    bool replace = false,
  ]) async {
    if (_appRoutes[routeName] != null) {
      return replace
          ? appNavigatorKey.currentState
              ?.pushReplacementNamed(routeName, arguments: arguments)
          : appNavigatorKey.currentState?.pushNamed(
              routeName,
              arguments: arguments,
            );
    }
  }

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = _appRoutes[settings.name];
    if (builder == null) {
      return MaterialPageRoute(builder: (_) => const SplashView());
    }

    final isFullScreen = _fullScreenRoutes.contains(settings.name);
    final isCupertino = _cupertinoRoutes.contains(settings.name);
    final isAnimated = _animatedRoutes.contains(settings.name);

    if (isAnimated) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(settings.arguments),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      );
    }

    if (isCupertino) {
      return CupertinoPageRoute(
        settings: settings,
        builder: (_) => builder(settings.arguments),
        fullscreenDialog: isFullScreen,
      );
    }

    return MaterialPageRoute(
      settings: settings,
      builder: (_) => builder(settings.arguments),
      fullscreenDialog: isFullScreen,
    );
  }

  Future<dynamic> pushAndRemoveAll(
    String routeName, [
    Object? arguments,
  ]) async {
    return appNavigatorKey.currentState
        ?.pushNamedAndRemoveUntil(routeName, (route) => false);
  }
}
