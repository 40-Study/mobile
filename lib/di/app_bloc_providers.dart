import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart' show SingleChildWidget;
import 'package:study/bloc/init/init_bloc.dart';
import 'package:study/bloc/theme/theme_cubit.dart';
import 'package:study/config/app_config.dart';
import 'package:study/config/environment.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/repository/onboarding_repository.dart';
import 'package:study/repository/theme_repository.dart';

abstract class AppBlocProviders {
  static List<SingleChildWidget> providers() {
    return [
      BlocProvider(
        create: (context) =>
            ThemeCubit(context.read<ThemeRepository>())..loadTheme(),
      ),
      BlocProvider<InitBloc>(
        create: (context) => InitBloc(
          onboardingRepository: context.read<OnboardingRepository>(),
          authRepository: context.read<AuthRepository>(),
          appConfig: Environment<AppConfig>.instance().config,
        )..add(InitStarted()),
      ),
      BlocProvider<AuthBloc>(
        create: (context) =>
            AuthBloc(context.read<AuthRepository>())..add(AuthStarted()),
      ),
    ];
  }
}
