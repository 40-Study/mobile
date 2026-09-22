import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key, required this.skills});

  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (skills.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.skillsEarned,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          AppSpacing.vGap16,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((skill) => _SkillChip(skill: skill)).toList(),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.skill});

  final String skill;

  IconData _getIconForSkill(String skill) {
    final lower = skill.toLowerCase();
    if (lower.contains('research')) return Icons.search_rounded;
    if (lower.contains('wire')) return Icons.grid_on_rounded;
    if (lower.contains('ui') || lower.contains('design')) {
      return Icons.palette_rounded;
    }
    if (lower.contains('proto')) return Icons.play_circle_rounded;
    if (lower.contains('system')) return Icons.auto_awesome_mosaic_rounded;
    return Icons.check_circle_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: cs.primary.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIconForSkill(skill), size: 14, color: cs.primary),
          AppSpacing.hGap8,
          Text(skill,
              style: tt.labelMedium
                  ?.copyWith(color: cs.primary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
