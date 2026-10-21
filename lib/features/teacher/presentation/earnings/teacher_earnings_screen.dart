import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

import '../../data/finance_rules.dart';
import '../../data/teacher_api.dart';
import '../classes/tools/tool_form.dart';
import '../widgets/teacher_widgets.dart';
import '../widgets/teacher_surface.dart';
import 'teacher_wallet_history.dart';
import 'widgets/teacher_wallet_balance_card.dart';
import 'widgets/teacher_wallet_bank_card.dart';
import 'widgets/teacher_wallet_summary.dart';
import 'wallet_format.dart';

class TeacherEarningsScreen extends StatefulWidget {
  const TeacherEarningsScreen({super.key, this.api});
  final TeacherApi? api;
  @override
  State<TeacherEarningsScreen> createState() => _TeacherEarningsScreenState();
}

class _TeacherEarningsScreenState extends State<TeacherEarningsScreen> {
  late final api = widget.api ?? TeacherApi();
  int revision = 0;
  bool uncertain = false;
  bool sending = false;
  String? requestError;
  void reload() => setState(() => revision++);

  Future<void> withdraw(Map<String, dynamic> wallet) async {
    if (sending || uncertain) return;
    await teacherToolForm(
      context,
      title: 'Yêu cầu rút tiền',
      action: 'Xem lại và gửi',
      fields: {'Số tiền (VND)': ''},
      validate: (v) => withdrawalError(wallet, v.values.first),
      save: (v) async {
        if (uncertain) {
          throw StateError(
            'Kết quả gửi trước chưa rõ. Hãy đóng biểu mẫu và kiểm tra lịch sử; không gửi lại.',
          );
        }
        final amount = v.values.first;
        final account = '${wallet['bank_account_number']}';
        final masked = account.length > 4
            ? '••••${account.substring(account.length - 4)}'
            : '••••';
        if (!await teacherToolConfirm(
          context,
          'Rút ${teacherMoney(amount)} về ${wallet['bank_name']} · $masked\nChủ tài khoản: ${wallet['bank_account_name']}?',
        )) {
          throw StateError('Chưa xác nhận gửi.');
        }
        if (!mounted || sending || uncertain) return;
        setState(() {
          sending = true;
          requestError = null;
        });
        try {
          await api.post(
            '/wallet/teacher/withdrawals',
            data: {'amount': amount},
          );
        } on DioException catch (e) {
          if (e.response == null || (e.response?.statusCode ?? 0) >= 500) {
            if (mounted) {
              setState(() {
                uncertain = true;
                requestError =
                    'Chưa xác định yêu cầu đã được ghi nhận hay chưa. Kiểm tra lịch sử và số dư; không gửi lại yêu cầu trong phiên này.';
              });
            }
          }
          rethrow;
        } finally {
          if (mounted) {
            setState(() {
              sending = false;
              revision++;
            });
          }
        }
      },
    );
    if (mounted) reload();
  }

  Future<void> editBank(Map<String, dynamic> wallet) async {
    final saved = await teacherToolForm(
      context,
      title: 'Tài khoản ngân hàng',
      fields: {
        'Ngân hàng': '${wallet['bank_name'] ?? ''}',
        'Số tài khoản': '${wallet['bank_account_number'] ?? ''}',
        'Tên chủ tài khoản': '${wallet['bank_account_name'] ?? ''}',
      },
      validate: (v) => v.values.any((x) => x.isEmpty)
          ? 'Điền đầy đủ thông tin ngân hàng.'
          : null,
      save: (v) async {
        await api.put(
          '/wallet/teacher/bank-info',
          data: {
            'bank_name': v['Ngân hàng'],
            'bank_account_number': v['Số tài khoản'],
            'bank_account_name': v['Tên chủ tài khoản'],
          },
        );
      },
    );
    if (saved && mounted) reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Thu nhập cá nhân'),
      actions: [
        IconButton(
          onPressed: reload,
          tooltip: 'Làm mới số dư',
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: SafeArea(
      top: false,
      child: TeacherAsyncView<Map<String, dynamic>>(
        refreshToken: revision,
        loading: const TeacherListPlaceholder(),
        load: () async => teacherMap(await api.get('/wallet/teacher/me')),
        builder: (context, wallet) => ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            Text(
              'Doanh thu khóa học của bạn, luôn thuộc tài khoản cá nhân.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            TeacherWalletBalanceCard(balance: wallet['available_balance']),
            const TeacherSectionTitle(title: 'Tài khoản nhận tiền'),
            TeacherWalletBankCard(
              wallet: wallet,
              onEdit: sending ? null : () => editBank(wallet),
            ),
            const SizedBox(height: 16),
            Text(
              'Mức rút tối thiểu: ${teacherMoney(wallet['min_withdrawal_amount'])}',
            ),
            if (requestError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  requestError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (withdrawalError(wallet, '${wallet['min_withdrawal_amount']}')
                case final String reason)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(reason),
              ),
            FilledButton(
              onPressed:
                  sending ||
                      uncertain ||
                      withdrawalError(
                            wallet,
                            '${wallet['min_withdrawal_amount']}',
                          ) !=
                          null
                  ? null
                  : () => withdraw(wallet),
              child: Text(sending ? 'Đang gửi…' : 'Rút tiền'),
            ),
            const SizedBox(height: 16),
            const TeacherSectionTitle(title: 'Tổng quan thu nhập'),
            TeacherWalletSummary(wallet: wallet),
            AppSpacing.vGap24,
            TeacherSurface(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  TeacherActionTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Lịch sử giao dịch',
                    subtitle: 'Theo dõi doanh thu và các khoản chi trả',
                    onTap: () => teacherPush<void>(
                      context,
                      TeacherWalletHistory(api: api, withdrawals: false),
                    ),
                  ),
                  TeacherActionTile(
                    icon: Icons.payments_outlined,
                    title: 'Yêu cầu rút tiền',
                    subtitle: 'Trạng thái và lịch sử yêu cầu',
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              TeacherWalletHistory(api: api, withdrawals: true),
                        ),
                      );
                      if (mounted) reload();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
