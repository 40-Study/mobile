part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.user,
    this.activeProfile,
  });

  final UserModel user;
  final ProfileModel? activeProfile;

  /// Returns the role name of active profile (e.g., 'TEACHER', 'STUDENT').
  String? get roleName => activeProfile?.roleName.toUpperCase();

  /// Check if current user is a teacher.
  bool get isTeacher => roleName?.contains('TEACHER') ?? false;

  /// Check if current user is a student.
  bool get isStudent => roleName?.contains('STUDENT') ?? false;

  /// Check if current user is a parent.
  bool get isParent => roleName?.contains('PARENT') ?? false;

  /// Check if current user is an organization owner.
  bool get isOrganizationOwner =>
      roleName?.contains('OWNER') == true ||
      roleName?.contains('ORG') == true;

  @override
  List<Object?> get props => [user, activeProfile];
}

final class AuthUnauthenticated extends AuthState {}
