import 'package:flutter/material.dart';
import 'package:study/features/student/bloc/portfolio/portfolio_state.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class AddSkillDialog extends StatefulWidget {
  const AddSkillDialog({super.key, required this.onAdd});

  final void Function(Skill) onAdd;

  @override
  State<AddSkillDialog> createState() => _AddSkillDialogState();
}

class _AddSkillDialogState extends State<AddSkillDialog> {
  final _nameController = TextEditingController();
  var _level = 3;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
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
                  l10n.addSkill,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
              controller: _nameController,
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
                final isSelected = index < _level;
                return GestureDetector(
                  onTap: () => setState(() => _level = index + 1),
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
    if (_nameController.text.isEmpty) return;
    widget.onAdd(Skill(name: _nameController.text, level: _level));
    Navigator.pop(context);
  }
}
