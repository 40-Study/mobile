import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/student/bloc/learning/learning_bloc.dart';
import 'package:study/features/student/bloc/learning/learning_event.dart';
import 'package:study/features/student/bloc/learning/learning_state.dart';
import 'package:study/features/student/presentation/learning/explore_courses_screen.dart';

class MockLearningBloc extends MockBloc<LearningEvent, LearningState>
    implements LearningBloc {}

void main() {
  late MockLearningBloc mockLearningBloc;

  final testCourses = [
    const CourseModel(
      id: 'course_1',
      title: 'Khóa học Flutter Toàn Diện',
      categoryName: 'Lập trình',
      instructorName: 'Nguyễn Văn A',
      price: 299000,
      isFree: false,
      averageRating: 4.8,
      totalRatings: 120,
      totalStudents: 1540,
      totalLessons: 32,
      level: 'beginner',
    ),
    const CourseModel(
      id: 'course_2',
      title: 'Thiết kế UI/UX Chuyên Nghiệp',
      categoryName: 'Thiết kế',
      instructorName: 'Trần Thị B',
      price: 0,
      isFree: true,
      averageRating: 4.9,
      totalRatings: 95,
      totalStudents: 2100,
      totalLessons: 18,
      level: 'intermediate',
    ),
    const CourseModel(
      id: 'course_3',
      title: 'Lập trình Backend Golang',
      categoryName: 'Lập trình',
      instructorName: 'Lê Văn C',
      price: 450000,
      isFree: false,
      averageRating: 4.7,
      totalRatings: 60,
      totalStudents: 800,
      totalLessons: 40,
      level: 'advanced',
    ),
  ];

  setUp(() {
    mockLearningBloc = MockLearningBloc();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<LearningBloc>.value(
        value: mockLearningBloc,
        child: const ExploreCoursesScreen(),
      ),
    );
  }

  group('ExploreCoursesScreen Discovery Hub Tests', () {
    testWidgets('renders search bar, category chips, sort bar and courses', (
      tester,
    ) async {
      when(
        () => mockLearningBloc.state,
      ).thenReturn(LearningSuccess(recommendedCourses: testCourses));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify app bar title
      expect(find.text('Khám phá khóa học'), findsOneWidget);

      // Verify search bar
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Tìm khóa học, giảng viên, kỹ năng...'), findsOneWidget);

      // Verify category chips
      expect(find.text('Tất cả'), findsWidgets);
      expect(find.text('Lập trình'), findsWidgets);
      expect(find.text('Thiết kế'), findsWidgets);

      // Verify price filter pills
      expect(find.text('🎁 Miễn phí'), findsOneWidget);
      expect(find.text('💳 Có phí'), findsOneWidget);

      // Verify Spotlight banner is displayed (for first course)
      expect(find.text('KHÓA HỌC NỔI BẬT'), findsOneWidget);

      // Verify course titles
      expect(find.text('Khóa học Flutter Toàn Diện'), findsWidgets);
      await tester.scrollUntilVisible(
        find.text('Lập trình Backend Golang'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Lập trình Backend Golang'), findsOneWidget);
    });

    testWidgets(
      'filtering by search query updates list and hides spotlight banner',
      (tester) async {
        when(
          () => mockLearningBloc.state,
        ).thenReturn(LearningSuccess(recommendedCourses: testCourses));

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Enter search query
        await tester.enterText(find.byType(TextField), 'Golang');
        await tester.pumpAndSettle();

        // Only Golang should be shown
        expect(find.text('Lập trình Backend Golang'), findsOneWidget);
        expect(find.text('Khóa học Flutter Toàn Diện'), findsNothing);
        expect(find.text('Thiết kế UI/UX Chuyên Nghiệp'), findsNothing);

        // Spotlight banner must be hidden when querying
        expect(find.text('KHÓA HỌC NỔI BẬT'), findsNothing);

        // Clear button should be visible
        expect(find.byIcon(Icons.close_rounded), findsOneWidget);
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();

        // All courses restored
        expect(find.text('Khóa học Flutter Toàn Diện'), findsWidgets);
      },
    );

    testWidgets('filtering by price pill filters free and paid courses', (
      tester,
    ) async {
      when(
        () => mockLearningBloc.state,
      ).thenReturn(LearningSuccess(recommendedCourses: testCourses));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap on '🎁 Miễn phí'
      await tester.tap(find.text('🎁 Miễn phí'));
      await tester.pumpAndSettle();

      // Only free course should be visible
      expect(find.text('Thiết kế UI/UX Chuyên Nghiệp'), findsOneWidget);
      expect(find.text('Khóa học Flutter Toàn Diện'), findsNothing);
      expect(find.text('Lập trình Backend Golang'), findsNothing);
    });

    testWidgets('shows empty state with reset button when no courses match', (
      tester,
    ) async {
      when(
        () => mockLearningBloc.state,
      ).thenReturn(LearningSuccess(recommendedCourses: testCourses));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Search for something non-existent
      await tester.enterText(find.byType(TextField), 'xyznonexistent123');
      await tester.pumpAndSettle();

      // Empty state
      expect(find.text('Không tìm thấy khóa học phù hợp'), findsOneWidget);
      expect(find.text('Đặt lại bộ lọc'), findsOneWidget);

      // Tap reset
      await tester.tap(find.text('Đặt lại bộ lọc'));
      await tester.pumpAndSettle();

      // Restored
      expect(find.text('Khóa học Flutter Toàn Diện'), findsWidgets);
    });

    testWidgets('bookmark button toggles state between outline and filled', (
      tester,
    ) async {
      when(
        () => mockLearningBloc.state,
      ).thenReturn(LearningSuccess(recommendedCourses: testCourses));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Find first unbookmarked icon
      final initialBookmark = find.byIcon(Icons.bookmark_border_rounded).first;
      expect(initialBookmark, findsOneWidget);

      // Tap bookmark
      await tester.tap(initialBookmark);
      await tester.pumpAndSettle();

      // Verify toggled to filled bookmark icon
      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);

      // Tap again to untoggle
      await tester.tap(find.byIcon(Icons.bookmark_rounded));
      await tester.pumpAndSettle();

      // Verify toggled back
      expect(find.byIcon(Icons.bookmark_rounded), findsNothing);
      expect(find.byIcon(Icons.bookmark_border_rounded), findsWidgets);
    });
  });
}
