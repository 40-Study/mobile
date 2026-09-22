import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

import 'filter_bottom_sheet.dart';

/// Filter sheet cho certificates screen
class CertificateFilterSheet extends StatefulWidget {
  const CertificateFilterSheet({super.key});

  @override
  State<CertificateFilterSheet> createState() => _CertificateFilterSheetState();
}

class _CertificateFilterSheetState extends State<CertificateFilterSheet> {
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
                  label: l10n.completed,
                  isSelected: _selectedStatus == 'completed',
                  onTap: () => setState(() => _selectedStatus = 'completed')),
              FilterOption(
                  label: l10n.studying,
                  isSelected: _selectedStatus == 'inProgress',
                  onTap: () => setState(() => _selectedStatus = 'inProgress')),
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
                  label: l10n.design,
                  isSelected: _selectedCategory == 'design',
                  onTap: () => setState(() => _selectedCategory = 'design')),
              FilterOption(
                  label: l10n.programming,
                  isSelected: _selectedCategory == 'programming',
                  onTap: () =>
                      setState(() => _selectedCategory = 'programming')),
              FilterOption(
                  label: l10n.business,
                  isSelected: _selectedCategory == 'business',
                  onTap: () => setState(() => _selectedCategory = 'business')),
              FilterOption(
                  label: l10n.language,
                  isSelected: _selectedCategory == 'language',
                  onTap: () => setState(() => _selectedCategory = 'language')),
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
