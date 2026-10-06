import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

import 'experience_section.dart';
import 'intro_section.dart';
import 'package:study/features/student/bloc/portfolio/portfolio_state.dart';
import 'profile_hero.dart';
import 'projects_section.dart';
import 'skills_section.dart';

class PortfolioPreviewScreen extends StatelessWidget {
  const PortfolioPreviewScreen({
    super.key,
    required this.profile,
    required this.stats,
    required this.sections,
    required this.projects,
    required this.skills,
    required this.experiences,
  });

  final PortfolioProfile profile;
  final PortfolioStats stats;
  final List<PortfolioSection> sections;
  final List<Project> projects;
  final List<Skill> skills;
  final List<Experience> experiences;

  Widget _buildPreviewSection(PortfolioSection section) {
    switch (section.id) {
      case 'intro':
        return IntroSection(
          stats: stats,
          isEditMode: false,
          visible: true,
          onToggleVisibility: () {},
        );
      case 'projects':
        return ProjectsSection(
          projects: projects,
          isEditMode: false,
          visible: true,
          onToggleVisibility: () {},
        );
      case 'skills':
        return SkillsSection(
          skills: skills,
          isEditMode: false,
          visible: true,
          onToggleVisibility: () {},
        );
      case 'experience':
        return ExperienceSection(
          experiences: experiences,
          isEditMode: false,
          visible: true,
          onToggleVisibility: () {},
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.previewPortfolio),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(l10n.editPortfolio),
          ),
          AppSpacing.hGap8,
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          // Profile hero (preview mode)
          ProfileHero(profile: profile, isEditMode: false),
          AppSpacing.vGap24,
          // Sections (preview mode - dynamic order, only visible ones)
          ...sections.asMap().entries.expand((entry) {
            final index = entry.key;
            final section = entry.value;
            if (!section.visible) return <Widget>[];
            return [
              _buildPreviewSection(section),
              if (index < sections.length - 1) AppSpacing.vGap16,
            ];
          }),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
