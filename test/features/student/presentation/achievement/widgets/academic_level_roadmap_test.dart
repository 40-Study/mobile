import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/student/data/models/student_stats_model.dart';
import 'package:study/features/student/presentation/achievement/widgets/academic_level_roadmap.dart';
import 'package:study/features/student/presentation/achievement/widgets/overview_statistics.dart';

void main() {
  group('AcademicLevelRoadmap Test Suite', () {
    testWidgets('renders RPG progression track with Lv.1 to Lv.5 waypoints cleanly',
        (tester) async {
      const stats = StudentStatsModel(
        level: 4,
        currentXp: 1850,
        nextLevelXp: 2000,
        streakDays: 12,
        totalStudyMinutes: 120, // 2 hours
        completedLessons: 10,
        totalLessons: 20,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AcademicLevelRoadmap(
                stats: stats,
                earnedBadgesCount: 4,
                enableAnimation: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Header Mở thoáng
      expect(find.text('HÀNH TRÌNH HỌC THUẬT'), findsOneWidget);
      expect(find.text('Bản Đồ Tiến Hóa Cấp Bậc'), findsOneWidget);
      expect(find.text('Đang diễn ra'), findsOneWidget);

      // Tầng 1: Dải Waypoints Bản đồ Cấp độ
      expect(find.text('Lv.1'), findsOneWidget);
      expect(find.text('Lv.2'), findsOneWidget);
      expect(find.text('Lv.3'), findsOneWidget);
      expect(find.text('Lv.4'), findsOneWidget);
      expect(find.text('Lv.5'), findsOneWidget);

      expect(find.text('Tân Khoa'), findsOneWidget);
      expect(find.text('Tinh Thông'), findsOneWidget);
      expect(find.text('Tiến Bộ'), findsOneWidget);
      expect(find.text('Vững Vàng'), findsOneWidget);
      expect(find.text('Tinh Hoa'), findsOneWidget);

      // Tầng 2: Hero Zenith Core
      expect(find.text('Học Giả Vững Vàng'), findsOneWidget);
      expect(find.text('CẤP ĐỘ 4'), findsOneWidget);
      expect(find.text('1,850'), findsOneWidget);
      expect(find.text('XP'), findsOneWidget);
      expect(find.text('4 huy hiệu'), findsOneWidget);

      // Thanh năng lượng thủy dịch XP chính xác 70%
      expect(find.text('Tiến độ thăng cấp Lv.5 (350 / 500 XP)'), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);

      // Dòng thôi thúc hành động
      expect(
        find.text('Còn 150 XP nữa để mở khóa Học Giả Tinh Hoa (Cấp 5)'),
        findsOneWidget,
      );

      // Tầng 3: Satellite Metric Pods
      expect(find.text('12 Ngày'), findsOneWidget);
      expect(find.text('Chuỗi kỷ luật'), findsOneWidget);
      expect(find.text('2 Giờ'), findsOneWidget);
      expect(find.text('Tích lũy học'), findsOneWidget);
      expect(find.text('10 Bài'), findsOneWidget);
      expect(find.text('Đã hoàn thành'), findsOneWidget);
    });

    testWidgets('OverviewStatistics legacy wrapper delegates properly', (tester) async {
      const stats = StudentStatsModel(
        level: 4,
        currentXp: 1850,
        nextLevelXp: 2000,
        streakDays: 12,
        totalStudyMinutes: 120,
        completedLessons: 10,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OverviewStatistics(
                stats: stats,
                earnedBadgesCount: 4,
                enableAnimation: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Học Giả Vững Vàng'), findsOneWidget);
      expect(find.text('CẤP ĐỘ 4'), findsOneWidget);
      expect(find.text('1,850'), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);
      expect(find.text('12 Ngày'), findsOneWidget);
    });

    test('LevelProgressData mathematical engine computes accurate ratios across boundaries', () {
      // 0 XP -> Level 1 (0 / 500 XP, 0%)
      const stats0 = StudentStatsModel(level: 1, currentXp: 0);
      final p0 = LevelProgressData.fromStats(stats0);
      expect(p0.currentLevel, 1);
      expect(p0.currentLevelXp, 0);
      expect(p0.xpNeededForNext, 500);
      expect(p0.progressRatio, 0.0);
      expect(p0.progressPercent, 0);

      // 250 XP -> Level 1 (250 / 500 XP, 50%)
      const stats250 = StudentStatsModel(level: 1, currentXp: 250);
      final p250 = LevelProgressData.fromStats(stats250);
      expect(p250.currentLevel, 1);
      expect(p250.currentLevelXp, 250);
      expect(p250.xpNeededForNext, 250);
      expect(p250.progressRatio, 0.5);
      expect(p250.progressPercent, 50);

      // 500 XP -> Level 2 (0 / 500 XP, 0%)
      const stats500 = StudentStatsModel(level: 2, currentXp: 500);
      final p500 = LevelProgressData.fromStats(stats500);
      expect(p500.currentLevel, 2);
      expect(p500.currentLevelXp, 0);
      expect(p500.xpNeededForNext, 500);
      expect(p500.progressRatio, 0.0);
      expect(p500.progressPercent, 0);

      // 1850 XP -> Level 4 (350 / 500 XP, 70%)
      const stats1850 = StudentStatsModel(level: 4, currentXp: 1850);
      final p1850 = LevelProgressData.fromStats(stats1850);
      expect(p1850.currentLevel, 4);
      expect(p1850.currentLevelXp, 350);
      expect(p1850.xpNeededForNext, 150);
      expect(p1850.progressRatio, 0.7);
      expect(p1850.progressPercent, 70);

      // Dynamic titles verification
      expect(LevelProgressData.resolveAcademicTitle(1), 'Tân Khoa Nhập Môn');
      expect(LevelProgressData.resolveAcademicTitle(2), 'Tân Khoa Tinh Thông');
      expect(LevelProgressData.resolveAcademicTitle(3), 'Học Giả Tiến Bộ');
      expect(LevelProgressData.resolveAcademicTitle(4), 'Học Giả Vững Vàng');
      expect(LevelProgressData.resolveAcademicTitle(5), 'Học Giả Tinh Hoa');
      expect(LevelProgressData.resolveAcademicTitle(6), 'Học Viện Danh Dự');
      expect(LevelProgressData.resolveAcademicTitle(7), 'Học Sĩ Uyên Bác');
      expect(LevelProgressData.resolveAcademicTitle(8), 'Học Sĩ Tinh Thông');
      expect(LevelProgressData.resolveAcademicTitle(9), 'Đại Học Sĩ ForteX');
    });

    testWidgets('renders cleanly on narrow 360px screen without any RenderFlex overflow',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const stats = StudentStatsModel(
        level: 5,
        currentXp: 2200,
        nextLevelXp: 2500,
        streakDays: 30,
        totalStudyMinutes: 900,
        completedLessons: 45,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: AcademicLevelRoadmap(
                stats: stats,
                earnedBadgesCount: 14,
                enableAnimation: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Học Giả Tinh Hoa'), findsOneWidget);
      expect(find.text('CẤP ĐỘ 5'), findsOneWidget);
      expect(find.text('30 Ngày'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders Ambient Honor Canvas with high contrast grading in Light Mode and preserves Dark Mode',
        (tester) async {
      const stats = StudentStatsModel(
        level: 4,
        currentXp: 1850,
        nextLevelXp: 2000,
        streakDays: 12,
        totalStudyMinutes: 120,
        completedLessons: 10,
      );

      // 1. Kiểm thử trên Light Mode
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: AcademicLevelRoadmap(
                stats: stats,
                earnedBadgesCount: 4,
                enableAnimation: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Kiểm tra đầy đủ nội dung trên Light Mode
      expect(find.text('Học Giả Vững Vàng'), findsOneWidget);
      expect(find.text('CẤP ĐỘ 4'), findsOneWidget);
      expect(find.text('1,850'), findsOneWidget);
      expect(find.text('12 Ngày'), findsOneWidget);
      expect(find.text('2 Giờ'), findsOneWidget);
      expect(find.text('10 Bài'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 2. Kiểm thử trên Dark Mode
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: AcademicLevelRoadmap(
                stats: stats,
                earnedBadgesCount: 4,
                enableAnimation: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Học Giả Vững Vàng'), findsOneWidget);
      expect(find.text('CẤP ĐỘ 4'), findsOneWidget);
      expect(find.text('1,850'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
