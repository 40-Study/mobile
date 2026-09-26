import 'package:flutter/material.dart';
import 'package:study/features/student/bloc/portfolio/portfolio_state.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class AddExperienceDialog extends StatefulWidget {
  const AddExperienceDialog({super.key, required this.onAdd});

  final void Function(Experience) onAdd;

  @override
  State<AddExperienceDialog> createState() => _AddExperienceDialogState();
}

class _AddExperienceDialogState extends State<AddExperienceDialog> {
  final _positionController = TextEditingController();
  final _companyController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _positionController.dispose();
    _companyController.dispose();
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
                  l10n.addExperience,
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
              controller: _positionController,
              decoration: InputDecoration(
                labelText: l10n.position,
                hintText: l10n.positionHint,
                border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
              ),
            ),
            AppSpacing.vGap12,
            TextField(
              controller: _companyController,
              decoration: InputDecoration(
                labelText: l10n.company,
                hintText: l10n.companyHint,
                border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
              ),
            ),
            AppSpacing.vGap12,
            TextField(
              controller: _descController,
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
    if (_positionController.text.isEmpty) return;
    widget.onAdd(Experience(
      position: _positionController.text,
      company: _companyController.text,
      startDate: '${DateTime.now().month}/${DateTime.now().year}',
      description: _descController.text,
    ));
    Navigator.pop(context);
  }
}
