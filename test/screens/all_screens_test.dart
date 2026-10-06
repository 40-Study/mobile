import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:study/features/student/presentation/learning/all_courses_screen.dart';
import 'package:study/features/student/presentation/learning/explore_courses_screen.dart';
import 'package:study/features/student/presentation/schedule/daily_goals_screen.dart';

import '../support/screen_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final screens = createScreenFixtures();
  setUpAll(() async {
    final font = FontLoader('Roboto')
      ..addFont(rootBundle.load('google_fonts/Roboto-Medium.ttf'));
    await font.load();
  });
  setUp(setUpScreenFixtures);
  tearDown(() async => GetIt.instance.reset());

  test('every concrete screen has a fixture', () {
    final classes = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .expand(
          (f) => RegExp(
            r'class (\w+(?:Screen|Shell)|SplashView) extends (?:StatefulWidget|StatelessWidget)',
          ).allMatches(f.readAsStringSync()).map((m) => m.group(1)!),
        )
        .toSet();
    expect(
      screens.map((w) => w.runtimeType.toString()).toSet(),
      containsAll(classes),
    );
  });

  for (final screen in screens) {
    for (final size in [const Size(390, 844), const Size(360, 800)]) {
      testWidgets(
        '${screen.runtimeType} renders and disposes at ${size.width.toInt()}px',
        (tester) async {
          await mockNetworkImagesFor(() async {
            await pumpScreenFixture(tester, screen, size: size);
            expect(find.byType(screen.runtimeType), findsOneWidget);
            expect(find.byType(Scaffold), findsWidgets);
            final exception = tester.takeException();
            expect(
              exception,
              isNull,
              reason: exception is FlutterError
                  ? exception.diagnostics
                        .map((node) => node.toString())
                        .join('\n')
                  : exception?.toString(),
            );
            await disposeScreenFixture(tester);
          });
        },
      );
    }
  }

  for (final screen in [
    const AllCoursesScreen(),
    const ExploreCoursesScreen(),
  ]) {
    testWidgets('${screen.runtimeType} receives the large benchmark dataset', (
      tester,
    ) async {
      await GetIt.instance.reset();
      await setUpScreenFixtures(itemCount: 100);
      await mockNetworkImagesFor(() async {
        await pumpScreenFixture(tester, screen);
        expect(find.text('Khóa học 0: Toán nâng cao'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await disposeScreenFixture(tester);
      });
    });
  }

  testWidgets(
    'daily goals rejects blank input, adds, completes and deletes a goal',
    (tester) async {
      await pumpScreenFixture(
        tester,
        DailyGoalsScreen(date: DateTime(2026, 9, 27)),
      );
      await tester.enterText(find.byType(TextField), '   ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.byType(Dismissible), findsNothing);
      await tester.enterText(find.byType(TextField), 'Read one lesson');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.text('Read one lesson'), findsOneWidget);
      expect(find.text('Hoàn thành 0/1'), findsOneWidget);
      await tester.tap(find.text('Read one lesson'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Hoàn thành 1/1'), findsOneWidget);
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('Read one lesson'), findsNothing);
      expect(find.text('Hoàn thành 0/0'), findsOneWidget);
      await disposeScreenFixture(tester);
    },
  );
}
