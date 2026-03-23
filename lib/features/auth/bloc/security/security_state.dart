import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/auth/data/models/models.dart';

@immutable
sealed class SecurityState extends Equatable {
  const SecurityState();

  @override
  List<Object?> get props => [];
}

final class SecurityInitial extends SecurityState {
  const SecurityInitial();
}

final class SecurityLoading extends SecurityState {
  const SecurityLoading();
}

final class SecurityLoaded extends SecurityState {
  const SecurityLoaded({required this.devices});

  final List<DeviceModel> devices;

  @override
  List<Object?> get props => [devices];
}

final class SecurityChangingPassword extends SecurityState {
  const SecurityChangingPassword({required this.devices});

  final List<DeviceModel> devices;

  @override
  List<Object?> get props => [devices];
}

final class SecurityPasswordChanged extends SecurityState {
  const SecurityPasswordChanged({required this.devices});

  final List<DeviceModel> devices;

  @override
  List<Object?> get props => [devices];
}

final class SecurityLoggingOutAll extends SecurityState {
  const SecurityLoggingOutAll({required this.devices});

  final List<DeviceModel> devices;

  @override
  List<Object?> get props => [devices];
}

final class SecurityLoggedOutAll extends SecurityState {
  const SecurityLoggedOutAll();
}

final class SecurityFailure extends SecurityState {
  const SecurityFailure({required this.message, this.devices = const []});

  final String message;
  final List<DeviceModel> devices;

  @override
  List<Object?> get props => [message, devices];
}
