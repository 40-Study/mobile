import 'package:flutter/material.dart';

/// Bộ lọc dạng chip ngang cho danh sách khóa học đề xuất
class CourseFilterChips extends StatelessWidget {
  const CourseFilterChips({
    super.key,
    required this.selectedFilter,
    required this.childName,
    required this.onSelected,
  });

  final String selectedFilter;
  final String childName;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'all', 'label': 'Tất cả'},
      {'key': 'best_match', 'label': 'Phù hợp nhất với $childName'},
      {'key': 'toan', 'label': 'Bổ trợ môn Toán'},
      {'key': 'tieng_anh', 'label': 'Tiếng Anh'},
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = filters[index];
          final key = item['key']!;
          final label = item['label']!;
          final isSelected = selectedFilter == key;

          return GestureDetector(
            onTap: () => onSelected(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
