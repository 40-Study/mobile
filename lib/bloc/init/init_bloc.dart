import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/repository/onboarding_repository.dart';

part 'init_event.dart';
part 'init_state.dart';

const Duration _splashDuration =
    Duration(milliseconds: 2200);
// TODO: Đổi về false khi không cần test onboarding
const bool _alwaysShowOnboarding = true;

class InitBloc extends Bloc<InitEvent, InitState> {
  InitBloc({
    required OnboardingRepository onboardingRepository,
    required AuthRepository authRepository,
  })  : _onboardingRepository = onboardingRepository,
        _authRepository = authRepository,
        super(InitInitial()) {
    on<InitStarted>(_onStarted);
  }

  final OnboardingRepository _onboardingRepository;
  // ignore: unused_field
  final AuthRepository _authRepository;

  Future<void> _onStarted(
    InitStarted event,
    Emitter<InitState> emit,
  ) async {
    await Future<void>.delayed(_splashDuration);

    if (_alwaysShowOnboarding) {
      emit(InitOpenOnboarding());
      return;
    }

    final seen = await _onboardingRepository
        .hasSeenOnboarding();
    if (!seen) {
      emit(InitOpenOnboarding());
      return;
    }

    // TODO: Bật lại khi test API
    // final loggedIn =
    //     await _authRepository.isLoggedIn();
    // if (loggedIn) {
    //   emit(InitOpenApp());
    // } else {
    //   emit(InitOpenLogin());
    // }

    // Giả lập: luôn mở login
    emit(InitOpenLogin());
  }
}
