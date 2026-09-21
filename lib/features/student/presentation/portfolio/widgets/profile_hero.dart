import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

import 'package:study/features/student/bloc/portfolio/portfolio_state.dart';
import 'social_button.dart';

class ProfileHero extends StatelessWidget {
  const ProfileHero({
    super.key,
    required this.profile,
    required this.isEditMode,
    this.onEdit,
  });

  final PortfolioProfile profile;
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
                        Icon(Icons.link, size: 16, color: cs.primary),
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
                    child: SocialButton(type: link.type),
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
