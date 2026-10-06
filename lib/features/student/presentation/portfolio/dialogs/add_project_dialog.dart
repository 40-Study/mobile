import 'package:flutter/material.dart';
import 'package:study/features/student/bloc/portfolio/portfolio_state.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class AddProjectDialog extends StatefulWidget {
  const AddProjectDialog({super.key, required this.onAdd});

  final void Function(Project) onAdd;

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descController = TextEditingController();
  var _category = 'UI/UX DESIGN';

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                  l10n.addProject,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            AppSpacing.vGap16,
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.projectName,
                hintText: l10n.projectNameHint,
                border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
              ),
            ),
            AppSpacing.vGap12,
            TextField(
              controller: _subtitleController,
              decoration: InputDecoration(
                labelText: l10n.shortDescription,
                hintText: l10n.shortDescriptionHint,
                border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
              ),
            ),
            AppSpacing.vGap12,
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.details,
                border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
              ),
            ),
            AppSpacing.vGap12,
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(
                labelText: l10n.categoryLabel,
                border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
              ),
              items: ['UI/UX DESIGN', 'MOBILE APP', 'WEBSITE', 'BRANDING']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            AppSpacing.vGap16,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: FilledButton(
                    onPressed: _submit,
                    child: Text(l10n.add),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_titleController.text.isEmpty) return;
    widget.onAdd(Project(
      title: _titleController.text,
      subtitle: _subtitleController.text,
      description: _descController.text,
      category: _category,
      tool: 'Figma',
      year: DateTime.now().year.toString(),
    ));
    Navigator.pop(context);
  }
}
