import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

import 'package:study/features/student/bloc/portfolio/portfolio_state.dart';
import 'portfolio_section_header.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({
    super.key,
    required this.projects,
    required this.isEditMode,
    required this.visible,
    required this.onToggleVisibility,
    this.onAddProject,
    this.onRemoveProject,
  });

  final List<Project> projects;
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
          PortfolioSectionHeader(
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
                separatorBuilder: (_, __) => AppSpacing.hGap12,
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

  final Project project;
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
