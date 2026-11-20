import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/earnings/teacher_earnings_screen.dart';

class _WalletApi extends TeacherApi {
  _WalletApi() : super(dio: Dio());
  int posts = 0;
  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async => {
    'available_balance': '350000',
    'min_withdrawal_amount': '100000',
    'has_open_withdrawal': false,
    'bank_name': 'Test Bank',
    'bank_account_number': '123456789',
    'bank_account_name': 'Teacher',
  };
  @override
  Future<dynamic> post(String path, {dynamic data}) async {
    posts++;
    throw DioException(
      requestOptions: RequestOptions(path: path),
      type: DioExceptionType.receiveTimeout,
    );
  }
}

void main() {
  testWidgets('uncertain withdrawal is never posted again from the same form', (
    tester,
  ) async {
    final api = _WalletApi();
    await tester.pumpWidget(MaterialApp(home: TeacherEarningsScreen(api: api)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Rút tiền'), 300);
    await tester.tap(find.text('Rút tiền'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '100000');
    await tester.tap(find.text('Xem lại và gửi'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
    await tester.pumpAndSettle();
    expect(api.posts, 1);
    expect(find.text('100000'), findsOneWidget);
    await tester.tap(find.text('Xem lại và gửi'));
    await tester.pumpAndSettle();
    expect(api.posts, 1);
    expect(find.textContaining('không gửi lại.'), findsOneWidget);
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('Rút tiền'), 300);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Rút tiền'),
    );
    expect(button.onPressed, isNull);
  });
}
