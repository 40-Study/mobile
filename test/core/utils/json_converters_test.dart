import 'package:flutter_test/flutter_test.dart';
import 'package:study/core/utils/json_converters.dart';

void main() {
  test(
    'numeric converters handle null, numbers, strings, and malformed input',
    () {
      const decimal = StringToDoubleConverter();
      const nullableDecimal = StringToNullableDoubleConverter();
      const integer = StringToIntConverter();

      expect(decimal.fromJson(null), 0);
      expect(decimal.fromJson(2), 2.0);
      expect(decimal.fromJson('2.5'), 2.5);
      expect(decimal.fromJson('bad'), 0);
      expect(decimal.toJson(2.5), 2.5);

      expect(nullableDecimal.fromJson(null), isNull);
      expect(nullableDecimal.fromJson('bad'), isNull);
      expect(nullableDecimal.fromJson('1.25'), 1.25);
      expect(nullableDecimal.toJson(null), isNull);

      expect(integer.fromJson(null), 0);
      expect(integer.fromJson(3.9), 3);
      expect(integer.fromJson('-4'), -4);
      expect(integer.fromJson('bad'), 0);
      expect(integer.toJson(4), 4);
    },
  );
}
