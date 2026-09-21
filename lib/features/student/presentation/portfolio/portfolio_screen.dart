import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/portfolio/portfolio_cubit.dart';
import 'package:study/features/student/bloc/portfolio/portfolio_state.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

import 'widgets/widgets.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  late final PortfolioCubit _cubit;

  // Mock data - sẽ từ API sau
  PortfolioProfile _profile = const PortfolioProfile(
    name: 'Linh Nguyen',
    title: 'UI/UX Designer',
    location: 'Hà Nội, Việt Nam',
    website: 'linhnguyen.design',
    bio:
        'Mình là UI/UX Designer với niềm đam mê tạo ra những trải nghiệm số đẹp mắt, hữu ích và dễ sử dụng.',
    socialLinks: [
      SocialLink(type: 'dribbble', url: ''),
      SocialLink(type: 'behance', url: ''),
      SocialLink(type: 'linkedin', url: ''),
      SocialLink(type: 'github', url: ''),
    ],
  );

  final _stats = const PortfolioStats(
    yearsExperience: '3+',
    projectsCompleted: 18,
    certificates: 12,
    followers: 120,
  );

  late List<PortfolioSection> _sections;
  bool _sectionsInitialized = false;

  final List<Project> _projects = [
    const Project(
      title: 'EduFlow',
      subtitle: 'Hệ thống quản lý học tập',
      description: 'Thiết kế hệ thống dashboard và trải nghiệm học tập toàn diện.',
      category: 'UI/UX DESIGN',
      tool: 'Figma',
      year: '2024',
    ),
    const Project(
      title: 'Mindora',
      subtitle: 'Ứng dụng thiền và thư giãn',
      description: 'Thiết kế ứng dụng giúp người dùng thiền định và theo dõi thói quen.',
      category: 'MOBILE APP',
      tool: 'Figma',
      year: '2023',
    ),
    const Project(
      title: 'GreenSpace',
      subtitle: 'Website thương hiệu',
      description: 'Thiết kế website giới thiệu sản phẩm và thương hiệu thân thiện.',
      category: 'WEBSITE',
      tool: 'Figma',
      year: '2023',
    ),
  ];

  final List<Skill> _skills = [
    const Skill(name: 'UI Design', level: 5),
    const Skill(name: 'UX Research', level: 3),
    const Skill(name: 'Prototyping', level: 4),
    const Skill(name: 'Interaction Design', level: 4),
    const Skill(name: 'Figma', level: 5),
    const Skill(name: 'Design System', level: 4),
    const Skill(name: 'Wireframing', level: 4),
    const Skill(name: 'Usability Testing', level: 3),
  ];

  final List<Experience> _experiences = [
    const Experience(
      position: 'Senior UI/UX Designer',
      company: 'Vela Creative Studio',
      startDate: '03/2022',
      endDate: null,
      description:
          'Thiết kế sản phẩm số cho khách hàng trong lĩnh vực edtech, fintech và healthtech. Dẫn dắt team 4 designer trong các dự án lớn.',
    ),
  ];

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
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    ];
                  }),
                  const SliverToBoxAdapter(child: AppSpacing.vGap24),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
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
          padding: const EdgeInsets.all(8),
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
          onToggleVisibility: () {
            setState(() => _sections[index] = _sections[index].copyWith(visible: !_sections[index].visible));
          },
        );
      case 'projects':
        return ProjectsSection(
          projects: _projects,
          isEditMode: isEditMode,
          visible: section.visible,
          onToggleVisibility: () {
            setState(() => _sections[index] = _sections[index].copyWith(visible: !_sections[index].visible));
          },
          onAddProject: () => _showAddProjectDialog(context),
          onRemoveProject: _removeProject,
        );
      case 'skills':
        return SkillsSection(
          skills: _skills,
          isEditMode: isEditMode,
          visible: section.visible,
          onToggleVisibility: () {
            setState(() => _sections[index] = _sections[index].copyWith(visible: !_sections[index].visible));
          },
          onAddSkill: () => _showAddSkillDialog(context),
          onRemoveSkill: _removeSkill,
        );
      case 'experience':
        return ExperienceSection(
          experiences: _experiences,
          isEditMode: isEditMode,
          visible: section.visible,
          onToggleVisibility: () {
            setState(() => _sections[index] = _sections[index].copyWith(visible: !_sections[index].visible));
          },
          onAddExperience: () => _showAddExperienceDialog(context),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ============================================================
  // DIALOGS & SHEETS
  // ============================================================

  void _showAddSectionSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
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
            Text(
              l10n.addItem,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
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
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final descController = TextEditingController();
    var category = 'UI/UX DESIGN';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.addProject,
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                AppSpacing.vGap16,
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: l10n.projectName,
                    hintText: l10n.projectNameHint,
                    border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                  ),
                ),
                AppSpacing.vGap12,
                TextField(
                  controller: subtitleController,
                  decoration: InputDecoration(
                    labelText: l10n.shortDescription,
                    hintText: l10n.shortDescriptionHint,
                    border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                  ),
                ),
                AppSpacing.vGap12,
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: l10n.details,
                    border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                  ),
                ),
                AppSpacing.vGap12,
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: InputDecoration(
                    labelText: l10n.categoryLabel,
                    border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                  ),
                  items: ['UI/UX DESIGN', 'MOBILE APP', 'WEBSITE', 'BRANDING']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => category = v ?? category),
                ),
                AppSpacing.vGap16,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    AppSpacing.hGap12,
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (titleController.text.isNotEmpty) {
                            setState(() {
                              _projects.add(Project(
                                title: titleController.text,
                                subtitle: subtitleController.text,
                                description: descController.text,
                                category: category,
                                tool: 'Figma',
                                year: DateTime.now().year.toString(),
                              ));
                            });
                            Navigator.pop(ctx);
                          }
                        },
                        child: Text(l10n.add),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddSkillDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    var level = 3;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final cs = Theme.of(ctx).colorScheme;
          final tt = Theme.of(ctx).textTheme;
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.addSkill,
                        style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  AppSpacing.vGap16,
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.skillName,
                      hintText: l10n.skillNameHint,
                      border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                    ),
                  ),
                  AppSpacing.vGap16,
                  Text(l10n.proficiencyLevel, style: tt.labelLarge),
                  AppSpacing.vGap8,
                  Row(
                    children: List.generate(5, (index) {
                      final isSelected = index < level;
                      return GestureDetector(
                        onTap: () => setDialogState(() => level = index + 1),
                        child: Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? cs.primary : cs.surfaceContainerHighest,
                            border: Border.all(
                              color: isSelected ? cs.primary : cs.outlineVariant,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: tt.labelMedium?.copyWith(
                                color: isSelected ? Colors.white : cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  AppSpacing.vGap16,
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      AppSpacing.hGap12,
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            if (nameController.text.isNotEmpty) {
                              setState(() {
                                _skills.add(Skill(name: nameController.text, level: level));
                              });
                              Navigator.pop(ctx);
                            }
                          },
                          child: Text(l10n.add),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddExperienceDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final positionController = TextEditingController();
    final companyController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.addExperience,
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              AppSpacing.vGap16,
              TextField(
                controller: positionController,
                decoration: InputDecoration(
                  labelText: l10n.position,
                  hintText: l10n.positionHint,
                  border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                ),
              ),
              AppSpacing.vGap12,
              TextField(
                controller: companyController,
                decoration: InputDecoration(
                  labelText: l10n.company,
                  hintText: l10n.companyHint,
                  border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                ),
              ),
              AppSpacing.vGap12,
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.jobDescription,
                  border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                ),
              ),
              AppSpacing.vGap16,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  AppSpacing.hGap12,
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (positionController.text.isNotEmpty) {
                          setState(() {
                            _experiences.add(Experience(
                              position: positionController.text,
                              company: companyController.text,
                              startDate: '${DateTime.now().month}/${DateTime.now().year}',
                              description: descController.text,
                            ));
                          });
                          Navigator.pop(ctx);
                        }
                      },
                      child: Text(l10n.add),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: _profile.name);
    final titleController = TextEditingController(text: _profile.title);
    final locationController = TextEditingController(text: _profile.location);
    final websiteController = TextEditingController(text: _profile.website);
    final bioController = TextEditingController(text: _profile.bio);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(ctx).size.width * 0.9,
            maxHeight: MediaQuery.of(ctx).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.editIntroduction,
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              AppSpacing.vGap16,
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: l10n.fullName,
                          border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                        ),
                      ),
                      AppSpacing.vGap12,
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: l10n.jobTitle,
                          hintText: l10n.jobTitleHint,
                          border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                        ),
                      ),
                      AppSpacing.vGap12,
                      TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          labelText: l10n.locationLabel,
                          hintText: l10n.locationHint,
                          border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                        ),
                      ),
                      AppSpacing.vGap12,
                      TextField(
                        controller: websiteController,
                        decoration: InputDecoration(
                          labelText: l10n.websiteLabel,
                          hintText: l10n.websiteHint,
                          border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                        ),
                      ),
                      AppSpacing.vGap12,
                      TextField(
                        controller: bioController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: l10n.aboutYourself,
                          hintText: l10n.aboutYourselfHint,
                          border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.vGap16,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  AppSpacing.hGap12,
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          _profile = PortfolioProfile(
                            name: nameController.text,
                            title: titleController.text,
                            location: locationController.text,
                            website: websiteController.text,
                            bio: bioController.text,
                            socialLinks: _profile.socialLinks,
                          );
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text(l10n.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLayoutEditor(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => LayoutEditorDialog(
        sections: _sections,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex--;
            final item = _sections.removeAt(oldIndex);
            _sections.insert(newIndex, item);
          });
        },
        onToggleVisibility: (index) {
          setState(() {
            _sections[index] = _sections[index].copyWith(visible: !_sections[index].visible);
          });
        },
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
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

    showModalBottomSheet(
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
            Text(
              l10n.privacySettings,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
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
  // HELPER METHODS
  // ============================================================

  void _removeProject(int index) {
    setState(() => _projects.removeAt(index));
  }

  void _removeSkill(int index) {
    setState(() => _skills.removeAt(index));
  }

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
      MaterialPageRoute(
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
    final url = 'https://${_profile.website}';
    Clipboard.setData(ClipboardData(text: url));
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
    final url = 'https://${_profile.website}';
    Clipboard.setData(ClipboardData(text: url));
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
    // TODO: Implement PDF generation
  }
}
