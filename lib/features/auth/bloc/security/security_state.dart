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
  const SecurityLoaded({
    required this.devices,
    this.linkedAccounts = const [],
  });

  final List<DeviceModel> devices;
  final List<LinkedAccountModel> linkedAccounts;

  @override
  List<Object?> get props => [devices, linkedAccounts];
}

final class SecurityChangingPassword extends SecurityState {
  const SecurityChangingPassword({
    required this.devices,
    this.linkedAccounts = const [],
  });

  final List<DeviceModel> devices;
  final List<LinkedAccountModel> linkedAccounts;

  @override
  List<Object?> get props => [devices, linkedAccounts];
}

final class SecurityPasswordChanged extends SecurityState {
  const SecurityPasswordChanged({
    required this.devices,
    this.linkedAccounts = const [],
  });

  final List<DeviceModel> devices;
  final List<LinkedAccountModel> linkedAccounts;

  @override
  List<Object?> get props => [devices, linkedAccounts];
}

final class SecurityLoggingOutAll extends SecurityState {
  const SecurityLoggingOutAll({
    required this.devices,
    this.linkedAccounts = const [],
  });

  final List<DeviceModel> devices;
  final List<LinkedAccountModel> linkedAccounts;

  @override
  List<Object?> get props => [devices, linkedAccounts];
}

final class SecurityUnlinkingAccount extends SecurityState {
  const SecurityUnlinkingAccount({
    required this.devices,
    required this.linkedAccounts,
    required this.provider,
  });

  final List<DeviceModel> devices;
  final List<LinkedAccountModel> linkedAccounts;
  final String provider;

  @override
  List<Object?> get props => [devices, linkedAccounts, provider];
}

final class SecurityAccountUnlinked extends SecurityState {
  const SecurityAccountUnlinked({
    required this.devices,
    required this.linkedAccounts,
    required this.provider,
  });

  final List<DeviceModel> devices;
  final List<LinkedAccountModel> linkedAccounts;
  final String provider;

  @override
  List<Object?> get props => [devices, linkedAccounts, provider];
}

final class SecurityLoggedOutAll extends SecurityState {
  const SecurityLoggedOutAll();
}

final class SecurityFailure extends SecurityState {
  const SecurityFailure({
    required this.message,
    this.devices = const [],
    this.linkedAccounts = const [],
  });

  final String message;
  final List<DeviceModel> devices;
  final List<LinkedAccountModel> linkedAccounts;

  @override
  List<Object?> get props => [message, devices, linkedAccounts];
}
