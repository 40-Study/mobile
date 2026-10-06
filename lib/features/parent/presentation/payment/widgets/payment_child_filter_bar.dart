import 'package:flutter/material.dart';

class PaymentChildFilterItem {
  const PaymentChildFilterItem({
    this.id,
    required this.label,
    this.count,
  });

  final String? id; // null = Tất cả học sinh
  final String label;
  final int? count;
}

class PaymentChildFilterBar extends StatelessWidget {
  const PaymentChildFilterBar({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onChanged,
  });

  final List<PaymentChildFilterItem> items;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: items.map((item) {
          final isSelected = item.id == selectedId;
          final displayText = item.count != null
              ? '${item.label} (${item.count})'
              : item.label;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                displayText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? cs.onPrimary
                      : cs.onSurface.withValues(alpha: 0.8),
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF1D4ED8),
              backgroundColor: cs.surface,
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF1D4ED8)
                    : cs.outlineVariant.withValues(alpha: 0.7),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 4,
              ),
              onSelected: (_) => onChanged(item.id),
            ),
          );
        }).toList(),
      ),
    );
  }
}
