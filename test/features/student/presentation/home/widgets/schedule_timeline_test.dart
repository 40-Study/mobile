import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/data/motivational_quotes.dart';
import 'package:study/features/student/presentation/home/widgets/schedule_timeline.dart';

void main() {
  group('ScheduleTimeline', () {
    testWidgets('should display timeline items', (tester) async {
      final items = [
        ScheduleTimelineItemData(
          time: '09:00 - 10:30',
          title: 'Toan cao cap',
          subtitle: 'Livestream - Phong A101',
          type: ScheduleItemType.livestream,
          isActive: true,
        ),
        ScheduleTimelineItemData(
          time: '14:00 - 15:30',
          title: 'Python Co ban',
          subtitle: 'Video - Bai 2.3 Functions',
          type: ScheduleItemType.video,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ScheduleTimeline(items: items)),
        ),
      );

      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('10:30'), findsOneWidget);
      expect(find.text('Toan cao cap'), findsOneWidget);
      expect(find.text('14:00'), findsOneWidget);
      expect(find.text('15:30'), findsOneWidget);
      expect(find.text('Python Co ban'), findsOneWidget);
    });

    testWidgets('should show empty state when no items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ScheduleTimeline(items: [])),
        ),
      );

      // Empty state hiển thị quote động lực theo ngày thay vì dòng chữ cố định
      final quote = MotivationalQuote.scheduleForDate(DateTime.now());
      expect(find.text('Quote hôm nay'), findsOneWidget);
      expect(find.text('"${quote.quote}"'), findsOneWidget);
    });
  });
}
