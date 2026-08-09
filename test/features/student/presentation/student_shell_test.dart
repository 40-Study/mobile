// test/features/student/presentation/student_shell_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/student/presentation/student_shell.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

Widget _buildShell({StudentTab initialTab = StudentTab.home}) {
  return BlocProvider<AuthBloc>(
    create: (_) => AuthBloc(_MockAuthRepository()),
    child: MaterialApp(home: StudentShell(initialTab: initialTab)),
  );
}

Future<void> _pumpShell(
  WidgetTester tester, {
  StudentTab initialTab = StudentTab.home,
}) async {
  await tester.pumpWidget(_buildShell(initialTab: initialTab));
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump();
}

void main() {
  group('StudentShell', () {
    testWidgets('should display 5 bottom navigation items', (tester) async {
      await _pumpShell(tester);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
    });

    testWidgets('should show home tab content when home is selected', (
      tester,
    ) async {
      await _pumpShell(tester);

      expect(find.text('40Study'), findsOneWidget);
      expect(find.text('Trang chủ'), findsOneWidget);
    });

    testWidgets('should switch tab khi tap navigation item', (tester) async {
      await _pumpShell(tester);

      expect(find.text('40Study'), findsOneWidget);

      await tester.tap(find.text('Học tập'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Học tập'), findsNWidgets(2));
      expect(find.text('40Study'), findsNothing);
    });

    testWidgets('should start on given initialTab', (tester) async {
      await _pumpShell(tester, initialTab: StudentTab.schedule);

      expect(find.text('Lịch học'), findsNWidgets(2));
    });

    testWidgets('should have StudentTab enum with 5 values', (tester) async {
      expect(StudentTab.values.length, 5);
      expect(StudentTab.values, contains(StudentTab.home));
      expect(StudentTab.values, contains(StudentTab.learning));
      expect(StudentTab.values, contains(StudentTab.schedule));
      expect(StudentTab.values, contains(StudentTab.achievement));
      expect(StudentTab.values, contains(StudentTab.profile));
    });
  });
}
