import 'package:flutter/material.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class SwitchProfileSection extends StatelessWidget {
  const SwitchProfileSection({
    super.key,
    required this.profiles,
    this.activeProfile,
    this.isLoading = false,
    this.switchingId,
    required this.onProfileSelected,
  });

  final List<ProfileModel> profiles;
  final ProfileModel? activeProfile;
  final bool isLoading;
  final String? switchingId;
  final ValueChanged<ProfileModel> onProfileSelected;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            l10n.switchProfile,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        AppSpacing.vGap12,
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: profiles.length,
            separatorBuilder: (_, __) => AppSpacing.hGap12,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              final isSelected = activeProfile?.id == profile.id;
              final isSwitching = switchingId == profile.id;
              return ProfileSwitcherCard(
                profile: profile,
                isSelected: isSelected,
                isLoading: isSwitching,
                onTap: isLoading ? null : () => onProfileSelected(profile),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProfileSwitcherCard extends StatelessWidget {
  const ProfileSwitcherCard({
    super.key,
    required this.profile,
    required this.isSelected,
    this.isLoading = false,
    this.onTap,
  });

  final ProfileModel profile;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final displayName = profile.displayName ?? profile.roleName;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 115,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary.withValues(alpha: 0.05) : cs.surface,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: isSelected
                ? cs.primary
                : cs.outlineVariant.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? cs.primary.withValues(alpha: 0.1)
                        : cs.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : Icon(
                          _getRoleIcon(profile.roleName),
                          size: 28,
                          color: isSelected ? cs.primary : cs.onSurfaceVariant,
                        ),
                ),
                if (isSelected && !isLoading)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.surface, width: 2),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            AppSpacing.vGap8,
            Text(
              displayName,
              style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (profile.organizationName != null)
              Text(
                profile.organizationName!,
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon(String roleName) {
    return switch (roleName.toUpperCase()) {
      'TEACHER' => Icons.school_outlined,
      'STUDENT' => Icons.person_outline,
      'ADMIN' => Icons.admin_panel_settings_outlined,
      'PARENT' => Icons.family_restroom_outlined,
      _ => Icons.badge_outlined,
    };
  }
}
