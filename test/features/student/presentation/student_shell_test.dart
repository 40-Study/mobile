// test/features/student/presentation/student_shell_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/student/presentation/student_shell.dart';

void main() {
  group('StudentShell', () {
    testWidgets('should display 5 bottom navigation items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentShell(initialTab: StudentTab.home),
        ),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
    });

    testWidgets('should show home tab content when home is selected',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentShell(initialTab: StudentTab.home),
        ),
      );

      // Body placeholder cho home tab
      expect(find.text('Trang chu'), findsOneWidget);
    });

    testWidgets('should switch tab khi tap navigation item', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentShell(initialTab: StudentTab.home),
        ),
      );

      // Ban dau hien home
      expect(find.text('Trang chu'), findsOneWidget);

      // Tap sang tab Hoc tap (label tren nav bar)
      await tester.tap(find.text('Hoc tap').first);
      await tester.pumpAndSettle();

      // Body doi sang Hoc tap (2 text: 1 body + 1 nav label)
      expect(find.text('Hoc tap'), findsAtLeastNWidgets(1));
      expect(find.text('Trang chu'), findsNothing);
    });

    testWidgets('should start on given initialTab', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentShell(initialTab: StudentTab.schedule),
        ),
      );

      // Body placeholder cho schedule tab
      expect(find.text('Lich hoc'), findsAtLeastNWidgets(1));
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
