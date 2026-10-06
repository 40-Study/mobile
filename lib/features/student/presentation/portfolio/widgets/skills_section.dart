import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

import 'package:study/features/student/bloc/portfolio/portfolio_state.dart';
import 'portfolio_section_header.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({
    super.key,
    required this.skills,
    required this.isEditMode,
    required this.visible,
    required this.onToggleVisibility,
    this.onAddSkill,
    this.onRemoveSkill,
  });

  final List<Skill> skills;
  final bool isEditMode;
  final bool visible;
  final VoidCallback onToggleVisibility;
  final VoidCallback? onAddSkill;
  final void Function(int index)? onRemoveSkill;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: Column(
        children: [
          PortfolioSectionHeader(
            title: l10n.skills,
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
                  // Grid 2 columns
                  for (int i = 0; i < skills.length; i += 2)
                    Padding(
                      padding: EdgeInsets.only(bottom: i + 2 < skills.length ? 8 : 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _SkillChip(
                              skill: skills[i],
                              isEditMode: isEditMode,
                              onRemove: isEditMode && onRemoveSkill != null
                                  ? () => onRemoveSkill!(i)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (i + 1 < skills.length)
                            Expanded(
                              child: _SkillChip(
                                skill: skills[i + 1],
                                isEditMode: isEditMode,
                                onRemove: isEditMode && onRemoveSkill != null
                                    ? () => onRemoveSkill!(i + 1)
                                    : null,
                              ),
                            )
                          else
                            const Expanded(child: SizedBox()),
                        ],
                      ),
                    ),
                  if (isEditMode && onAddSkill != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onAddSkill,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          borderRadius: AppRadius.borderMd,
                          border: Border.all(color: cs.primary),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 16, color: cs.primary),
                            const SizedBox(width: 4),
                            Text(
                              l10n.addSkill,
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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

class _SkillChip extends StatelessWidget {
  const _SkillChip({
    required this.skill,
    this.isEditMode = false,
    this.onRemove,
  });

  final Skill skill;
  final bool isEditMode;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(_getSkillIcon(skill.name), size: 16, color: cs.primary),
          AppSpacing.hGap8,
          Expanded(
            child: Text(
              skill.name,
              style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AppSpacing.hGap8,
          // Level dots
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(left: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < skill.level ? cs.primary : cs.outlineVariant,
                ),
              );
            }),
          ),
          // Delete button in edit mode
          if (isEditMode && onRemove != null) ...[
            AppSpacing.hGap8,
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close, size: 16, color: cs.error),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getSkillIcon(String name) {
    if (name.contains('Design')) return Icons.brush;
    if (name.contains('Research')) return Icons.search;
    if (name.contains('Figma')) return Icons.design_services;
    if (name.contains('Prototyping')) return Icons.architecture;
    if (name.contains('System')) return Icons.grid_view;
    if (name.contains('Wire')) return Icons.crop_square;
    if (name.contains('Testing')) return Icons.check_circle_outline;
    return Icons.lightbulb_outline;
  }
}
