import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

import 'package:study/features/student/bloc/portfolio/portfolio_state.dart';

class LayoutEditorDialog extends StatefulWidget {
  const LayoutEditorDialog({
    super.key,
    required this.sections,
    required this.onReorder,
    required this.onToggleVisibility,
  });

  final List<PortfolioSection> sections;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int index) onToggleVisibility;

  @override
  State<LayoutEditorDialog> createState() => _LayoutEditorDialogState();
}

class _LayoutEditorDialogState extends State<LayoutEditorDialog> {
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
          // Drag handle
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
