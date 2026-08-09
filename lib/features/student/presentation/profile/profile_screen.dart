import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/account/account_cubit.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/data/models/user_model.dart';
import 'package:study/features/auth/presentation/edit_profile_screen.dart';
import 'package:study/features/auth/presentation/security_screen.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/student/presentation/portfolio/portfolio_screen.dart';
import 'package:study/features/student/presentation/settings/settings_screen.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
          );
        }
        return _ProfileContent(user: state.user);
      },
    );
  }
}

class _ProfileContent extends StatefulWidget {
  const _ProfileContent({required this.user});

  final UserModel user;

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  int _selectedProfileIndex = 0;

  // Mock profiles for demo
  late final List<_ProfileData> _profiles = [
    _ProfileData(
      id: '1',
      name: widget.user.fullName ?? 'User',
      email: widget.user.email,
      avatarUrl: widget.user.avatarUrl,
      isPremium: true,
    ),
    _ProfileData(
      id: '2',
      name: 'Minh Tran',
      email: 'minh.tran@email.com',
    ),
    _ProfileData(
      id: '3',
      name: 'An Tran',
      email: 'an.tran@email.com',
    ),
  ];

  _ProfileData get _currentProfile => _profiles[_selectedProfileIndex];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.profileTitle),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Top section - Profile Card
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: _CurrentProfileCard(
              profile: _currentProfile,
              onEditProfile: () => _navigateToEditProfile(context),
            ),
          ),
          AppSpacing.vGap8,
          _SwitchProfileSection(
            profiles: _profiles,
            selectedIndex: _selectedProfileIndex,
            onProfileSelected: (index) {
              setState(() => _selectedProfileIndex = index);
            },
            onAddProfile: () {},
          ),
          AppSpacing.vGap16,

          // Bottom section - Settings with layer background
          Container(
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                cs.primary.withValues(
                  alpha: Theme.of(context).brightness == Brightness.light
                      ? 0.045
                      : 0.065,
                ),
                cs.surfaceContainer,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
              border: Border(
                top: BorderSide(color: cs.primary.withValues(alpha: 0.1)),
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.045),
                  blurRadius: 32,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(0, AppSpacing.xl, 0, 100),
            child: Column(
              children: [

                // Personal Settings
                _SettingsSection(
                  items: [
                    _SettingItem(
                      icon: Icons.person_outline_rounded,
                      iconColor: cs.primary,
                      title: l10n.profileTitle,
                      subtitle: l10n.updatePersonalDetails,
                      onTap: () => _navigateToEditProfile(context),
                    ),
                    _SettingItem(
                      icon: Icons.web_rounded,
                      iconColor: AchievementColors.purple,
                      title: l10n.portfolio,
                      subtitle: l10n.viewPortfolio,
                      onTap: () => _navigateToPortfolio(context),
                    ),
                    _SettingItem(
                      icon: Icons.shield_outlined,
                      iconColor: cs.blue500,
                      title: l10n.passwordAndSecurity,
                      subtitle: l10n.passwordSecurityHint,
                      onTap: () => _navigateToSecurity(context),
                    ),
                    _SettingItem(
                      icon: Icons.workspace_premium_outlined,
                      iconColor: AchievementColors.orange,
                      title: l10n.subscription,
                      subtitle: l10n.managePlanBilling,
                      onTap: () {},
                    ),
                    _SettingItem(
                      icon: Icons.notifications_outlined,
                      iconColor: cs.blue400,
                      title: l10n.notifications,
                      subtitle: l10n.customizeNotifications,
                      onTap: () {},
                    ),
                    _SettingItem(
                      icon: Icons.lock_outline_rounded,
                      iconColor: cs.slate500,
                      title: l10n.privacy,
                      subtitle: l10n.managePrivacySettings,
                      onTap: () {},
                      showDivider: false,
                    ),
                  ],
                ),

                AppSpacing.vGap24,

                // General Section
                _GeneralSection(
                  onLanguageTap: () => _navigateToSettings(context),
                  onDarkModeTap: () => _navigateToSettings(context),
                  onHelpTap: () {},
                  onAboutTap: () {},
                ),

                AppSpacing.vGap24,

                // Logout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: _LogoutTile(
                    onTap: () => _showLogoutConfirmation(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => AccountCubit(
            authRepository: context.read<AuthRepository>(),
          )..loadAccount(),
          child: const EditProfileScreen(),
        ),
      ),
    );
  }

  void _navigateToSecurity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SecurityScreen()),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _navigateToPortfolio(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PortfolioScreen()),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
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
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AppSpacing.vGap24,
            Icon(Icons.logout_rounded,
                size: 48, color: TogetherSemanticColors.error),
            AppSpacing.vGap16,
            Text(l10n.logout,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            AppSpacing.vGap8,
            Text(l10n.logoutConfirm,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center),
            AppSpacing.vGap24,
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
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<AuthBloc>().add(AuthLoggedOut());
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: TogetherSemanticColors.error,
                    ),
                    child: Text(l10n.logout),
                  ),
                ),
              ],
            ),
            AppSpacing.vGap16,
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PROFILE DATA MODEL
// ============================================================
class _ProfileData {
  const _ProfileData({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isPremium = false,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isPremium;
}

// ============================================================
// CURRENT PROFILE CARD
// ============================================================
class _CurrentProfileCard extends StatelessWidget {
  const _CurrentProfileCard({
    required this.profile,
    required this.onEditProfile,
  });

  final _ProfileData profile;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile info row
          Row(
            children: [
              // Avatar
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: cs.primaryContainer,
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child: profile.avatarUrl == null
                      ? Text(
                          _getInitials(profile.name),
                          style: tt.titleLarge?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
              ),
              AppSpacing.hGap16,
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.vGap4,
                    Text(
                      profile.email,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    AppSpacing.vGap8,
                    // Premium badge
                    if (profile.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AchievementColors.orange.withValues(alpha: 0.1),
                          borderRadius: AppRadius.borderFull,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: AchievementColors.orange,
                            ),
                            AppSpacing.hGap4,
                            Text(
                              l10n.premium,
                              style: tt.labelSmall?.copyWith(
                                color: AchievementColors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Edit button
              OutlinedButton.icon(
                onPressed: onEditProfile,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text(l10n.editProfile),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: tt.labelMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.substring(0, 2).toUpperCase();
  }
}

// ============================================================
// SWITCH PROFILE SECTION
// ============================================================
class _SwitchProfileSection extends StatelessWidget {
  const _SwitchProfileSection({
    required this.profiles,
    required this.selectedIndex,
    required this.onProfileSelected,
    required this.onAddProfile,
  });

  final List<_ProfileData> profiles;
  final int selectedIndex;
  final ValueChanged<int> onProfileSelected;
  final VoidCallback onAddProfile;

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
            itemCount: profiles.length + 1,
            separatorBuilder: (_, __) => AppSpacing.hGap12,
            itemBuilder: (context, index) {
              if (index == profiles.length) {
                return _AddProfileCard(onTap: onAddProfile);
              }
              return _ProfileSwitcherCard(
                profile: profiles[index],
                isSelected: index == selectedIndex,
                onTap: () => onProfileSelected(index),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProfileSwitcherCard extends StatelessWidget {
  const _ProfileSwitcherCard({
    required this.profile,
    required this.isSelected,
    required this.onTap,
  });

  final _ProfileData profile;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
            color: isSelected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.4),
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
                CircleAvatar(
                  radius: 28,
                  backgroundColor: cs.primaryContainer,
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child: profile.avatarUrl == null
                      ? Text(
                          _getInitials(profile.name),
                          style: tt.titleSmall?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
                if (isSelected)
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
              profile.name,
              style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              profile.isPremium
                  ? AppLocalizations.of(context)!.premium
                  : AppLocalizations.of(context)!.student,
              style: tt.labelSmall?.copyWith(
                color: profile.isPremium
                    ? AchievementColors.orange
                    : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.substring(0, 2).toUpperCase();
  }
}

class _AddProfileCard extends StatelessWidget {
  const _AddProfileCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: cs.outlineVariant,
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Icons.add,
                color: cs.onSurfaceVariant,
                size: 24,
              ),
            ),
            AppSpacing.vGap8,
            Text(
              l10n.addProfile,
              style: tt.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SETTINGS SECTION
// ============================================================
class _SettingItem {
  const _SettingItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.items});

  final List<_SettingItem> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.borderXl,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: items.map((item) {
            return _SettingsTile(
              icon: item.icon,
              iconColor: item.iconColor,
              title: item.title,
              subtitle: item.subtitle,
              onTap: item.onTap,
              showDivider: item.showDivider,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: showDivider ? null : AppRadius.borderLg,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: tt.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 68),
            child: Divider(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
      ],
    );
  }
}

// ============================================================
// GENERAL SECTION
// ============================================================
class _GeneralSection extends StatelessWidget {
  const _GeneralSection({
    required this.onLanguageTap,
    required this.onDarkModeTap,
    required this.onHelpTap,
    required this.onAboutTap,
  });

  final VoidCallback onLanguageTap;
  final VoidCallback onDarkModeTap;
  final VoidCallback onHelpTap;
  final VoidCallback onAboutTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.general,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          AppSpacing.vGap12,
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: AppRadius.borderLg,
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                _GeneralTile(
                  icon: Icons.settings_outlined,
                  iconColor: AchievementColors.green,
                  title: l10n.settingsTitle,
                  value: l10n.appearanceTitle,
                  onTap: onLanguageTap,
                ),
                _GeneralTile(
                  icon: Icons.dark_mode_outlined,
                  iconColor: cs.slate600,
                  title: l10n.darkThemeSettingsItemTitle,
                  value: l10n.darkThemeFollowSystemSettingsItemTitle,
                  onTap: onDarkModeTap,
                ),
                _GeneralTile(
                  icon: Icons.help_outline_rounded,
                  iconColor: cs.blue500,
                  title: l10n.helpCenter,
                  value: l10n.faqAndSupport,
                  onTap: onHelpTap,
                ),
                _GeneralTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: cs.slate400,
                  title: l10n.aboutSettingsItem,
                  value: l10n.version('1.2.0'),
                  onTap: onAboutTap,
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneralTile extends StatelessWidget {
  const _GeneralTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: tt.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        value,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 68),
            child: Divider(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
      ],
    );
  }
}

// ============================================================
// LOGOUT TILE
// ============================================================
class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final errorColor = TogetherSemanticColors.error;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderLg,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: errorColor.withValues(alpha: 0.05),
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: errorColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.1),
                borderRadius: AppRadius.borderSm,
              ),
              child: Icon(Icons.logout_rounded, size: 20, color: errorColor),
            ),
            AppSpacing.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.logout,
                    style: tt.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: errorColor,
                    ),
                  ),
                  Text(
                    l10n.signOutHint,
                    style: tt.bodySmall?.copyWith(
                      color: errorColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
