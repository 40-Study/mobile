import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  bool _isEditMode = true;

  // Mock data
  _PortfolioProfile _profile = const _PortfolioProfile(
    name: 'Linh Nguyen',
    title: 'UI/UX Designer',
    location: 'Hà Nội, Việt Nam',
    website: 'linhnguyen.design',
    bio:
        'Mình là UI/UX Designer với niềm đam mê tạo ra những trải nghiệm số đẹp mắt, hữu ích và dễ sử dụng.',
    socialLinks: [
      _SocialLink(type: 'dribbble', url: ''),
      _SocialLink(type: 'behance', url: ''),
      _SocialLink(type: 'linkedin', url: ''),
      _SocialLink(type: 'github', url: ''),
    ],
  );

  final _stats = const _PortfolioStats(
    yearsExperience: '3+',
    projectsCompleted: 18,
    certificates: 12,
    followers: 120,
  );

  // Section titles set in build via l10n
  late List<_PortfolioSection> _sections;
  bool _sectionsInitialized = false;

  void _initSections(AppLocalizations l10n) {
    if (_sectionsInitialized) return;
    _sections = [
      _PortfolioSection(id: 'intro', title: l10n.introduction, visible: true),
      _PortfolioSection(id: 'projects', title: l10n.featuredProjects, visible: true),
      _PortfolioSection(id: 'skills', title: l10n.skills, visible: true),
      _PortfolioSection(id: 'experience', title: l10n.experience, visible: true),
    ];
    _sectionsInitialized = true;
  }

  final List<_Project> _projects = [
    const _Project(
      title: 'EduFlow',
      subtitle: 'Hệ thống quản lý học tập',
      description: 'Thiết kế hệ thống dashboard và trải nghiệm học tập toàn diện.',
      category: 'UI/UX DESIGN',
      tool: 'Figma',
      year: '2024',
    ),
    const _Project(
      title: 'Mindora',
      subtitle: 'Ứng dụng thiền và thư giãn',
      description: 'Thiết kế ứng dụng giúp người dùng thiền định và theo dõi thói quen.',
      category: 'MOBILE APP',
      tool: 'Figma',
      year: '2023',
    ),
    const _Project(
      title: 'GreenSpace',
      subtitle: 'Website thương hiệu',
      description: 'Thiết kế website giới thiệu sản phẩm và thương hiệu thân thiện.',
      category: 'WEBSITE',
      tool: 'Figma',
      year: '2023',
    ),
  ];

  final List<_Skill> _skills = [
    const _Skill(name: 'UI Design', level: 5),
    const _Skill(name: 'UX Research', level: 3),
    const _Skill(name: 'Prototyping', level: 4),
    const _Skill(name: 'Interaction Design', level: 4),
    const _Skill(name: 'Figma', level: 5),
    const _Skill(name: 'Design System', level: 4),
    const _Skill(name: 'Wireframing', level: 4),
    const _Skill(name: 'Usability Testing', level: 3),
  ];

  final List<_Experience> _experiences = [
    const _Experience(
      position: 'Senior UI/UX Designer',
      company: 'Vela Creative Studio',
      startDate: '03/2022',
      endDate: null,
      description:
          'Thiết kế sản phẩm số cho khách hàng trong lĩnh vực edtech, fintech và healthtech. Dẫn dắt team 4 designer trong các dự án lớn.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    _initSections(l10n);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // AppBar
                SliverAppBar(
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
                    // Edit/Preview toggle
                    _ModeToggleButton(
                      isEditMode: _isEditMode,
                      onToggle: () => setState(() => _isEditMode = !_isEditMode),
                    ),
                    AppSpacing.hGap8,
                    // Layout editor button (only in edit mode)
                    if (_isEditMode)
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
                    if (_isEditMode) AppSpacing.hGap8,
                    // More menu
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
                ),

                // Profile Hero
                SliverToBoxAdapter(
                  child: _ProfileHero(
                    profile: _profile,
                    isEditMode: _isEditMode,
                    onEdit: () => _showEditProfileDialog(context),
                  ),
                ),

                const SliverToBoxAdapter(child: AppSpacing.vGap24),

                // Dynamic sections based on order
                ..._sections.asMap().entries.expand((entry) {
                  final index = entry.key;
                  final section = entry.value;
                  return [
                    SliverToBoxAdapter(
                      child: _buildSection(context, section, index),
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
      // FAB for adding sections
      floatingActionButton: _isEditMode
          ? FloatingActionButton(
              onPressed: () => _showAddSectionSheet(context),
              backgroundColor: cs.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

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
            _AddSectionTile(
              icon: Icons.folder_outlined,
              title: l10n.addProject,
              onTap: () {
                Navigator.pop(context);
                _showAddProjectDialog(context);
              },
            ),
            _AddSectionTile(
              icon: Icons.work_outline,
              title: l10n.addExperience,
              onTap: () {
                Navigator.pop(context);
                _showAddExperienceDialog(context);
              },
            ),
            _AddSectionTile(
              icon: Icons.school_outlined,
              title: l10n.addEducation,
              onTap: () {
                Navigator.pop(context);
                _showAddExperienceDialog(context);
              },
            ),
            _AddSectionTile(
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
                  initialValue: category,
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
                              _projects.add(_Project(
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
                                _skills.add(_Skill(name: nameController.text, level: level));
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
                            _experiences.add(_Experience(
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

  void _removeSkill(int index) {
    setState(() {
      _skills.removeAt(index);
    });
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
                          _profile = _PortfolioProfile(
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

  void _removeProject(int index) {
    setState(() {
      _projects.removeAt(index);
    });
  }

  Widget _buildSection(BuildContext context, _PortfolioSection section, int index) {
    switch (section.id) {
      case 'intro':
        return _IntroSection(
          stats: _stats,
          isEditMode: _isEditMode,
          visible: section.visible,
          onToggleVisibility: () {
            setState(() => _sections[index].visible = !_sections[index].visible);
          },
        );
      case 'projects':
        return _ProjectsSection(
          projects: _projects,
          isEditMode: _isEditMode,
          visible: section.visible,
          onToggleVisibility: () {
            setState(() => _sections[index].visible = !_sections[index].visible);
          },
          onAddProject: () => _showAddProjectDialog(context),
          onRemoveProject: _removeProject,
        );
      case 'skills':
        return _SkillsSection(
          skills: _skills,
          isEditMode: _isEditMode,
          visible: section.visible,
          onToggleVisibility: () {
            setState(() => _sections[index].visible = !_sections[index].visible);
          },
          onAddSkill: () => _showAddSkillDialog(context),
          onRemoveSkill: _removeSkill,
        );
      case 'experience':
        return _ExperienceSection(
          experiences: _experiences,
          isEditMode: _isEditMode,
          visible: section.visible,
          onToggleVisibility: () {
            setState(() => _sections[index].visible = !_sections[index].visible);
          },
          onAddExperience: () => _showAddExperienceDialog(context),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showLayoutEditor(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _LayoutEditorDialog(
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
            _sections[index].visible = !_sections[index].visible;
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
            // Preview
            _MenuTile(
              icon: Icons.visibility_outlined,
              iconColor: cs.primary,
              title: l10n.previewPortfolio,
              subtitle: l10n.viewAsOthers,
              onTap: () {
                Navigator.pop(ctx);
                _openPreview(context);
              },
            ),
            // Share
            _MenuTile(
              icon: Icons.share_outlined,
              iconColor: AchievementColors.blue,
              title: l10n.share,
              subtitle: l10n.shareOnSocial,
              onTap: () {
                Navigator.pop(ctx);
                _sharePortfolio(context);
              },
            ),
            // Copy link
            _MenuTile(
              icon: Icons.link,
              iconColor: AchievementColors.green,
              title: l10n.copyLink,
              subtitle: l10n.copyPortfolioLink,
              onTap: () {
                Navigator.pop(ctx);
                _copyLink(context);
              },
            ),
            // Download PDF
            _MenuTile(
              icon: Icons.download_outlined,
              iconColor: AchievementColors.orange,
              title: l10n.downloadPdf,
              subtitle: l10n.downloadPortfolioPdf,
              onTap: () {
                Navigator.pop(ctx);
                _downloadPdf(context);
              },
            ),
            // Visibility settings
            _MenuTile(
              icon: Icons.lock_outline,
              iconColor: cs.onSurfaceVariant,
              title: l10n.privacySettings,
              subtitle: _getVisibilityText(l10n),
              trailing: _VisibilityBadge(visibility: _visibility),
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

  String _visibility = 'public';

  String _getVisibilityText(AppLocalizations l10n) {
    switch (_visibility) {
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
        builder: (_) => _PortfolioPreviewScreen(
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
            _VisibilityOption(
              icon: Icons.public,
              title: l10n.publicPortfolio,
              subtitle: l10n.everyoneCanView,
              isSelected: _visibility == 'public',
              onTap: () {
                setState(() => _visibility = 'public');
                Navigator.pop(ctx);
              },
            ),
            _VisibilityOption(
              icon: Icons.link,
              title: l10n.linkOnlyPortfolio,
              subtitle: l10n.onlyWithLink,
              isSelected: _visibility == 'link',
              onTap: () {
                setState(() => _visibility = 'link');
                Navigator.pop(ctx);
              },
            ),
            _VisibilityOption(
              icon: Icons.lock_outline,
              title: l10n.privatePortfolio,
              subtitle: l10n.onlyYouCanView,
              isSelected: _visibility == 'private',
              onTap: () {
                setState(() => _visibility = 'private');
                Navigator.pop(ctx);
              },
            ),
            AppSpacing.vGap16,
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MENU TILE
// ============================================================
class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: AppRadius.borderSm,
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
    );
  }
}

// ============================================================
// VISIBILITY BADGE
// ============================================================
class _VisibilityBadge extends StatelessWidget {
  const _VisibilityBadge({required this.visibility});

  final String visibility;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    IconData icon;
    Color color;
    String text;

    switch (visibility) {
      case 'public':
        icon = Icons.public;
        color = AchievementColors.green;
        text = l10n.publicPortfolio;
        break;
      case 'link':
        icon = Icons.link;
        color = AchievementColors.blue;
        text = l10n.linkOnlyPortfolio;
        break;
      case 'private':
        icon = Icons.lock;
        color = cs.onSurfaceVariant;
        text = l10n.privatePortfolio;
        break;
      default:
        icon = Icons.public;
        color = AchievementColors.green;
        text = l10n.publicPortfolio;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: tt.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// VISIBILITY OPTION
// ============================================================
class _VisibilityOption extends StatelessWidget {
  const _VisibilityOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? cs.primary.withValues(alpha: 0.1) : cs.surfaceContainerHighest,
          borderRadius: AppRadius.borderSm,
        ),
        child: Icon(
          icon,
          color: isSelected ? cs.primary : cs.onSurfaceVariant,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: tt.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: isSelected ? cs.primary : cs.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: cs.primary)
          : Icon(Icons.circle_outlined, color: cs.outlineVariant),
    );
  }
}

// ============================================================
// PORTFOLIO PREVIEW SCREEN
// ============================================================
class _PortfolioPreviewScreen extends StatelessWidget {
  const _PortfolioPreviewScreen({
    required this.profile,
    required this.stats,
    required this.sections,
    required this.projects,
    required this.skills,
    required this.experiences,
  });

  final _PortfolioProfile profile;
  final _PortfolioStats stats;
  final List<_PortfolioSection> sections;
  final List<_Project> projects;
  final List<_Skill> skills;
  final List<_Experience> experiences;

  Widget _buildPreviewSection(_PortfolioSection section) {
    switch (section.id) {
      case 'intro':
        return _IntroSection(
          stats: stats,
          isEditMode: false,
          visible: true,
          onToggleVisibility: () {},
        );
      case 'projects':
        return _ProjectsSection(
          projects: projects,
          isEditMode: false,
          visible: true,
          onToggleVisibility: () {},
        );
      case 'skills':
        return _SkillsSection(
          skills: skills,
          isEditMode: false,
          visible: true,
          onToggleVisibility: () {},
        );
      case 'experience':
        return _ExperienceSection(
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
    final tt = Theme.of(context).textTheme;
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
              _ProfileHero(profile: profile, isEditMode: false),
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

// ============================================================
// MODE TOGGLE BUTTON
// ============================================================
class _ModeToggleButton extends StatelessWidget {
  const _ModeToggleButton({
    required this.isEditMode,
    required this.onToggle,
  });

  final bool isEditMode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isEditMode ? cs.primary.withValues(alpha: 0.1) : cs.surface,
          borderRadius: AppRadius.borderFull,
          border: Border.all(
            color: isEditMode ? cs.primary : cs.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isEditMode ? Icons.edit_outlined : Icons.visibility_outlined,
              size: 16,
              color: isEditMode ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              isEditMode ? l10n.editPortfolio : l10n.previewPortfolio,
              style: tt.labelMedium?.copyWith(
                color: isEditMode ? cs.primary : cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PROFILE HERO
// ============================================================
class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.profile,
    required this.isEditMode,
    this.onEdit,
  });

  final _PortfolioProfile profile;
  final bool isEditMode;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.2),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 47,
                      backgroundColor: cs.primaryContainer,
                      child: Text(
                        'LN',
                        style: tt.headlineMedium?.copyWith(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (isEditMode)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: cs.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.surface, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              AppSpacing.hGap16,
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      profile.title,
                      style: tt.bodyLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    AppSpacing.vGap8,
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16, color: cs.onSurfaceVariant),
                        AppSpacing.hGap4,
                        Flexible(
                          child: Text(
                            profile.location,
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGap4,
                    Row(
                      children: [
                        Icon(Icons.link,
                            size: 16, color: cs.primary),
                        AppSpacing.hGap4,
                        Text(
                          profile.website,
                          style: tt.bodySmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vGap16,
          // Bio
          Text(
            profile.bio,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          AppSpacing.vGap16,
          // Social links
          Row(
            children: [
              ...profile.socialLinks.map((link) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: _SocialButton(type: link.type),
                  )),
              const Spacer(),
              if (isEditMode && onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderSm,
                      border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Icons.edit, size: 18, color: cs.primary),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SOCIAL BUTTON
// ============================================================
class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.type});

  final String type;

  IconData get _icon {
    switch (type) {
      case 'dribbble':
        return Icons.sports_basketball;
      case 'behance':
        return Icons.brush;
      case 'linkedin':
        return Icons.business_center;
      case 'github':
        return Icons.code;
      default:
        return Icons.link;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Icon(_icon, size: 18, color: cs.onSurface),
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================
class _PortfolioSectionHeader extends StatelessWidget {
  const _PortfolioSectionHeader({
    required this.title,
    required this.visible,
    required this.isEditMode,
    required this.onToggleVisibility,
  });

  final String title;
  final bool visible;
  final bool isEditMode;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          if (isEditMode) ...[
            Icon(Icons.drag_indicator, size: 20, color: cs.onSurfaceVariant),
            AppSpacing.hGap8,
          ],
          Text(
            title,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: visible ? cs.onSurface : cs.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          if (isEditMode) ...[
            Switch.adaptive(
              value: visible,
              onChanged: (_) => onToggleVisibility(),
              activeColor: cs.primary,
            ),
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            AppSpacing.hGap4,
            Icon(Icons.more_horiz, size: 20, color: cs.onSurfaceVariant),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// INTRO SECTION
// ============================================================
class _IntroSection extends StatelessWidget {
  const _IntroSection({
    required this.stats,
    required this.isEditMode,
    required this.visible,
    required this.onToggleVisibility,
  });

  final _PortfolioStats stats;
  final bool isEditMode;
  final bool visible;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: Column(
        children: [
          _PortfolioSectionHeader(
            title: l10n.introduction,
            visible: visible,
            isEditMode: isEditMode,
            onToggleVisibility: onToggleVisibility,
          ),
          if (visible) ...[
            AppSpacing.vGap12,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: AppRadius.borderLg,
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    _StatItem(
                      icon: Icons.work_outline,
                      iconColor: cs.primary,
                      value: stats.yearsExperience,
                      label: l10n.yearsExperience,
                    ),
                    _StatDivider(),
                    _StatItem(
                      icon: Icons.folder_outlined,
                      iconColor: AchievementColors.green,
                      value: stats.projectsCompleted.toString(),
                      label: l10n.projectsCompleted,
                    ),
                    _StatDivider(),
                    _StatItem(
                      icon: Icons.emoji_events_outlined,
                      iconColor: AchievementColors.orange,
                      value: stats.certificates.toString(),
                      label: l10n.certificate,
                    ),
                    _StatDivider(),
                    _StatItem(
                      icon: Icons.favorite_outline,
                      iconColor: Colors.pink,
                      value: '${stats.followers}+',
                      label: l10n.followers,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          AppSpacing.vGap8,
          Text(
            value,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            label,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 1,
      height: 40,
      color: cs.outlineVariant.withValues(alpha: 0.5),
    );
  }
}

// ============================================================
// PROJECTS SECTION
// ============================================================
class _ProjectsSection extends StatelessWidget {
  const _ProjectsSection({
    required this.projects,
    required this.isEditMode,
    required this.visible,
    required this.onToggleVisibility,
    this.onAddProject,
    this.onRemoveProject,
  });

  final List<_Project> projects;
  final bool isEditMode;
  final bool visible;
  final VoidCallback onToggleVisibility;
  final VoidCallback? onAddProject;
  final void Function(int index)? onRemoveProject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: Column(
        children: [
          _PortfolioSectionHeader(
            title: l10n.featuredProjects,
            visible: visible,
            isEditMode: isEditMode,
            onToggleVisibility: onToggleVisibility,
          ),
          if (visible) ...[
            AppSpacing.vGap12,
            SizedBox(
              height: 280,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                itemCount: projects.length,
                separatorBuilder: (_, _) => AppSpacing.hGap12,
                itemBuilder: (context, index) => _ProjectCard(
                  project: projects[index],
                  isEditMode: isEditMode,
                  onRemove: isEditMode && onRemoveProject != null
                      ? () => onRemoveProject!(index)
                      : null,
                ),
              ),
            ),
            if (isEditMode) ...[
              AppSpacing.vGap12,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: OutlinedButton.icon(
                  onPressed: onAddProject,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.addProject),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderMd,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    this.isEditMode = false,
    this.onRemove,
  });

  final _Project project;
  final bool isEditMode;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(Icons.image, size: 40, color: cs.onSurfaceVariant),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Text(
                      project.category,
                      style: tt.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                // Delete button in edit mode
                if (isEditMode && onRemove != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: cs.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${project.title} – ${project.subtitle}',
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vGap4,
                Text(
                  project.description,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vGap8,
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Text(
                        project.tool,
                        style: tt.labelSmall,
                      ),
                    ),
                    AppSpacing.hGap8,
                    Text(
                      project.year,
                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const Spacer(),
                    Icon(Icons.open_in_new, size: 16, color: cs.onSurfaceVariant),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SKILLS SECTION
// ============================================================
class _SkillsSection extends StatelessWidget {
  const _SkillsSection({
    required this.skills,
    required this.isEditMode,
    required this.visible,
    required this.onToggleVisibility,
    this.onAddSkill,
    this.onRemoveSkill,
  });

  final List<_Skill> skills;
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
          _PortfolioSectionHeader(
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

  final _Skill skill;
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
                  color: index < skill.level
                      ? cs.primary
                      : cs.outlineVariant,
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

// ============================================================
// EXPERIENCE SECTION
// ============================================================
class _ExperienceSection extends StatelessWidget {
  const _ExperienceSection({
    required this.experiences,
    required this.isEditMode,
    required this.visible,
    required this.onToggleVisibility,
    this.onAddExperience,
  });

  final List<_Experience> experiences;
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
          _PortfolioSectionHeader(
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

  final _Experience experience;

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

// ============================================================
// ADD SECTION TILE
// ============================================================
class _AddSectionTile extends StatelessWidget {
  const _AddSectionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.1),
          borderRadius: AppRadius.borderSm,
        ),
        child: Icon(icon, color: cs.primary, size: 20),
      ),
      title: Text(title, style: tt.bodyLarge),
      trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
    );
  }
}

// ============================================================
// LAYOUT EDITOR DIALOG
// ============================================================
class _LayoutEditorDialog extends StatefulWidget {
  const _LayoutEditorDialog({
    required this.sections,
    required this.onReorder,
    required this.onToggleVisibility,
  });

  final List<_PortfolioSection> sections;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int index) onToggleVisibility;

  @override
  State<_LayoutEditorDialog> createState() => _LayoutEditorDialogState();
}

class _LayoutEditorDialogState extends State<_LayoutEditorDialog> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.grid_view, color: cs.primary),
                AppSpacing.hGap12,
                Expanded(
                  child: Text(
                    l10n.manageLayout,
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            AppSpacing.vGap8,
            Text(
              l10n.dragToReorder,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            AppSpacing.vGap16,
            // Reorderable list
            Flexible(
              child: ReorderableListView.builder(
                shrinkWrap: true,
                itemCount: widget.sections.length,
                onReorder: (oldIndex, newIndex) {
                  widget.onReorder(oldIndex, newIndex);
                  setState(() {});
                },
                proxyDecorator: (child, index, animation) {
                  return Material(
                    elevation: 4,
                    borderRadius: AppRadius.borderMd,
                    child: child,
                  );
                },
                itemBuilder: (context, index) {
                  final section = widget.sections[index];
                  return _LayoutSectionTile(
                    key: ValueKey(section.id),
                    index: index,
                    title: section.title,
                    visible: section.visible,
                    onToggle: () {
                      widget.onToggleVisibility(index);
                      setState(() {});
                    },
                  );
                },
              ),
            ),
            AppSpacing.vGap16,
            // Done button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.done),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayoutSectionTile extends StatelessWidget {
  const _LayoutSectionTile({
    super.key,
    required this.index,
    required this.title,
    required this.visible,
    required this.onToggle,
  });

  final int index;
  final String title;
  final bool visible;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: visible ? cs.surface : cs.surfaceContainerHighest,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: visible ? cs.primary.withValues(alpha: 0.3) : cs.outlineVariant,
          width: visible ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Drag handle - touch to drag instantly
          ReorderableDragStartListener(
            index: index,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: AppRadius.borderSm,
              ),
              child: Icon(
                Icons.drag_indicator,
                color: cs.primary,
                size: 24,
              ),
            ),
          ),
          AppSpacing.hGap16,
          Expanded(
            child: Text(
              title,
              style: tt.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: visible ? cs.onSurface : cs.onSurfaceVariant,
              ),
            ),
          ),
          Switch.adaptive(
            value: visible,
            onChanged: (_) => onToggle(),
            activeColor: cs.primary,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DATA MODELS
// ============================================================
class _PortfolioProfile {
  const _PortfolioProfile({
    required this.name,
    required this.title,
    required this.location,
    required this.website,
    required this.bio,
    required this.socialLinks,
  });

  final String name;
  final String title;
  final String location;
  final String website;
  final String bio;
  final List<_SocialLink> socialLinks;
}

class _SocialLink {
  const _SocialLink({required this.type, required this.url});

  final String type;
  final String url;
}

class _PortfolioStats {
  const _PortfolioStats({
    required this.yearsExperience,
    required this.projectsCompleted,
    required this.certificates,
    required this.followers,
  });

  final String yearsExperience;
  final int projectsCompleted;
  final int certificates;
  final int followers;
}

class _PortfolioSection {
  _PortfolioSection({
    required this.id,
    required this.title,
    required this.visible,
  });

  final String id;
  final String title;
  bool visible;
}

class _Project {
  const _Project({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.tool,
    required this.year,
  });

  final String title;
  final String subtitle;
  final String description;
  final String category;
  final String tool;
  final String year;
}

class _Skill {
  const _Skill({required this.name, required this.level});

  final String name;
  final int level;
}

class _Experience {
  const _Experience({
    required this.position,
    required this.company,
    required this.startDate,
    this.endDate,
    required this.description,
  });

  final String position;
  final String company;
  final String startDate;
  final String? endDate;
  final String description;
}
