import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/presentation/home/widgets/continue_learning_card.dart';
import 'package:study/features/student/presentation/home/widgets/curved_surface_tray.dart';
import 'package:study/features/student/presentation/home/widgets/today_summary.dart';

void main() {
  group('TodaySummary Capsule Pills', () {
    testWidgets('hiển thị đầy đủ số ca học và bài tập dạng pill',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TodaySummary(
              scheduleCount: 3,
              assignmentCount: 5,
            ),
          ),
        ),
      );

      expect(find.text('3 ca học hôm nay'), findsOneWidget);
      expect(find.text('5 bài cần làm'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
      expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
    });
  });

  group('ContinueLearningCard Hybrid CTA', () {
    testWidgets('hiển thị nút CTA tròn xanh và avatar giảng viên',
        (tester) async {
      final enrollment = EnrollmentModel(
        id: 'enroll-1',
        courseId: 'course-1',
        userId: 'user-1',
        enrolledAt: DateTime(2026, 1, 1),
        progressPercentage: 45.0,
        completedLessons: 4,
        totalLessons: 10,
        course: CourseModel(
          id: 'course-1',
          title: 'Lập trình Flutter Chuyên Sâu',
          instructorName: 'Thầy Nam',
          description: 'Học Flutter thực chiến',
          categoryName: 'Mobile',
          price: 500000,
          thumbnailUrl: null,
          totalDurationMins: 120,
          totalLessons: 10,
        ),
      );

      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContinueLearningCard(
              enrollment: enrollment,
              onContinueTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('TIẾP TỤC HỌC'), findsOneWidget);
      expect(find.text('Lập trình Flutter Chuyên Sâu'), findsOneWidget);
      expect(find.text('Bài 5 • '), findsOneWidget);
      expect(find.text('Thầy Nam'), findsOneWidget);
      expect(find.text('N'), findsOneWidget); // Initial của Thầy Nam
      expect(find.text('45%'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);

      await tester.tap(find.byType(ContinueLearningCard));
      expect(tapped, isTrue);
    });
  });

  group('CurvedSurfaceTray', () {
    testWidgets('render nội dung bên trong khay bề mặt cong',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CurvedSurfaceTray(
              child: Text('Nội dung bàn làm việc'),
            ),
          ),
        ),
      );

      expect(find.text('Nội dung bàn làm việc'), findsOneWidget);
    });
  });
}
