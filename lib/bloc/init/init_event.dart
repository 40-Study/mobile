part of 'init_bloc.dart';

/// [InitBloc] events (use past tense).
@immutable
abstract class InitEvent extends Equatable {
  const InitEvent();

  @override
  List<Object?> get props => [];
}

/// App start requested (e.g. after splash).
final class InitStarted extends InitEvent {}
