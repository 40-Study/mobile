import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:study/features/teacher/data/teacher_preview_api.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_schedule_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Teacher can navigate out of empty weeks on a phone', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherScheduleScreen(
          api: TeacherPreviewApi(),
          organizationId: null,
          workplaceLabel: 'Cá nhân',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final previous = find.byKey(const ValueKey('teacher-calendar-previous'));
    final next = find.byKey(const ValueKey('teacher-calendar-next'));
    for (final arrow in [next, previous, previous]) {
      await tester.tap(arrow);
      await tester.pumpAndSettle();
      expect(previous, findsOneWidget);
      expect(next, findsOneWidget);
    }
    expect(find.text('Không có buổi dạy trong tuần này.'), findsOneWidget);
    await tester.tap(find.text('Hôm nay').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('3 buổi dạy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
