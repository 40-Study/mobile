import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/auth/data/models/models.dart';

@immutable
sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded({required this.profiles});

  final List<ProfileModel> profiles;

  @override
  List<Object?> get props => [profiles];
}

final class ProfileSwitching extends ProfileState {
  const ProfileSwitching({
    required this.profiles,
    required this.switchingProfileId,
  });

  final List<ProfileModel> profiles;
  final String switchingProfileId;

  @override
  List<Object?> get props => [profiles, switchingProfileId];
}

final class ProfileSwitched extends ProfileState {
  const ProfileSwitched({
    required this.profiles,
    this.newProfile,
    this.authResponse,
  });

  final List<ProfileModel> profiles;
  final ProfileModel? newProfile;
  final AuthResponse? authResponse;

  @override
  List<Object?> get props => [profiles, newProfile, authResponse];
}

final class ProfileSwitchFailure extends ProfileState {
  const ProfileSwitchFailure({
    required this.profiles,
    required this.message,
  });

  final List<ProfileModel> profiles;
  final String message;

  @override
  List<Object?> get props => [profiles, message];
}

final class ProfileFailure extends ProfileState {
  const ProfileFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
