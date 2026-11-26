import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/repository/auth_repository.dart';

class _AuthRepository extends Mock implements AuthRepository {}

const _user = UserModel(id: 'u1');
const _teacherRole = RoleModel(id: 'role-teacher', name: 'TEACHER');
const _parentProfile = ProfileModel(
  id: 'p-parent',
  systemRoleId: 'role-parent',
  roleName: 'parent',
);

void main() {
  setUpAll(() => registerFallbackValue(const AuthResponse()));

  group('AuthBloc', () {
    late _AuthRepository repo;

    setUp(() {
      repo = _AuthRepository();
      when(() => repo.clearSession()).thenAnswer((_) async {});
      when(() => repo.saveSession(any())).thenAnswer((_) async {});
    });

    blocTest<AuthBloc, AuthState>(
      'should clear session and emit AuthUnauthenticated when login response has no user',
      build: () => AuthBloc(repo),
      act: (b) => b.add(const AuthLoggedIn(AuthResponse())),
      expect: () => [isA<AuthUnauthenticated>()],
      verify: (_) => verify(() => repo.clearSession()).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'should not pick first profile when none matches active role',
      build: () {
        when(() => repo.getProfiles()).thenAnswer((_) async => [_parentProfile]);
        return AuthBloc(repo);
      },
      act: (b) => b.add(
        const AuthLoggedIn(AuthResponse(user: _user, activeRole: _teacherRole)),
      ),
      expect: () => [
        isA<AuthAuthenticated>().having((s) => s.activeProfile, 'profile', isNull),
      ],
      verify: (_) => verifyNever(() => repo.saveSession(any())),
    );

    blocTest<AuthBloc, AuthState>(
      'should use the only profile when there is no active role',
      build: () {
        when(() => repo.getProfiles()).thenAnswer((_) async => [_parentProfile]);
        return AuthBloc(repo);
      },
      act: (b) => b.add(const AuthLoggedIn(AuthResponse(user: _user))),
      expect: () => [
        isA<AuthAuthenticated>().having(
          (s) => s.activeProfile,
          'profile',
          _parentProfile,
        ),
      ],
    );
  });
}
