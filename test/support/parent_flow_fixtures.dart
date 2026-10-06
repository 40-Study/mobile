import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_payment_model.dart';
import 'package:study/features/parent/presentation/learning/homework/parent_homework_detail_screen.dart';
import 'package:study/features/parent/presentation/learning/homework/parent_homework_screen.dart';
import 'package:study/features/parent/presentation/learning/progress/parent_progress_screen.dart';
import 'package:study/features/parent/presentation/payment/checkout/payment_checkout_screen.dart';
import 'package:study/features/parent/presentation/payment/history/payment_history_screen.dart';
import 'package:study/features/parent/presentation/payment/invoice_detail/payment_invoice_detail_screen.dart';
import 'package:study/features/parent/presentation/payment/result/payment_transaction_result_screen.dart';
import 'package:study/features/parent/repository/parent_learning_repository_impl.dart';

const _invoice = ParentInvoiceModel(
  id: 'invoice',
  invoiceCode: '#INV-2026-01',
  childId: 'child',
  childName: 'Minh',
  childInitials: 'M',
  className: '10A1',
  title: 'Học phí tháng 10',
  courseName: 'Toán',
  teacherName: 'Giáo viên',
  durationText: '12 buổi',
  dueDateText: '15/10/2026',
  status: PaymentInvoiceStatus.unpaid,
  statusLabel: 'Chưa thanh toán',
  lineItems: [InvoiceLineItem(name: 'Học phí', amount: 1400000)],
  originalAmount: 1400000,
  totalAmount: 1400000,
);

List<Widget> createParentFlowFixtures() => [
  ParentHomeworkScreen(repository: ParentLearningRepositoryImpl()),
  ParentHomeworkDetailScreen(
    homeworkId: 'hw-minh-toan-1',
    childId: ParentLearningRepositoryImpl.studentMinhId,
    repository: ParentLearningRepositoryImpl(),
  ),
  ParentProgressScreen(repository: ParentLearningRepositoryImpl()),
  const PaymentCheckoutScreen(invoice: _invoice),
  const PaymentHistoryScreen(),
  const PaymentInvoiceDetailScreen(invoice: _invoice),
  PaymentTransactionResultScreen(
    initialResult: PaymentTransactionResult(
      transactionId: 'transaction',
      invoiceId: 'invoice',
      amount: 1400000,
      status: PaymentTransactionStatus.success,
      statusTitle: 'Thanh toán thành công',
      message: 'Đã ghi nhận học phí',
      paymentMethod: PaymentMethodType.vietQr,
      timestamp: DateTime(2026, 10, 6),
      idempotencyKey: 'test-payment',
    ),
  ),
];
