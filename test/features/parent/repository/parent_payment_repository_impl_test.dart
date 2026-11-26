import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/features/parent/data/models/parent_payment_model.dart';
import 'package:study/features/parent/data/parent_home_api_client.dart';
import 'package:study/features/parent/repository/parent_payment_repository.dart';
import 'package:study/features/parent/repository/parent_payment_repository_impl.dart';

class _Api extends Mock implements ParentHomeApiClient {}

void main() {
  group('ParentPaymentRepositoryImpl', () {
    late _Api api;

    setUp(() {
      api = _Api();
      when(
        () => api.getChildren(),
      ).thenThrow(DioException(requestOptions: RequestOptions()));
    });

    test('getChildren should rethrow API error when preview disabled', () {
      final repo = ParentPaymentRepositoryImpl(
        apiClient: api,
        enablePreviewFallback: false,
      );
      expect(repo.getChildren(), throwsA(isA<DioException>()));
    });

    test('getChildren should merge mock children when preview enabled', () async {
      final repo = ParentPaymentRepositoryImpl(
        apiClient: api,
        enablePreviewFallback: true,
      );
      final ids = (await repo.getChildren()).map((c) => c.id);
      expect(ids, contains(ParentPaymentRepositoryImpl.studentMinhId));
    });
    test('submitPayment should throw when preview disabled', () {
      final repo = ParentPaymentRepositoryImpl(
        apiClient: api,
        enablePreviewFallback: false,
      );
      expect(
        repo.submitPayment(
          invoiceId: 'inv',
          method: PaymentMethodType.vietQr,
          idempotencyKey: 'k',
        ),
        throwsA(isA<PaymentUnavailableException>()),
      );
    });

    test('getPaymentSummary should throw when preview disabled', () {
      final repo = ParentPaymentRepositoryImpl(
        apiClient: api,
        enablePreviewFallback: false,
      );
      expect(
        repo.getPaymentSummary(childId: 'real-child'),
        throwsA(isA<PaymentUnavailableException>()),
      );
    });

    test('checkPaymentStatus should throw when preview disabled', () {
      final repo = ParentPaymentRepositoryImpl(
        apiClient: api,
        enablePreviewFallback: false,
      );
      expect(
        repo.checkPaymentStatus('TXN-1'),
        throwsA(isA<PaymentUnavailableException>()),
      );
    });
  });
}
