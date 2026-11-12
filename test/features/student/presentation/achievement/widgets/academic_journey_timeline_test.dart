import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/student/data/models/student_stats_model.dart';
import 'package:study/features/student/presentation/achievement/widgets/academic_journey_timeline.dart';
import 'package:study/features/student/presentation/achievement/widgets/overview_statistics.dart';

void main() {
  group('AcademicJourneyTimeline Test Suite', () {
    testWidgets('renders all 4 timeline waypoints correctly', (tester) async {
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
            body: SingleChildScrollView(
              child: AcademicJourneyTimeline(
                stats: stats,
                earnedBadgesCount: 3,
                joinedDateText: 'Gia nhập ngày 15/01/2026',
                enableAnimation: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Header
      expect(find.text('HÀNH TRÌNH HỌC THUẬT'), findsOneWidget);
      expect(find.text('Tiến Trình & Cột Mốc Năng Lực'), findsOneWidget);
      expect(find.text('Đang diễn ra'), findsOneWidget);

      // Trạm 1: Khởi Nguyên
      expect(find.text('Khởi Nguyên Tri Thức'), findsOneWidget);
      expect(find.text('Gia nhập ngày 15/01/2026'), findsOneWidget);
      expect(find.text('4 giờ tích lũy'), findsOneWidget);
      expect(find.text('12 bài hoàn tất'), findsOneWidget);

      // Trạm 2: Kỷ Luật
      expect(find.text('Chuỗi Kỷ Luật'), findsOneWidget);
      expect(find.text('7 ngày liên tục'), findsOneWidget);

      // Trạm 3: Đỉnh Cao Hiện Tại
      expect(find.text('Tân Khoa Nhập Môn'), findsOneWidget);
      expect(find.text('CẤP ĐỘ 1'), findsOneWidget);
      expect(find.text('350 XP tích lũy • 3 huy hiệu vinh danh'), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);

      // Trạm 4: Chân Trời Kế Tiếp
      expect(find.text('Mục Tiêu Kế Tiếp: Tân Khoa Tinh Thông'), findsOneWidget);
      expect(find.text('(Cấp 2)'), findsOneWidget);
      expect(
        find.text('Còn 150 XP nữa để vinh danh danh xưng tiếp theo.'),
        findsOneWidget,
      );
    });

    testWidgets('OverviewStatistics legacy wrapper delegates properly', (tester) async {
      const stats = StudentStatsModel(
        level: 3,
        currentXp: 1200,
        nextLevelXp: 1500,
        streakDays: 15,
        totalStudyMinutes: 480, // 8 hours
        completedLessons: 28,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OverviewStatistics(
                stats: stats,
                earnedBadgesCount: 7,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Học Giả Tiến Bộ'), findsOneWidget);
      expect(find.text('CẤP ĐỘ 3'), findsOneWidget);
      expect(find.text('15 Ngày'), findsOneWidget);
      expect(find.text('8 Giờ'), findsOneWidget);
    });

    testWidgets('dynamic academic titles map accurately across levels', (tester) async {
      expect(AcademicJourneyTimeline.resolveAcademicTitle(1), 'Tân Khoa Nhập Môn');
      expect(AcademicJourneyTimeline.resolveAcademicTitle(2), 'Tân Khoa Tinh Thông');
      expect(AcademicJourneyTimeline.resolveAcademicTitle(3), 'Học Giả Tiến Bộ');
      expect(AcademicJourneyTimeline.resolveAcademicTitle(4), 'Học Giả Vững Vàng');
      expect(AcademicJourneyTimeline.resolveAcademicTitle(5), 'Học Giả Tinh Hoa');
      expect(AcademicJourneyTimeline.resolveAcademicTitle(6), 'Học Viện Danh Dự');
      expect(AcademicJourneyTimeline.resolveAcademicTitle(7), 'Học Sĩ Uyên Bác');
      expect(AcademicJourneyTimeline.resolveAcademicTitle(8), 'Học Sĩ Tinh Thông');
      expect(AcademicJourneyTimeline.resolveAcademicTitle(9), 'Đại Học Sĩ ForteX');
    });

    testWidgets('renders cleanly on narrow 360px screen without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const stats = StudentStatsModel(
        level: 5,
        currentXp: 2200,
        nextLevelXp: 2500,
        streakDays: 30,
        totalStudyMinutes: 900, // 15 hours
        completedLessons: 45,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: AcademicJourneyTimeline(
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
      expect(find.text('Mục Tiêu Kế Tiếp: Học Viện Danh Dự'), findsOneWidget);
      expect(find.text('(Cấp 6)'), findsOneWidget);
      expect(find.text('30 ngày liên tục'), findsOneWidget);
    });
  });
}
