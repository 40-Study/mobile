import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/parent/data/models/parent_analytics_data.dart';
import 'package:study/features/parent/data/models/parent_homework_model.dart';
import 'package:study/features/parent/presentation/home/widgets/learning_analytics_card.dart';
import 'package:study/features/parent/presentation/learning/course_detail/widgets/parent_course_enrollment_bar.dart';
import 'package:study/features/parent/presentation/learning/homework/widgets/homework_detail_actions.dart';
import 'package:study/features/parent/presentation/payment/widgets/payment_toolbar.dart';

ParentAnalyticsData _analytics(String id, String name) => ParentAnalyticsData(
  childId: id,
  childName: name,
  className: '10A1',
  reportLabel: 'Báo cáo tuần 4',
  subjectName: 'Toán',
  progressPercent: 15,
  averageScore: 8.4,
  weeklyTrend: const [0.4, 0.5, 0.6, 0.8],
  insightText: 'Tiến bộ trong tuần',
);

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  testWidgets('analytics keeps selected-child navigation and collapse', (
    tester,
  ) async {
    String? selected;
    await _pump(
      tester,
      LearningAnalyticsCard(
        analytics: _analytics('minh', 'Minh'),
        selectedChildId: 'minh',
        onViewDetailForChild: (id) => selected = id,
      ),
    );
    await tester.tap(find.text('Xem phân tích của Minh ->'));
    expect(selected, 'minh');
    await tester.tap(find.text('PHÂN TÍCH HỌC TẬP'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade))
          .crossFadeState,
      CrossFadeState.showSecond,
    );
    await tester.tap(find.text('PHÂN TÍCH HỌC TẬP'));
    await tester.pumpAndSettle();
    expect(
      find.text('Xem phân tích của Minh ->').hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('family analytics preserves the child chosen from each report', (
    tester,
  ) async {
    String? selected;
    var allReports = false;
    await _pump(
      tester,
      LearningAnalyticsCard(
        analytics: null,
        analyticsList: [_analytics('minh', 'Minh'), _analytics('lan', 'Lan')],
        onViewDetailForChild: (id) => selected = id,
        onViewAllReports: () => allReports = true,
      ),
    );
    final lan = find.text('Xem phân tích của Lan ->');
    await tester.ensureVisible(lan);
    await tester.tap(lan);
    expect(selected, 'lan');
    final all = find.text('Tất cả phân tích >');
    await tester.ensureVisible(all);
    await tester.tap(all);
    expect(allReports, isTrue);
    expect(tester.takeException(), isNull);
  });

  for (final status in [
    ParentHomeworkStatus.urgent,
    ParentHomeworkStatus.submitted,
    ParentHomeworkStatus.graded,
  ]) {
    testWidgets('homework actions preserve permissions for $status', (
      tester,
    ) async {
      var reminded = false;
      var contacted = false;
      await _pump(
        tester,
        HomeworkDetailActions(
          detail: ParentHomeworkDetailModel(
            id: 'homework',
            title: 'Bài tập',
            subjectName: 'Toán',
            teacherName: 'Giáo viên',
            dueDateText: '15/10/2026',
            timeRemainingText: 'Còn 1 ngày',
            status: status,
            statusLabel: 'Bài tập',
            description: 'Nội dung',
          ),
          onRemind: () => reminded = true,
          onContactTeacher: () => contacted = true,
        ),
      );
      final remind = find.text('Nhắc con nộp');
      if (status == ParentHomeworkStatus.urgent) {
        await tester.tap(remind);
        expect(reminded, isTrue);
      } else {
        expect(remind, findsNothing);
      }
      await tester.tap(find.text('Nhắn giáo viên'));
      expect(contacted, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('enrollment and payment callbacks stay connected', (
    tester,
  ) async {
    var enrolled = false;
    var history = false;
    var toggled = false;
    await _pump(
      tester,
      Column(
        children: [
          ParentCourseEnrollmentBar(
            childName: 'Lan',
            onEnroll: () => enrolled = true,
          ),
          PaymentToolbar(
            showDueDemo: false,
            onOpenHistory: () => history = true,
            onToggleDemo: () => toggled = true,
          ),
        ],
      ),
    );
    await tester.tap(find.text('Đăng ký khóa học ngay'));
    await tester.tap(find.text('Lịch sử thanh toán'));
    await tester.tap(find.text('Demo: Tất toán'));
    expect(enrolled, isTrue);
    expect(history, isTrue);
    expect(toggled, isTrue);
    await tester.tap(find.text('Tư vấn miễn phí 1-1'));
    await tester.pump();
    expect(find.textContaining('Lan.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
