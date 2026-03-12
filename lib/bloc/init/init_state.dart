part of 'init_bloc.dart';

/// [InitBloc] states (nouns).
@immutable
abstract class InitState extends Equatable {
  const InitState();

  @override
  List<Object> get props => [];
}

/// Before app is ready.
final class InitInitial extends InitState {}

/// Ready; navigate to main.
final class InitOpenApp extends InitState {}
