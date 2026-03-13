import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/app/localization.dart';
import 'package:study/bloc/init/init_bloc.dart';
import 'package:study/di/app_bloc_providers.dart';
import 'package:study/di/app_repository_providers.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/data/session_expired_notifier.dart';
import 'package:study/index.dart';
import 'package:study/theme/util.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  StreamSubscription<void>? _sessionSub;

  @override
  void dispose() {
    _sessionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
        providers: [...AppRepositoryProviders.providers()],
        child: MultiBlocProvider(
          providers: [...AppBlocProviders.providers()],
          child: Builder(
            builder: (context) {
              _listenSessionExpired(context);

              final navigator = NavigationService.of(context);
              var textTheme =
                  createTextTheme(context: context);
              var theme = MaterialTheme(textTheme);

              return MaterialApp(
                debugShowCheckedModeBanner: kDebugMode,
                restorationScopeId: 'app',
                key: Key(
                  '${context.watch<ThemeCubit>().themeMode}',
                ),
                localizationsDelegates:
                    appLocalizationsDelegates,
                supportedLocales: appSupportedLocales,
                onGenerateTitle: (BuildContext context) =>
                    context.appTitle,
                theme: theme.yellowLight(),
                darkTheme: theme.yellowDark(),
                themeMode:
                    context.watch<ThemeCubit>().themeMode,
                navigatorKey: appNavigatorKey,
                onGenerateRoute: navigator.onGenerateRoute,
                builder: (_, child) => MultiBlocListener(
                  listeners: [
                    BlocListener<InitBloc, InitState>(
                      listener: (_, state) {
                        if (state is InitOpenApp) {
                          navigator
                              .pushAndRemoveAll(Routes.app);
                        } else if (state
                            is InitOpenOnboarding) {
                          navigator.pushAndRemoveAll(
                            Routes.onboarding,
                          );
                        } else if (state is InitOpenLogin) {
                          navigator.pushAndRemoveAll(
                            Routes.login,
                          );
                        }
                      },
                    ),
                    BlocListener<AuthBloc, AuthState>(
                      listenWhen: (prev, curr) =>
                          prev is! AuthUnauthenticated &&
                          curr is AuthUnauthenticated,
                      listener: (_, state) {
                        if (state is AuthUnauthenticated) {
                          navigator.pushAndRemoveAll(
                            Routes.login,
                          );
                        }
                      },
                    ),
                  ],
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
          ),
        ),
      );

  /// Khi interceptor phát hiện session hết hạn,
  /// dispatch event vào AuthBloc để xử lý.
  void _listenSessionExpired(BuildContext context) {
    if (_sessionSub != null) return;
    _sessionSub = diContainer
        .get<SessionExpiredNotifier>()
        .stream
        .listen((_) {
      context.read<AuthBloc>().add(AuthSessionExpired());
    });
  }
}
