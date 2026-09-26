import 'package:flutter/material.dart';
import 'package:study/features/student/bloc/portfolio/portfolio_state.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({
    super.key,
    required this.profile,
    required this.onSave,
  });

  final PortfolioProfile profile;
  final void Function(PortfolioProfile) onSave;

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _websiteController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _titleController = TextEditingController(text: widget.profile.title);
    _locationController = TextEditingController(text: widget.profile.location);
    _websiteController = TextEditingController(text: widget.profile.website);
    _bioController = TextEditingController(text: widget.profile.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
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
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.fullName,
                        border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                      ),
                    ),
                    AppSpacing.vGap12,
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: l10n.jobTitle,
                        hintText: l10n.jobTitleHint,
                        border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                      ),
                    ),
                    AppSpacing.vGap12,
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: l10n.locationLabel,
                        hintText: l10n.locationHint,
                        border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                      ),
                    ),
                    AppSpacing.vGap12,
                    TextField(
                      controller: _websiteController,
                      decoration: InputDecoration(
                        labelText: l10n.websiteLabel,
                        hintText: l10n.websiteHint,
                        border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                      ),
                    ),
                    AppSpacing.vGap12,
                    TextField(
                      controller: _bioController,
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
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: FilledButton(
                    onPressed: _submit,
                    child: Text(l10n.save),
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
    widget.onSave(PortfolioProfile(
      name: _nameController.text,
      title: _titleController.text,
      location: _locationController.text,
      website: _websiteController.text,
      bio: _bioController.text,
      socialLinks: widget.profile.socialLinks,
    ));
    Navigator.pop(context);
  }
}
