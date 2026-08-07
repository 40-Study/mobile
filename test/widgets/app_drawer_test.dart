// test/widgets/app_drawer_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/widgets/app_drawer.dart';

void main() {
  group('AppDrawer', () {
    testWidgets('should display user header with name and email', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(
              userName: 'Nguyen Van A',
              userEmail: 'test@email.com',
              onNotificationsTap: () {},
              onBookmarksTap: () {},
              onSearchTap: () {},
              onSettingsTap: () {},
              onHelpTap: () {},
              onLogoutTap: () {},
            ),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Nguyen Van A'), findsOneWidget);
      expect(find.text('test@email.com'), findsOneWidget);
    });

    testWidgets('should display all menu items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(
              userName: 'Test',
              userEmail: 'test@email.com',
              onNotificationsTap: () {},
              onBookmarksTap: () {},
              onSearchTap: () {},
              onSettingsTap: () {},
              onHelpTap: () {},
              onLogoutTap: () {},
            ),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Thong bao'), findsOneWidget);
      expect(find.text('Da luu'), findsOneWidget);
      expect(find.text('Tim kiem'), findsOneWidget);
      expect(find.text('Cai dat'), findsOneWidget);
      expect(find.text('Tro giup'), findsOneWidget);
      expect(find.text('Dang xuat'), findsOneWidget);
    });
  });
}
