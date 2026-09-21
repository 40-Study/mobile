import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/account/account_cubit.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/bloc/profile/profile_cubit.dart';
import 'package:study/features/auth/bloc/profile/profile_state.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/edit_profile_screen.dart';
import 'package:study/features/auth/presentation/security_screen.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/parent/presentation/children/manage_children_screen.dart';
import 'package:study/features/parent/presentation/profile/widgets/widgets.dart';
import 'package:study/features/student/presentation/settings/help_center_screen.dart';
import 'package:study/features/student/presentation/settings/settings_screen.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
          );
        }
        return BlocProvider(
          create: (_) => ProfileCubit(
            authRepository: context.read<AuthRepository>(),
          )..loadProfiles(),
          child: _ProfileContent(
            user: state.user,
            activeProfile: state.activeProfile,
          ),
        );
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.user, this.activeProfile});

  final UserModel user;
  final ProfileModel? activeProfile;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Profile Card
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: ProfileCard(
                user: user,
                activeProfile: activeProfile,
                onEditProfile: () => _navigateToEditProfile(context),
              ),
            ),
            AppSpacing.vGap8,

            // Switch Profile
            _buildSwitchProfileSection(context),
            AppSpacing.vGap16,

            // Settings Container
            _buildSettingsContainer(context, cs, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchProfileSection(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSwitched && state.authResponse != null) {
          context.read<AuthBloc>().add(
            AuthProfileSwitched(state.authResponse!),
          );
        } else if (state is ProfileSwitchFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final profiles = switch (state) {
          ProfileLoaded(:final profiles) => profiles,
          ProfileSwitching(:final profiles) => profiles,
          ProfileSwitched(:final profiles) => profiles,
          ProfileSwitchFailure(:final profiles) => profiles,
          _ => <ProfileModel>[],
        };
        if (profiles.length <= 1) return const SizedBox.shrink();
        return SwitchProfileSection(
          profiles: profiles,
          activeProfile: activeProfile,
          isLoading: state is ProfileSwitching,
          switchingId: state is ProfileSwitching ? state.switchingProfileId : null,
          onProfileSelected: (profile) {
            context.read<ProfileCubit>().switchProfile(profile);
          },
        );
      },
    );
  }

  Widget _buildSettingsContainer(
    BuildContext context,
    ColorScheme cs,
    AppLocalizations l10n,
  ) {
    return Container(
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
          // Quản lý con
          SettingsSection(
            items: [
              SettingItem(
                icon: Icons.family_restroom_rounded,
                iconColor: AchievementColors.orange,
                title: 'Quản lý con',
                subtitle: 'Xem và liên kết hồ sơ con',
                onTap: () => _navigateToManageChildren(context),
              ),
            ],
          ),
          AppSpacing.vGap16,

          // Personal Settings
          SettingsSection(
            items: [
              SettingItem(
                icon: Icons.person_outline_rounded,
                iconColor: cs.primary,
                title: l10n.profileTitle,
                subtitle: l10n.updatePersonalDetails,
                onTap: () => _navigateToEditProfile(context),
              ),
              SettingItem(
                icon: Icons.shield_outlined,
                iconColor: cs.blue500,
                title: l10n.passwordAndSecurity,
                subtitle: l10n.passwordSecurityHint,
                onTap: () => _navigateToSecurity(context),
                showDivider: false,
              ),
            ],
          ),
          AppSpacing.vGap24,

          // General
          GeneralSection(
            onSettingsTap: () => _navigateToSettings(context),
            onHelpTap: () => _navigateToHelpCenter(context),
            onAboutTap: () {},
          ),
          AppSpacing.vGap24,

          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: LogoutTile(
              onTap: () => showLogoutConfirmation(context),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToManageChildren(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManageChildrenScreen()),
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

  void _navigateToHelpCenter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
    );
  }
}
