import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/portfolio/portfolio_cubit.dart';
import 'package:study/features/student/bloc/portfolio/portfolio_state.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

import 'dialogs/dialogs.dart';
import 'mock_portfolio_data.dart';
import 'widgets/widgets.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  late final PortfolioCubit _cubit;

  PortfolioProfile _profile = kMockProfile;
  final _stats = kMockStats;
  final List<Project> _projects = List.of(kMockProjects);
  final List<Skill> _skills = List.of(kMockSkills);
  final List<Experience> _experiences = List.of(kMockExperiences);

  late List<PortfolioSection> _sections;
  bool _sectionsInitialized = false;

  @override
  void initState() {
    super.initState();
    _cubit = PortfolioCubit();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _initSections(AppLocalizations l10n) {
    if (_sectionsInitialized) return;
    _sections = [
      PortfolioSection(id: 'intro', title: l10n.introduction, visible: true),
      PortfolioSection(id: 'projects', title: l10n.featuredProjects, visible: true),
      PortfolioSection(id: 'skills', title: l10n.skills, visible: true),
      PortfolioSection(id: 'experience', title: l10n.experience, visible: true),
    ];
    _sectionsInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    _initSections(l10n);

    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<PortfolioCubit, PortfolioState>(
        buildWhen: (prev, curr) => prev.isEditMode != curr.isEditMode,
        builder: (context, state) {
          final isEditMode = state.isEditMode;
          return Scaffold(
            backgroundColor: cs.surface,
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(cs, isEditMode),
                  SliverToBoxAdapter(
                    child: ProfileHero(
                      profile: _profile,
                      isEditMode: isEditMode,
                      onEdit: () => _showEditProfileDialog(context),
                    ),
                  ),
                  const SliverToBoxAdapter(child: AppSpacing.vGap24),
                  ..._sections.asMap().entries.expand((entry) {
                    final index = entry.key;
                    final section = entry.value;
                    return [
                      SliverToBoxAdapter(
                        child: _buildSection(context, section, index, isEditMode),
                      ),
                      if (index < _sections.length - 1)
                        const SliverToBoxAdapter(child: AppSpacing.vGap16),
                    ];
                  }),
                  const SliverToBoxAdapter(child: AppSpacing.vGap24),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)), // ponytail: no token for 120, keep as-is
                ],
              ),
            ),
            floatingActionButton: isEditMode
                ? FloatingActionButton(
                    onPressed: () => _showAddSectionSheet(context),
                    backgroundColor: cs.primary,
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                : null,
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(ColorScheme cs, bool isEditMode) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: AppSpacing.paddingSm,
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: AppRadius.borderSm,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Icon(Icons.arrow_back, size: 20, color: cs.onSurface),
        ),
      ),
      actions: [
        ModeToggleButton(
          isEditMode: isEditMode,
          onToggle: () => _cubit.toggleEditMode(),
        ),
        AppSpacing.hGap8,
        if (isEditMode)
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: AppRadius.borderSm,
              border: Border.all(color: cs.outlineVariant),
            ),
            child: IconButton(
              onPressed: () => _showLayoutEditor(context),
              icon: Icon(Icons.grid_view, color: cs.primary),
              tooltip: 'Quản lý bố cục',
            ),
          ),
        if (isEditMode) AppSpacing.hGap8,
        Container(
          margin: const EdgeInsets.only(right: AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: AppRadius.borderSm,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: IconButton(
            onPressed: () => _showMoreMenu(context),
            icon: Icon(Icons.more_horiz, color: cs.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, PortfolioSection section, int index, bool isEditMode) {
    switch (section.id) {
      case 'intro':
        return IntroSection(
          stats: _stats,
          isEditMode: isEditMode,
          visible: section.visible,
          onToggleVisibility: () => _toggleSectionVisibility(index),
        );
      case 'projects':
        return ProjectsSection(
          projects: _projects,
          isEditMode: isEditMode,
          visible: section.visible,
          onToggleVisibility: () => _toggleSectionVisibility(index),
          onAddProject: () => _showAddProjectDialog(context),
          onRemoveProject: _removeProject,
        );
      case 'skills':
        return SkillsSection(
          skills: _skills,
          isEditMode: isEditMode,
          visible: section.visible,
          onToggleVisibility: () => _toggleSectionVisibility(index),
          onAddSkill: () => _showAddSkillDialog(context),
          onRemoveSkill: _removeSkill,
        );
      case 'experience':
        return ExperienceSection(
          experiences: _experiences,
          isEditMode: isEditMode,
          visible: section.visible,
          onToggleVisibility: () => _toggleSectionVisibility(index),
          onAddExperience: () => _showAddExperienceDialog(context),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ============================================================
  // DIALOGS
  // ============================================================

  void _showAddSectionSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Padding(
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
            Text(l10n.addItem, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            AppSpacing.vGap16,
            AddSectionTile(
              icon: Icons.folder_outlined,
              title: l10n.addProject,
              onTap: () {
                Navigator.pop(context);
                _showAddProjectDialog(context);
              },
            ),
            AddSectionTile(
              icon: Icons.work_outline,
              title: l10n.addExperience,
              onTap: () {
                Navigator.pop(context);
                _showAddExperienceDialog(context);
              },
            ),
            AddSectionTile(
              icon: Icons.school_outlined,
              title: l10n.addEducation,
              onTap: () {
                Navigator.pop(context);
                _showAddExperienceDialog(context);
              },
            ),
            AddSectionTile(
              icon: Icons.lightbulb_outline,
              title: l10n.addSkill,
              onTap: () {
                Navigator.pop(context);
                _showAddSkillDialog(context);
              },
            ),
            AppSpacing.vGap16,
          ],
        ),
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AddProjectDialog(
        onAdd: (project) => setState(() => _projects.add(project)),
      ),
    );
  }

  void _showAddSkillDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AddSkillDialog(
        onAdd: (skill) => setState(() => _skills.add(skill)),
      ),
    );
  }

  void _showAddExperienceDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AddExperienceDialog(
        onAdd: (exp) => setState(() => _experiences.add(exp)),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => EditProfileDialog(
        profile: _profile,
        onSave: (profile) => setState(() => _profile = profile),
      ),
    );
  }

  void _showLayoutEditor(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => LayoutEditorDialog(
        sections: _sections,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex--;
            final item = _sections.removeAt(oldIndex);
            _sections.insert(newIndex, item);
          });
        },
        onToggleVisibility: _toggleSectionVisibility,
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AppSpacing.vGap16,
            MenuTile(
              icon: Icons.visibility_outlined,
              iconColor: cs.primary,
              title: l10n.previewPortfolio,
              subtitle: l10n.viewAsOthers,
              onTap: () {
                Navigator.pop(ctx);
                _openPreview(context);
              },
            ),
            MenuTile(
              icon: Icons.share_outlined,
              iconColor: AchievementColors.blue,
              title: l10n.share,
              subtitle: l10n.shareOnSocial,
              onTap: () {
                Navigator.pop(ctx);
                _sharePortfolio(context);
              },
            ),
            MenuTile(
              icon: Icons.link,
              iconColor: AchievementColors.green,
              title: l10n.copyLink,
              subtitle: l10n.copyPortfolioLink,
              onTap: () {
                Navigator.pop(ctx);
                _copyLink(context);
              },
            ),
            MenuTile(
              icon: Icons.download_outlined,
              iconColor: AchievementColors.orange,
              title: l10n.downloadPdf,
              subtitle: l10n.downloadPortfolioPdf,
              onTap: () {
                Navigator.pop(ctx);
                _downloadPdf(context);
              },
            ),
            MenuTile(
              icon: Icons.lock_outline,
              iconColor: cs.onSurfaceVariant,
              title: l10n.privacySettings,
              subtitle: _getVisibilityText(l10n),
              trailing: VisibilityBadge(visibility: _cubit.state.visibility),
              onTap: () {
                Navigator.pop(ctx);
                _showVisibilitySettings(context);
              },
            ),
            AppSpacing.vGap8,
          ],
        ),
      ),
    );
  }

  void _showVisibilitySettings(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => Padding(
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
            Text(l10n.privacySettings, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            AppSpacing.vGap16,
            VisibilityOption(
              icon: Icons.public,
              title: l10n.publicPortfolio,
              subtitle: l10n.everyoneCanView,
              isSelected: _cubit.state.visibility == 'public',
              onTap: () {
                _cubit.setVisibility('public');
                Navigator.pop(ctx);
              },
            ),
            VisibilityOption(
              icon: Icons.link,
              title: l10n.linkOnlyPortfolio,
              subtitle: l10n.onlyWithLink,
              isSelected: _cubit.state.visibility == 'link',
              onTap: () {
                _cubit.setVisibility('link');
                Navigator.pop(ctx);
              },
            ),
            VisibilityOption(
              icon: Icons.lock_outline,
              title: l10n.privatePortfolio,
              subtitle: l10n.onlyYouCanView,
              isSelected: _cubit.state.visibility == 'private',
              onTap: () {
                _cubit.setVisibility('private');
                Navigator.pop(ctx);
              },
            ),
            AppSpacing.vGap16,
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  void _toggleSectionVisibility(int index) {
    setState(() => _sections[index] = _sections[index].copyWith(visible: !_sections[index].visible));
  }

  void _removeProject(int index) => setState(() => _projects.removeAt(index));

  void _removeSkill(int index) => setState(() => _skills.removeAt(index));

  String _getVisibilityText(AppLocalizations l10n) {
    switch (_cubit.state.visibility) {
      case 'public':
        return l10n.everyoneCanView;
      case 'private':
        return l10n.onlyYouCanView;
      case 'link':
        return l10n.onlyWithLink;
      default:
        return '';
    }
  }

  void _openPreview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PortfolioPreviewScreen(
          profile: _profile,
          stats: _stats,
          sections: _sections,
          projects: _projects,
          skills: _skills,
          experiences: _experiences,
        ),
      ),
    );
  }

  void _sharePortfolio(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: 'https://${_profile.website}'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.linkCopiedToShare),
        backgroundColor: AchievementColors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      ),
    );
  }

  void _copyLink(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: 'https://${_profile.website}'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.linkCopied),
        backgroundColor: AchievementColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      ),
    );
  }

  void _downloadPdf(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.creatingPdf),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      ),
    );
    // TODO(MOCK-01): Implement PDF generation - needs pdf package
  }
}
