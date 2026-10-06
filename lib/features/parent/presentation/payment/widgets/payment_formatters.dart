/// Hàm định dạng tiền tệ Việt Nam Đồng (VND)
String formatVnd(num amount) {
  final isNegative = amount < 0;
  final absVal = amount.abs().round();
  final s = absVal.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(s[i]);
  }
  return '${isNegative ? '-' : ''}${buffer.toString()} đ';
}
