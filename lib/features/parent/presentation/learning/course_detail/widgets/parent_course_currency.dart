String formatParentCourseCurrency(int amount) {
  final buffer = StringBuffer();
  final str = amount.toString();
  var count = 0;
  for (var i = str.length - 1; i >= 0; i--) {
    buffer.write(str[i]);
    count++;
    if (count % 3 == 0 && i > 0) {
      buffer.write('.');
    }
  }
  return '${buffer.toString().split('').reversed.join()}đ';
}
