import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/teacher/data/finance_rules.dart';

void main() {
  final wallet = <String, dynamic>{
    'available_balance': '350000',
    'min_withdrawal_amount': '150000',
    'has_open_withdrawal': false,
    'bank_name': 'Bank',
    'bank_account_number': '1234567',
    'bank_account_name': 'Teacher',
  };
  test(
    'withdrawal uses server minimum, available balance and open-request guard',
    () {
      expect(withdrawalError(wallet, '100000'), isNotNull);
      expect(withdrawalError(wallet, '150000'), isNull);
      expect(withdrawalError(wallet, '350001'), isNotNull);
      expect(
        withdrawalError({...wallet, 'has_open_withdrawal': true}, '150000'),
        isNotNull,
      );
      expect(
        withdrawalError({...wallet, 'available_balance': '-5'}, '150000'),
        isNotNull,
      );
      expect(
        withdrawalError({...wallet, 'bank_account_name': ''}, '150000'),
        isNotNull,
      );
      for (final invalid in ['NaN', 'Infinity', '150000.5', '-10', '']) {
        expect(withdrawalError(wallet, invalid), isNotNull, reason: invalid);
      }
    },
  );
}
