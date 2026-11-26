import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/presentation/payment/parent_payment_screen.dart';
import 'package:study/features/parent/repository/parent_payment_repository.dart';

class _Repo extends Mock implements ParentPaymentRepository {}

class _AuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  group('ParentPaymentScreen', () {
    testWidgets('should show error instead of all-paid when payment unavailable', (
      tester,
    ) async {
      final repo = _Repo();
      when(repo.getChildren).thenAnswer(
        (_) async => [FamilyScopeChild.sample(id: 'c1', name: 'An', className: '6A')],
      );
      when(
        () => repo.getPaymentSummary(
          childId: any(named: 'childId'),
          mockAllPaid: any(named: 'mockAllPaid'),
        ),
      ).thenThrow(const PaymentUnavailableException());

      // Header cần AuthBloc
      final authBloc = _AuthBloc();
      whenListen(
        authBloc,
        const Stream<AuthState>.empty(),
        initialState: AuthUnauthenticated(),
      );

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: MaterialApp(home: ParentPaymentScreen(repository: repo)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Thanh toán trực tuyến chưa khả dụng.'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
      expect(find.textContaining('Hoàn tất 100%'), findsNothing);
    });
  });
}
