import 'package:flutter/material.dart';

/// Item mô tả cho một nút lọc bài tập
class HomeworkFilterOption {
  const HomeworkFilterOption({
    required this.key,
    required this.label,
    this.badgeCount,
  });

  final String key;
  final String label;
  final int? badgeCount;

  String get displayText =>
      badgeCount != null ? '$label ($badgeCount)' : label;
}

/// Thanh cuộn ngang các chip bộ lọc bài tập
class HomeworkFilterBar extends StatelessWidget {
  const HomeworkFilterBar({
    super.key,
    required this.options,
    required this.selectedKey,
    required this.onSelectKey,
  });

  final List<HomeworkFilterOption> options;
  final String selectedKey;
  final ValueChanged<String> onSelectKey;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: options.map((option) {
          final isSelected = option.key == selectedKey;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onSelectKey(option.key),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  option.displayText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
