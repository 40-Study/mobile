import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/presentation/learning/widgets/course_card.dart';
import 'package:study/features/student/presentation/learning/widgets/learning_cards.dart';
import 'package:study/features/student/presentation/learning/widgets/recent_learning_item.dart';

void main() {
  final sampleEnrollment = EnrollmentModel(
    id: 'enroll-1',
    courseId: 'course-1',
    userId: 'user-1',
    progressPercentage: 50.0,
    completedLessons: 2,
    totalLessons: 6,
    course: const CourseModel(
      id: 'course-1',
      title: 'Khóa học Flutter nâng cao',
      categoryName: 'Mobile',
      instructorName: 'Thầy Nam',
      totalDurationMins: 90,
    ),
  );

  final sampleEnrollmentNoInstructor = EnrollmentModel(
    id: 'enroll-2',
    courseId: 'course-2',
    userId: 'user-1',
    progressPercentage: 20.0,
    completedLessons: 1,
    totalLessons: 5,
    course: const CourseModel(
      id: 'course-2',
      title: 'Khóa học Python căn bản',
      categoryName: 'Data',
      instructorName: null,
      totalDurationMins: 60,
    ),
  );

  group('MyCourseCard Instructor Info', () {
    testWidgets('hiển thị avatar và tên giảng viên khi có thông tin',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 240,
              child: MyCourseCard(
                enrollment: sampleEnrollment,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Khóa học Flutter nâng cao'), findsOneWidget);
      expect(find.text('Thầy Nam'), findsOneWidget);
      expect(find.text('N'), findsOneWidget); // Initial của Nam
    });

    testWidgets('hiển thị Giảng viên và initial T khi instructorName là null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 240,
              child: MyCourseCard(
                enrollment: sampleEnrollmentNoInstructor,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Khóa học Python căn bản'), findsOneWidget);
      expect(find.text('Giảng viên'), findsOneWidget);
      expect(find.text('T'), findsOneWidget);
    });
  });

  group('ContinueLearningCard Instructor Info in Learning Tab', () {
    testWidgets('hiển thị tên giảng viên trong thẻ tiếp tục học',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContinueLearningCard(
              enrollment: sampleEnrollment,
              onContinue: () {},
            ),
          ),
        ),
      );

      expect(find.text('Thầy Nam'), findsOneWidget);
      expect(find.text('N'), findsOneWidget);
    });
  });

  group('CourseCard Instructor Info', () {
    testWidgets('hiển thị avatar và tên giảng viên đầy đủ', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CourseCard(
              enrollment: sampleEnrollment,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Thầy Nam'), findsOneWidget);
      expect(find.text('N'), findsOneWidget);
    });

    testWidgets('hiển thị Giảng viên khi không có tên giảng viên',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CourseCard(
              enrollment: sampleEnrollmentNoInstructor,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Giảng viên'), findsOneWidget);
      expect(find.text('T'), findsOneWidget);
    });
  });

  group('RecentLearningItem Instructor Info', () {
    testWidgets('hiển thị tên giảng viên trong dòng thông tin', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentLearningItem(
              enrollment: sampleEnrollment,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Mobile • Thầy Nam'), findsOneWidget);
    });

    testWidgets('hiển thị Giảng viên khi không có tên giảng viên',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentLearningItem(
              enrollment: sampleEnrollmentNoInstructor,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Data • Giảng viên'), findsOneWidget);
    });
  });
}
