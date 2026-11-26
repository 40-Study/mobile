import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/main_screen.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  setUpAll(() => registerFallbackValue(AuthLoggedOut()));

  group('MainScreen', () {
    late _MockAuthBloc bloc;

    Future<void> pump(WidgetTester tester, AuthState state) async {
      whenListen(bloc, const Stream<AuthState>.empty(), initialState: state);
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: bloc,
            child: const MainScreen(),
          ),
        ),
      );
    }

    setUp(() => bloc = _MockAuthBloc());

    testWidgets('should show logout recovery when profile is null', (tester) async {
      await pump(tester, const AuthAuthenticated(user: UserModel(id: 'u1')));

      expect(find.text('Đăng xuất'), findsOneWidget);
      await tester.tap(find.text('Đăng xuất'));
      verify(() => bloc.add(any(that: isA<AuthLoggedOut>()))).called(1);
    });

    testWidgets('should show logout recovery when role is unknown', (tester) async {
      await pump(
        tester,
        const AuthAuthenticated(
          user: UserModel(id: 'u1'),
          activeProfile: ProfileModel(id: 'p', roleName: 'admin'),
        ),
      );

      expect(find.text('Không xác định được vai trò của tài khoản.'), findsOneWidget);
    });
  });
}
