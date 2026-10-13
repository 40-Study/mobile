import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/student/presentation/learning/lesson_detail/widgets/lesson_bottom_bar.dart';
import 'package:study/features/student/presentation/learning/widgets/section/section_widgets.dart';

void main() {
  group('Course & Lesson Flow Widgets Test', () {
    testWidgets('LessonBottomBar renders correctly at first lesson', (tester) async {
      bool nextPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: LessonBottomBar(
              currentIndex: 0,
              totalLessons: 4,
              onPrevious: null,
              onNext: () {
                nextPressed = true;
              },
            ),
          ),
        ),
      );

      // Verify page indicator
      expect(find.text('1/4'), findsOneWidget);
      expect(find.text('Bài học'), findsOneWidget);

      // Verify Next button exists and works
      expect(find.text('Bài tiếp theo'), findsOneWidget);
      await tester.tap(find.text('Bài tiếp theo'));
      expect(nextPressed, isTrue);
    });

    testWidgets('LessonBottomBar renders correctly in middle lesson', (tester) async {
      bool prevPressed = false;
      bool nextPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: LessonBottomBar(
              currentIndex: 1,
              totalLessons: 4,
              onPrevious: () {
                prevPressed = true;
              },
              onNext: () {
                nextPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('2/4'), findsOneWidget);
      expect(find.text('Bài trước'), findsOneWidget);
      expect(find.text('Bài tiếp theo'), findsOneWidget);

      await tester.tap(find.text('Bài trước'));
      expect(prevPressed, isTrue);

      await tester.tap(find.text('Bài tiếp theo'));
      expect(nextPressed, isTrue);
    });

    testWidgets('LessonStatusIcon shows correct icons for states', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                LessonStatusIcon(isCompleted: true, isInProgress: false),
                LessonStatusIcon(isCompleted: false, isInProgress: false, isLocked: true),
                LessonStatusIcon(isCompleted: false, isInProgress: true),
                LessonStatusIcon(isCompleted: false, isInProgress: false),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNWidgets(2));
    });
  });
}
