import 'package:flutter/material.dart';

class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final List<FilterItem> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter.value == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.label),
              selected: isSelected,
              onSelected: (_) => onFilterChanged(filter.value),
              backgroundColor: cs.surface,
              selectedColor: cs.primary,
              labelStyle: TextStyle(
                color: isSelected ? cs.onPrimary : cs.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? cs.primary : cs.outlineVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FilterItem {
  const FilterItem({required this.label, required this.value});

  final String label;
  final String value;
}
