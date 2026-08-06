import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:study/config/app_config.dart';
import 'package:study/constants/durations.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/repository/onboarding_repository.dart';

part 'init_event.dart';
part 'init_state.dart';

class InitBloc extends Bloc<InitEvent, InitState> {
  InitBloc({
    required OnboardingRepository onboardingRepository,
    required AuthRepository authRepository,
    required AppConfig appConfig,
  }) : _onboardingRepository = onboardingRepository,
       _authRepository = authRepository,
       _appConfig = appConfig,
       super(InitInitial()) {
    on<InitStarted>(_onStarted);
  }

  final OnboardingRepository _onboardingRepository;
  final AuthRepository _authRepository;
  final AppConfig _appConfig;

  Future<void> _onStarted(InitStarted event, Emitter<InitState> emit) async {
    await Future<void>.delayed(AppDurations.splash);

    if (_appConfig.forceShowOnboarding) {
      emit(InitOpenOnboarding());
      return;
    }

    final seen = await _onboardingRepository.hasSeenOnboarding();
    if (!seen) {
      emit(InitOpenOnboarding());
      return;
    }

    final loggedIn = await _authRepository.isLoggedIn();
    if (loggedIn) {
      emit(InitOpenApp());
    } else {
      emit(InitOpenLogin());
    }
  }
}
