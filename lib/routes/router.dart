import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/durations.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/forgot_password_otp_screen.dart';
import 'package:study/features/auth/presentation/forgot_password_screen.dart';
import 'package:study/features/auth/presentation/login_role_picker_screen.dart';
import 'package:study/features/auth/presentation/login_screen.dart';
import 'package:study/features/auth/presentation/register_form_screen.dart';
import 'package:study/features/auth/presentation/register_otp_screen.dart';
import 'package:study/features/auth/presentation/reset_password_screen.dart';
import 'package:study/features/auth/presentation/select_role_screen.dart';
import 'package:study/features/main_screen.dart';
import 'package:study/features/onboarding/onboarding_screen.dart';
import 'package:study/features/splash_view.dart';

class Routes {
  static const app = 'home';
  static const onboarding = 'onboarding';

  // Auth
  static const login = 'login';
  static const loginRolePicker = 'loginRolePicker';
  static const selectRole = 'selectRole';
  static const registerForm = 'registerForm';
  static const registerOtp = 'registerOtp';
  static const forgotPassword = 'forgotPassword';
  static const forgotPasswordOtp = 'forgotPasswordOtp';
  static const resetPassword = 'resetPassword';
}

class NavigationService {
  NavigationService({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  final _appRoutes = {
    Routes.app: (_) => const MainScreen(),
    Routes.onboarding: (_) => const OnboardingScreen(),
    Routes.login: (_) => const LoginScreen(),
    Routes.loginRolePicker: (Object? args) {
      final data = args as Map<String, dynamic>;
      return LoginRolePickerScreen(
        sessionToken: data['sessionToken'] as String,
        roles: data['roles'] as List<RoleModel>,
      );
    },
    Routes.selectRole: (_) => const SelectRoleScreen(),
    Routes.registerForm: (_) => const RegisterFormScreen(),
    Routes.registerOtp: (_) => const RegisterOtpScreen(),
    Routes.forgotPassword: (_) => const ForgotPasswordScreen(),
    Routes.forgotPasswordOtp: (_) => const ForgotPasswordOtpScreen(),
    Routes.resetPassword: (_) => const ResetPasswordScreen(),
  };

  final Set<String> _animatedRoutes = {
    Routes.loginRolePicker,
    Routes.selectRole,
    Routes.registerForm,
    Routes.registerOtp,
    Routes.forgotPassword,
    Routes.forgotPasswordOtp,
    Routes.resetPassword,
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
          ? navigatorKey.currentState?.pushReplacementNamed(
              routeName,
              arguments: arguments,
            )
          : navigatorKey.currentState?.pushNamed(
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

          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: AppDurations.pageTransition,
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
    return navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
    );
  }
}
