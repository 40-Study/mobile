import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

/// Generic filter bottom sheet
/// Trả về map {statusKey: selectedValue, categoryKey: selectedValue}
class FilterSheet extends StatefulWidget {
  const FilterSheet({
    super.key,
    required this.statusOptions,
    required this.categoryOptions,
    this.initialStatus = 'all',
    this.initialCategory = 'all',
  });

  /// Map: value -> label
  final Map<String, String> statusOptions;
  final Map<String, String> categoryOptions;
  final String initialStatus;
  final String initialCategory;

  /// Show sheet và trả về filter result
  static Future<({String status, String category})?> show(
    BuildContext context, {
    required Map<String, String> statusOptions,
    required Map<String, String> categoryOptions,
    String initialStatus = 'all',
    String initialCategory = 'all',
  }) async {
    return showModalBottomSheet<({String status, String category})>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FilterSheet(
        statusOptions: statusOptions,
        categoryOptions: categoryOptions,
        initialStatus: initialStatus,
        initialCategory: initialCategory,
      ),
    );
  }

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String _selectedStatus;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          AppSpacing.vGap16,
          Text(l10n.filter,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          AppSpacing.vGap24,
          Text(l10n.status, style: tt.titleSmall),
          AppSpacing.vGap12,
          _buildOptions(widget.statusOptions, _selectedStatus,
              (v) => setState(() => _selectedStatus = v)),
          AppSpacing.vGap24,
          Text(l10n.category, style: tt.titleSmall),
          AppSpacing.vGap12,
          _buildOptions(widget.categoryOptions, _selectedCategory,
              (v) => setState(() => _selectedCategory = v)),
          AppSpacing.vGap32,
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(
                  context, (status: _selectedStatus, category: _selectedCategory)),
              child: Text(l10n.apply),
            ),
          ),
          AppSpacing.vGap16,
        ],
      ),
    );
  }

  Widget _buildOptions(
      Map<String, String> options, String selected, ValueChanged<String> onTap) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.entries
          .map((e) => _FilterChip(
                label: e.value,
                isSelected: selected == e.key,
                onTap: () => onTap(e.key),
              ))
          .toList(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check_rounded, size: 16, color: cs.onPrimary),
              AppSpacing.hGap4,
            ],
            Text(label,
                style: tt.labelMedium
                    ?.copyWith(color: isSelected ? cs.onPrimary : cs.onSurface)),
          ],
        ),
      ),
    );
  }
}
