import 'package:flutter_test/flutter_test.dart';
import 'package:study/core/network/api_response.dart';

void main() {
  group('ApiResponse', () {
    test('parses absent data and accepts both pagination key styles', () {
      final missing = ApiResponse<int>.fromJson({
        'message': 'ok',
      }, (value) => value! as int);
      expect(missing.data, isNull);
      expect(missing.message, 'ok');

      final response = ApiResponse<int>.fromJson({
        'data': 7,
        'meta': {
          'page': '2',
          'pageSize': 10.9,
          'total': 21,
          'total_pages': '3',
        },
      }, (value) => value! as int);
      expect(response.data, 7);
      expect(response.meta?.page, 2);
      expect(response.meta?.pageSize, 10);
      expect(response.meta?.total, 21);
      expect(response.meta?.totalPages, 3);
      expect(response.toJson((value) => value), {
        'data': 7,
        'meta': {'page': 2, 'page_size': 10, 'total': 21, 'total_pages': 3},
      });
    });

    test('ignores malformed optional pagination values', () {
      final response = ApiResponse<void>.fromJson({
        'data': null,
        'meta': 'bad',
      }, (_) => null);
      expect(response.meta, isNull);
      expect(response.toJson((_) => null), isEmpty);

      final meta = PaginationMeta.fromJson({
        'page': 'not-a-number',
        'page_size': null,
        'total': 4.8,
      });
      expect(meta.page, isNull);
      expect(meta.pageSize, isNull);
      expect(meta.total, 4);
      expect(meta.toJson(), {'total': 4});
    });
  });
}
