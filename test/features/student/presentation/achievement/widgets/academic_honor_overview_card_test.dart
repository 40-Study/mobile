import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/student/data/models/student_stats_model.dart';
import 'package:study/features/student/presentation/achievement/widgets/academic_honor_overview_card.dart';
import 'package:study/features/student/presentation/achievement/widgets/overview_statistics.dart';

void main() {
  group('AcademicHonorOverviewCard & OverviewStatistics Test Suite', () {
    testWidgets('renders correctly with default stats and level 1 title', (tester) async {
      const stats = StudentStatsModel(
        level: 1,
        currentXp: 350,
        nextLevelXp: 500,
        streakDays: 7,
        totalStudyMinutes: 240, // 4 hours
        completedLessons: 12,
        totalLessons: 20,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AcademicHonorOverviewCard(
              stats: stats,
              earnedBadgesCount: 3,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tầng 1: Vị thế & Tiến trình
      expect(find.text('Tân Khoa Nhập Môn'), findsOneWidget);
      expect(find.text('Tín chỉ tích lũy: 350 XP'), findsOneWidget);
      expect(find.text('CẤP ĐỘ 1'), findsOneWidget);
      expect(find.text('Tiến trình lên Cấp 2'), findsOneWidget);
      expect(find.text('150 XP nữa • 70%'), findsOneWidget);

      // Tầng 2: 4 Micro Pods
      expect(find.text('7'), findsOneWidget); // Streak
      expect(find.text('4'), findsOneWidget); // Study hours (240 / 60)
      expect(find.text('12'), findsOneWidget); // Completed lessons
      expect(find.text('3'), findsOneWidget); // Badges earned (not hardcoded 18!)
    });

    testWidgets('AcademicHonorOverviewCard renders level 2 properly', (tester) async {
      const stats = StudentStatsModel(
        level: 2,
        currentXp: 800,
        nextLevelXp: 1000,
        streakDays: 14,
        totalStudyMinutes: 480, // 8 hours
        completedLessons: 18,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AcademicHonorOverviewCard(
              stats: stats,
              earnedBadgesCount: 6,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tân Khoa Nhập Môn'), findsOneWidget);
      expect(find.text('CẤP ĐỘ 2'), findsOneWidget);
      expect(find.text('8'), findsOneWidget); // Study hours
      expect(find.text('6'), findsOneWidget); // Badges count
    });

    testWidgets('dynamic academic titles resolve properly across levels', (tester) async {
      expect(AcademicHonorOverviewCard.resolveAcademicTitle(1), 'Tân Khoa Nhập Môn');
      expect(AcademicHonorOverviewCard.resolveAcademicTitle(2), 'Tân Khoa Nhập Môn');
      expect(AcademicHonorOverviewCard.resolveAcademicTitle(3), 'Học Giả Tiến Bộ');
      expect(AcademicHonorOverviewCard.resolveAcademicTitle(4), 'Học Giả Tiến Bộ');
      expect(AcademicHonorOverviewCard.resolveAcademicTitle(5), 'Học Giả Tinh Hoa');
      expect(AcademicHonorOverviewCard.resolveAcademicTitle(6), 'Học Giả Tinh Hoa');
      expect(AcademicHonorOverviewCard.resolveAcademicTitle(7), 'Học Viện Danh Dự');
      expect(AcademicHonorOverviewCard.resolveAcademicTitle(8), 'Học Viện Danh Dự');
      expect(AcademicHonorOverviewCard.resolveAcademicTitle(9), 'Đại Học Sĩ ForteX');
      expect(AcademicHonorOverviewCard.resolveAcademicTitle(12), 'Đại Học Sĩ ForteX');
    });

    testWidgets('handles completed XP cleanly when currentXp >= nextLevelXp', (tester) async {
      const stats = StudentStatsModel(
        level: 5,
        currentXp: 2000,
        nextLevelXp: 2000,
        streakDays: 30,
        totalStudyMinutes: 600,
        completedLessons: 25,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AcademicHonorOverviewCard(
              stats: stats,
              earnedBadgesCount: 15,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Học Giả Tinh Hoa'), findsOneWidget);
      expect(find.text('CẤP ĐỘ 5'), findsOneWidget);
      expect(find.text('Đã hoàn thành • 100%'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('renders cleanly on narrow 360px device without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const stats = StudentStatsModel(
        level: 6,
        currentXp: 3500,
        nextLevelXp: 4000,
        streakDays: 45,
        totalStudyMinutes: 1500, // 25 hours
        completedLessons: 60,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: AcademicHonorOverviewCard(
                stats: stats,
                earnedBadgesCount: 20,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Học Giả Tinh Hoa'), findsOneWidget);
      expect(find.text('CẤP ĐỘ 6'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
    });
  });
}
