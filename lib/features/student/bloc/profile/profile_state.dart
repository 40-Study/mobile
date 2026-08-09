import 'package:equatable/equatable.dart';
import 'package:study/features/auth/data/models/user_model.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileInProgress extends ProfileState {
  const ProfileInProgress();
}

final class ProfileSuccess extends ProfileState {
  const ProfileSuccess({required this.user});

  final UserModel user;

  @override
  List<Object?> get props => [user];
}

final class ProfileFailure extends ProfileState {
  const ProfileFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ProfileLoggedOut extends ProfileState {
  const ProfileLoggedOut();
}
