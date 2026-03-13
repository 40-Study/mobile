import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/repository/onboarding_repository.dart';

part 'init_event.dart';
part 'init_state.dart';

/// Thời gian hiển thị màn splash (loading) trước khi quyết định vào onboarding hay home.
/// Tăng nhẹ để kịp xem animation/logo.
const Duration _splashDuration = Duration(milliseconds: 2200);

/// Bật `true` để luôn hiện onboarding mỗi lần mở app (tắt logic "chỉ lần đầu").
const bool _alwaysShowOnboarding = true;

class InitBloc extends Bloc<InitEvent, InitState> {
  InitBloc(this._onboardingRepository) : super(InitInitial()) {
    on<InitStarted>(_onStarted);
  }

  final OnboardingRepository _onboardingRepository;

  Future<void> _onStarted(InitStarted event, Emitter<InitState> emit) async {
    await Future<void>.delayed(_splashDuration);
    if (_alwaysShowOnboarding) {
      emit(InitOpenOnboarding());
      return;
    }
    final seen = await _onboardingRepository.hasSeenOnboarding();
    if (seen) {
      emit(InitOpenApp());
    } else {
      emit(InitOpenOnboarding());
    }
  }
}
