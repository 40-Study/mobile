import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

enum AuthScreenAnimStatus {
  initial,
  animatingIn,
  ready,
  submitting,
  success,
  error,
  animatingOut,
}

class AuthAnimationState extends Equatable {
  const AuthAnimationState({
    required this.status,
    this.hasPlayedEntrance = false,
  });

  final AuthScreenAnimStatus status;
  final bool hasPlayedEntrance;

  bool get shouldAnimate => !hasPlayedEntrance;

  AuthAnimationState copyWith({
    AuthScreenAnimStatus? status,
    bool? hasPlayedEntrance,
  }) {
    return AuthAnimationState(
      status: status ?? this.status,
      hasPlayedEntrance: hasPlayedEntrance ?? this.hasPlayedEntrance,
    );
  }

  @override
  List<Object?> get props => [status, hasPlayedEntrance];
}

/// Orchestrates animation state for auth screens.
/// Separated from business blocs so animation logic doesn't pollute domain.
class AuthAnimationCubit extends Cubit<AuthAnimationState> {
  AuthAnimationCubit()
    : super(const AuthAnimationState(status: AuthScreenAnimStatus.initial));

  void startEntrance() {
    if (state.hasPlayedEntrance) {
      emit(state.copyWith(status: AuthScreenAnimStatus.ready));
      return;
    }
    emit(state.copyWith(status: AuthScreenAnimStatus.animatingIn));
  }

  void entranceComplete() {
    emit(
      state.copyWith(
        status: AuthScreenAnimStatus.ready,
        hasPlayedEntrance: true,
      ),
    );
  }

  void submit() {
    emit(state.copyWith(status: AuthScreenAnimStatus.submitting));
  }

  void succeed() {
    emit(state.copyWith(status: AuthScreenAnimStatus.success));
  }

  void fail() {
    emit(state.copyWith(status: AuthScreenAnimStatus.error));
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (!isClosed) {
        emit(state.copyWith(status: AuthScreenAnimStatus.ready));
      }
    });
  }

  void animateOut() {
    emit(state.copyWith(status: AuthScreenAnimStatus.animatingOut));
  }
}
