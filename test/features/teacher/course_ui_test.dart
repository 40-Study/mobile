import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/courses/teacher_courses_screen.dart';
import 'package:study/features/teacher/presentation/earnings/teacher_earnings_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

class _Api extends TeacherApi {
  _Api() : super(dio: Dio());
  final requests = <String>[];
  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    requests.add(path);
    if (path == '/wallet/teacher/me')
      return {
        'data': {'available_balance': '1500000'},
      };
    return {
      'data': {'courses': <dynamic>[], 'total': 0},
    };
  }
}

void main() {
  testWidgets('refresh keeps the message composer focused and draft intact', (
    tester,
  ) async {
    var revision = 0, calls = 0;
    late StateSetter update;
    final pending = Completer<String>(), input = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return TeacherAsyncView<String>(
                refreshToken: revision,
                load: () {
                  calls++;
                  return calls == 1 ? Future.value('Đã tải') : pending.future;
                },
                builder: (_, value) => Column(
                  children: [
                    Text(value),
                    TextField(controller: input),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Bản nháp đang viết');
    update(() => revision++);
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);
    expect(find.text('Bản nháp đang viết'), findsOneWidget);
    pending.complete('Có tin nhắn mới');
    await tester.pumpAndSettle();
    expect(tester.testTextInput.isVisible, isTrue);
    expect(input.text, 'Bản nháp đang viết');
    await tester.pumpWidget(const SizedBox.shrink());
    input.dispose();
  });
  testWidgets(
    'empty course collection and filtered empty have different recovery',
    (tester) async {
      final api = _Api();
      await tester.pumpWidget(
        MaterialApp(home: TeacherCoursesScreen(api: api)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Khóa học đầu tiên của bạn'), findsOneWidget);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Nháp'));
      await tester.pumpAndSettle();
      expect(find.text('Không có khóa khớp bộ lọc'), findsOneWidget);
      await tester.tap(find.text('Xóa bộ lọc'));
      await tester.pumpAndSettle();
      expect(find.text('Khóa học đầu tiên của bạn'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'earnings remain reachable after removing Teacher account tools',
    (tester) async {
      final api = _Api();
      await tester.pumpWidget(
        MaterialApp(home: TeacherCoursesScreen(api: api)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thu nhập cá nhân'));
      await tester.pumpAndSettle();
      expect(find.byType(TeacherEarningsScreen), findsOneWidget);
      expect(api.requests, contains('/wallet/teacher/me'));
      expect(find.text('1.500.000 ₫'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'explicit refresh retains content and does not request on rebuild',
    (tester) async {
      var revision = 0, calls = 0;
      late StateSetter update;
      final pending = Completer<String>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return TeacherAsyncView<String>(
                  refreshToken: revision,
                  load: () {
                    calls++;
                    return calls == 1
                        ? Future.value('Nội dung cũ')
                        : pending.future;
                  },
                  builder: (_, value) => ListView(children: [Text(value)]),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      update(() {});
      await tester.pump();
      expect(calls, 1);
      update(() => revision++);
      await tester.pump();
      expect(find.text('Nội dung cũ'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      pending.complete('Nội dung mới');
      await tester.pumpAndSettle();
      expect(find.text('Nội dung mới'), findsOneWidget);
      expect(calls, 2);
    },
  );
}
