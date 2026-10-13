import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/student/presentation/learning/instructor_detail_screen.dart';
import 'package:study/features/student/presentation/learning/widgets/instructor_course_card.dart';
import 'package:study/features/student/presentation/learning/widgets/instructor_skill_chip.dart';

void main() {
  group('InstructorDetailScreen & Widgets Test', () {
    testWidgets('InstructorDetailScreen displays full instructor profile', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InstructorDetailScreen(
            instructorId: 'inst_1',
            instructorName: 'ThS. Nguyễn Văn A',
            instructorTitle: 'Chuyên gia Thiết kế UI/UX',
          ),
        ),
      );

      // Verify header and title
      expect(find.text('Hồ sơ giảng viên'), findsOneWidget);
      expect(find.text('ThS. Nguyễn Văn A'), findsOneWidget);
      expect(find.text('Chuyên gia Thiết kế UI/UX'), findsOneWidget);

      // Verify stats
      expect(find.text('Khóa học'), findsWidgets);
      expect(find.text('Học viên'), findsOneWidget);
      expect(find.text('Đánh giá'), findsOneWidget);

      // Verify course section and CTA button
      expect(find.text('Khóa học của giảng viên'), findsOneWidget);
      expect(find.text('Nhắn tin cho giảng viên'), findsOneWidget);
    });

    testWidgets('InstructorCourseCard displays course info and enrolled badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InstructorCourseCard(
              title: 'Lập trình Flutter cơ bản',
              lessonCount: 20,
              duration: '10h 30m',
              progress: 0.5,
              isEnrolled: true,
            ),
          ),
        ),
      );

      expect(find.text('Lập trình Flutter cơ bản'), findsOneWidget);
      expect(find.text('20 bài'), findsOneWidget);
      expect(find.text('10h 30m'), findsOneWidget);
      expect(find.text('Đang học'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('InstructorSkillChip renders label and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InstructorSkillChip(
              icon: Icons.code_rounded,
              label: 'Flutter Development',
            ),
          ),
        ),
      );

      expect(find.text('Flutter Development'), findsOneWidget);
      expect(find.byIcon(Icons.code_rounded), findsOneWidget);
    });
  });
}
