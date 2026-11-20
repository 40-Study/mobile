/// The wallet response is the authority for withdrawal limits and availability.
String? withdrawalError(Map<String, dynamic> wallet, String amount) {
  final value = num.tryParse(amount.trim());
  num number(String key) => num.tryParse('${wallet[key]}') ?? 0;
  if (wallet['has_open_withdrawal'] == true) {
    return 'Có yêu cầu đang xử lý. Hãy kiểm tra lịch sử.';
  }
  if ([
    'bank_name',
    'bank_account_number',
    'bank_account_name',
  ].any((key) => '${wallet[key] ?? ''}'.trim().isEmpty)) {
    return 'Cần cập nhật đầy đủ tài khoản ngân hàng.';
  }
  if (value == null ||
      !value.isFinite ||
      value <= 0 ||
      value != value.truncate()) {
    return 'Nhập số tiền nguyên lớn hơn 0.';
  }
  if (value < number('min_withdrawal_amount')) {
    return 'Số tiền thấp hơn mức rút tối thiểu.';
  }
  if (value > number('available_balance')) return 'Số dư khả dụng không đủ.';
  return null;
}
