import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart'
    show SingleChildWidget;
import 'package:study/bloc/init/init_bloc.dart';
import 'package:study/bloc/theme/theme_cubit.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:study/features/auth/bloc/login/login_bloc.dart';
import 'package:study/features/auth/bloc/register/register_bloc.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/data/device_info_helper.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/repository/onboarding_repository.dart';
import 'package:study/repository/theme_repository.dart';

import 'di_container.dart';

abstract class AppBlocProviders {
  static List<SingleChildWidget> providers() {
    final authRepo = diContainer.get<AuthRepository>();

    return [
      BlocProvider(
        create: (_) =>
            ThemeCubit(diContainer.get<ThemeRepository>())
              ..loadTheme(),
      ),
      BlocProvider<InitBloc>(
        create: (_) => InitBloc(
          onboardingRepository:
              diContainer.get<OnboardingRepository>(),
          authRepository: authRepo,
        )..add(InitStarted()),
      ),
      BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(authRepo),
      ),
      BlocProvider<LoginBloc>(
        create: (_) => LoginBloc(
          authRepository: authRepo,
          deviceInfoHelper: DeviceInfoHelper(
            diContainer.get<AuthStorage>(),
          ),
        ),
      ),
      BlocProvider<RegisterBloc>(
        create: (_) => RegisterBloc(
          authRepository: authRepo,
        ),
      ),
      BlocProvider<ForgotPasswordBloc>(
        create: (_) => ForgotPasswordBloc(
          authRepository: authRepo,
        ),
      ),
    ];
  }
}
