import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/auth/data/models/models.dart';

@immutable
sealed class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

final class AccountInitial extends AccountState {
  const AccountInitial();
}

final class AccountLoading extends AccountState {
  const AccountLoading();
}

final class AccountLoaded extends AccountState {
  const AccountLoaded({required this.user});

  final UserModel user;

  @override
  List<Object?> get props => [user];
}

final class AccountUpdating extends AccountState {
  const AccountUpdating({required this.user});

  final UserModel user;

  @override
  List<Object?> get props => [user];
}

final class AccountUpdateSuccess extends AccountState {
  const AccountUpdateSuccess({required this.user});

  final UserModel user;

  @override
  List<Object?> get props => [user];
}

final class AccountFailure extends AccountState {
  const AccountFailure({required this.message, this.user});

  final String message;
  final UserModel? user;

  @override
  List<Object?> get props => [message, user];
}
