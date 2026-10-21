import 'package:intl/intl.dart';

String teacherMoney(dynamic value) {
  final amount = num.tryParse('$value');
  return amount == null || !amount.isFinite
      ? '—'
      : '${NumberFormat.decimalPattern('vi').format(amount)} ₫';
}

String teacherMaskedAccount(String account) => account.isEmpty
    ? 'Chưa có số tài khoản'
    : '••••${account.length > 4 ? account.substring(account.length - 4) : ''}';
