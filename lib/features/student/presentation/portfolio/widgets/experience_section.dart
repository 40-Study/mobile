import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

import 'package:study/features/student/bloc/portfolio/portfolio_state.dart';
import 'portfolio_section_header.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({
    super.key,
    required this.experiences,
    required this.isEditMode,
    required this.visible,
    required this.onToggleVisibility,
    this.onAddExperience,
  });

  final List<Experience> experiences;
  final bool isEditMode;
  final bool visible;
  final VoidCallback onToggleVisibility;
  final VoidCallback? onAddExperience;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: Column(
        children: [
          PortfolioSectionHeader(
            title: l10n.experience,
            visible: visible,
            isEditMode: isEditMode,
            onToggleVisibility: onToggleVisibility,
          ),
          if (visible) ...[
            AppSpacing.vGap12,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                children: [
                  ...experiences.map((exp) => _ExperienceItem(experience: exp)),
                  if (isEditMode) ...[
                    AppSpacing.vGap12,
                    OutlinedButton.icon(
                      onPressed: onAddExperience,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.addExperience),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderMd,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExperienceItem extends StatelessWidget {
  const _ExperienceItem({required this.experience});

  final Experience experience;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(Icons.work_outline, size: 20, color: cs.primary),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  experience.position,
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  experience.company,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                AppSpacing.vGap4,
                Text(
                  '${experience.startDate} – ${experience.endDate ?? l10n.present}',
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              experience.description,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}
