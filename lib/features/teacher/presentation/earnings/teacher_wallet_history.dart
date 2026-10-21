import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/empty_state.dart';
import '../../data/teacher_api.dart';
import '../classes/tools/tool_form.dart';
import '../widgets/teacher_widgets.dart';

class TeacherWalletHistory extends StatefulWidget {
  const TeacherWalletHistory({required this.api, required this.withdrawals});
  final TeacherApi api;
  final bool withdrawals;
  @override
  State<TeacherWalletHistory> createState() => _TeacherWalletHistoryState();
}

class _TeacherWalletHistoryState extends State<TeacherWalletHistory> {
  int page = 1, revision = 0;
  String filter = '';
  bool busy = false;
  static const statuses = {
    'pending': 'Chờ xử lý',
    'approved': 'Đã duyệt',
    'completed': 'Đã chuyển',
    'rejected': 'Bị từ chối',
    'cancelled': 'Đã hủy',
  };
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.withdrawals ? 'Yêu cầu rút tiền' : 'Giao dịch cá nhân',
      ),
    ),
    body: Column(
      children: [
        if (!widget.withdrawals)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '', label: Text('Tất cả')),
                ButtonSegment(value: 'income', label: Text('Thu nhập')),
                ButtonSegment(value: 'expense', label: Text('Hoàn tiền')),
              ],
              selected: {filter},
              onSelectionChanged: (v) => setState(() {
                filter = v.first;
                page = 1;
              }),
            ),
          ),
        Expanded(
          child: TeacherAsyncView<Map<String, dynamic>>(
            key: ValueKey('$page/$filter/$revision'),
            load: () async => teacherMap(
              await widget.api.get(
                '/wallet/teacher/${widget.withdrawals ? 'withdrawals' : 'transactions'}',
                query: {
                  'page': page,
                  'limit': 20,
                  if (filter.isNotEmpty) 'type': filter,
                },
              ),
            ),
            builder: (context, data) {
              final rows = teacherList(
                data,
                keys: [widget.withdrawals ? 'items' : 'transactions'],
              );
              return Column(
                children: [
                  Expanded(
                    child: rows.isEmpty
                        ? EmptyState(
                            style: EmptyStateStyle.fullPage,
                            title: widget.withdrawals
                                ? 'Chưa có yêu cầu rút tiền'
                                : 'Chưa có giao dịch',
                            message: widget.withdrawals
                                ? 'Yêu cầu rút và tiến độ xử lý sẽ xuất hiện tại đây.'
                                : 'Giao dịch khóa học sẽ được cập nhật khi phát sinh.',
                          )
                        : ListView.separated(
                            itemCount: rows.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final row = teacherMap(rows[index]);
                              final amount = NumberFormat.decimalPattern(
                                'vi',
                              ).format(num.tryParse('${row['amount']}') ?? 0);
                              final status = '${row['status']}';
                              return ListTile(
                                title: Text(
                                  '$amount ₫ · ${widget.withdrawals ? statuses[status] ?? status : row['course_name'] ?? ''}',
                                ),
                                subtitle: Text(
                                  '${row['created_at'] ?? ''}\n${widget.withdrawals ? '${row['bank_name'] ?? ''}${row['rejection_reason'] == null ? '' : '\n${row['rejection_reason']}'}' : '${row['order_number'] ?? ''} · $status'}',
                                ),
                                isThreeLine: true,
                                onTap: () => showDialog<void>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Chi tiết'),
                                    content: SelectableText(
                                      'Số tiền: $amount ₫\n'
                                      'Trạng thái: ${statuses[status] ?? status}\n'
                                      'Thời gian: ${row['created_at'] ?? '—'}\n'
                                      '${widget.withdrawals ? 'Ngân hàng: ${row['bank_name'] ?? '—'}\nChủ tài khoản: ${row['bank_account_name'] ?? '—'}\nSố tài khoản: ••••${_lastDigits(row['bank_account_number'])}\nLý do từ chối: ${row['rejection_reason'] ?? '—'}\nMã chuyển khoản: ${row['transaction_id'] ?? '—'}' : 'Khóa học: ${row['course_name'] ?? '—'}\nĐơn hàng: ${row['order_number'] ?? '—'}\nNgười mua: ${row['buyer_name'] ?? '—'}'}',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Đóng'),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing:
                                    widget.withdrawals && status == 'pending'
                                    ? TextButton(
                                        onPressed: busy
                                            ? null
                                            : () async {
                                                if (!await teacherToolConfirm(
                                                  context,
                                                  'Hủy yêu cầu rút $amount ₫?',
                                                )) {
                                                  return;
                                                }
                                                if (!mounted) return;
                                                setState(() => busy = true);
                                                try {
                                                  await widget.api.post(
                                                    '/wallet/teacher/withdrawals/${row['id']}/cancel',
                                                  );
                                                  if (mounted) {
                                                    setState(() => revision++);
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Không hủy được: $e',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                } finally {
                                                  if (mounted) {
                                                    setState(
                                                      () => busy = false,
                                                    );
                                                  }
                                                }
                                              },
                                        child: const Text('Hủy'),
                                      )
                                    : null,
                              );
                            },
                          ),
                  ),
                  SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: page > 1
                              ? () => setState(() => page--)
                              : null,
                          tooltip: 'Trang trước',
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text('Trang $page / ${data['total_pages'] ?? 1}'),
                        IconButton(
                          onPressed:
                              page <
                                  (num.tryParse('${data['total_pages']}') ?? 1)
                              ? () => setState(() => page++)
                              : null,
                          tooltip: 'Trang sau',
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}

String _lastDigits(dynamic value) {
  final text = '$value';
  return text.length > 4 ? text.substring(text.length - 4) : '';
}
