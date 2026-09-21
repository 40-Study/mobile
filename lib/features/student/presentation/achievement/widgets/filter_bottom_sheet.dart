import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String _selectedStatus = 'all';
  String _selectedCategory = 'all';

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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterOption(
                  label: l10n.all,
                  isSelected: _selectedStatus == 'all',
                  onTap: () => setState(() => _selectedStatus = 'all')),
              FilterOption(
                  label: l10n.earned,
                  isSelected: _selectedStatus == 'earned',
                  onTap: () => setState(() => _selectedStatus = 'earned')),
              FilterOption(
                  label: l10n.inProgress,
                  isSelected: _selectedStatus == 'inProgress',
                  onTap: () => setState(() => _selectedStatus = 'inProgress')),
              FilterOption(
                  label: l10n.notEarned,
                  isSelected: _selectedStatus == 'locked',
                  onTap: () => setState(() => _selectedStatus = 'locked')),
            ],
          ),
          AppSpacing.vGap24,
          Text(l10n.category, style: tt.titleSmall),
          AppSpacing.vGap12,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterOption(
                  label: l10n.all,
                  isSelected: _selectedCategory == 'all',
                  onTap: () => setState(() => _selectedCategory = 'all')),
              FilterOption(
                  label: l10n.learning,
                  isSelected: _selectedCategory == 'learning',
                  onTap: () => setState(() => _selectedCategory = 'learning')),
              FilterOption(
                  label: l10n.habit,
                  isSelected: _selectedCategory == 'habit',
                  onTap: () => setState(() => _selectedCategory = 'habit')),
              FilterOption(
                  label: l10n.achievement,
                  isSelected: _selectedCategory == 'achievement',
                  onTap: () => setState(() => _selectedCategory = 'achievement')),
            ],
          ),
          AppSpacing.vGap32,
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.apply),
            ),
          ),
          AppSpacing.vGap16,
        ],
      ),
    );
  }
}

class FilterOption extends StatelessWidget {
  const FilterOption({
    super.key,
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
