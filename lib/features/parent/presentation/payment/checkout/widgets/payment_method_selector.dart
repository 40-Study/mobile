import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_payment_model.dart';

class PaymentMethodItem {
  const PaymentMethodItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.badgeText,
  });

  final PaymentMethodType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final String? badgeText;
}

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
  });

  final PaymentMethodType selectedMethod;
  final ValueChanged<PaymentMethodType> onChanged;

  static const List<PaymentMethodItem> methods = [
    PaymentMethodItem(
      type: PaymentMethodType.vietQr,
      title: 'VietQR Napas247',
      subtitle: 'Quét mã chuyển khoản tức thì mọi ngân hàng',
      icon: Icons.qr_code_2_rounded,
      badgeText: 'Khuyên dùng',
    ),
    PaymentMethodItem(
      type: PaymentMethodType.atmCard,
      title: 'Thẻ ATM / Internet Banking',
      subtitle: 'Hơn 40 ngân hàng nội địa Việt Nam',
      icon: Icons.account_balance_rounded,
    ),
    PaymentMethodItem(
      type: PaymentMethodType.eWallet,
      title: 'Ví điện tử',
      subtitle: 'MoMo, ZaloPay, VNPay, ShopeePay',
      icon: Icons.account_balance_wallet_outlined,
    ),
    PaymentMethodItem(
      type: PaymentMethodType.creditCard,
      title: 'Thẻ quốc tế',
      subtitle: 'Visa, MasterCard, JCB',
      icon: Icons.credit_card_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PHƯƠNG THỨC THANH TOÁN',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ...methods.map((method) {
          final isSelected = method.type == selectedMethod;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFEFF6FF)
                  : cs.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF1D4ED8)
                    : cs.outlineVariant.withValues(alpha: 0.6),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => onChanged(method.type),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1D4ED8)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          method.icon,
                          size: 22,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  method.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                if (method.badgeText != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      method.badgeText!,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF15803D),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              method.subtitle,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFF94A3B8),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
