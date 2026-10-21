import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_discussions_screen.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_messages_screen.dart';

import '../../support/teacher_screen_fixtures.dart';

class _PendingMessageApi extends TeacherFixtureApi {
  final send = Completer<dynamic>();
  int sent = 0;
  @override
  Future<dynamic> post(String path, {dynamic data}) {
    if (path.endsWith('/messages')) {
      sent++;
      return send.future;
    }
    return super.post(path, data: data);
  }
}

void main() {
  testWidgets('pending message can finish after leaving conversation', (
    tester,
  ) async {
    final api = _PendingMessageApi();
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherConversationScreen(
          api: api,
          conversationId: 'conversation',
          realtime: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Bài tập tuần này');
    await tester.tap(find.byTooltip('Gửi'));
    await tester.pump();
    expect(api.sent, 1);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Đã rời'))),
    );
    api.send.complete({
      'data': {'id': 'message', 'content': 'Bài tập tuần này'},
    });
    await tester.pumpAndSettle();
    expect(find.text('Đã rời'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(api.sent, 1);
  });
  testWidgets(
    'closing discussion composer preserves route lifecycle during animation',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: TeacherDiscussionsScreen(api: TeacherFixtureApi())),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Câu hỏi chưa đăng');
      await tester.tap(find.text('Hủy'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
