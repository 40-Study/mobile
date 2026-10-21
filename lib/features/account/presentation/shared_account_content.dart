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
import 'package:study/features/parent/presentation/profile/widgets/widgets.dart';
import 'package:study/features/student/presentation/settings/help_center_screen.dart';
import 'package:study/features/student/presentation/settings/settings_screen.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

/// Shared identity and account actions. Role wrappers supply only their own
/// optional settings; teaching, organization and learning state stay outside.
class SharedAccountContent extends StatelessWidget {
  const SharedAccountContent({super.key, this.header, this.roleSettings});

  final Widget? header;
  final List<SettingItem> Function(BuildContext)? roleSettings;

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthBloc, AuthState>(
    builder: (context, auth) {
      if (auth is! AuthAuthenticated) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return BlocProvider(
        create: (_) =>
            ProfileCubit(authRepository: context.read<AuthRepository>())
              ..loadProfiles(),
        child: _AccountBody(
          user: auth.user,
          activeProfile: auth.activeProfile,
          header: header,
          roleSettings: roleSettings,
        ),
      );
    },
  );
}

class _AccountBody extends StatelessWidget {
  const _AccountBody({
    required this.user,
    this.activeProfile,
    this.header,
    this.roleSettings,
  });
  final UserModel user;
  final ProfileModel? activeProfile;
  final Widget? header;
  final List<SettingItem> Function(BuildContext)? roleSettings;

  void _open(BuildContext context, Widget screen) => Navigator.of(
    context,
  ).push<void>(MaterialPageRoute<void>(builder: (_) => screen));

  void _edit(BuildContext context) => _open(
    context,
    BlocProvider(
      create: (_) =>
          AccountCubit(authRepository: context.read<AuthRepository>())
            ..loadAccount(),
      child: const EditProfileScreen(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (header != null) header!,
            Expanded(
              child: BlocConsumer<ProfileCubit, ProfileState>(
                listener: (context, state) {
                  if (state is ProfileSwitched && state.authResponse != null) {
                    context.read<AuthBloc>().add(
                      AuthProfileSwitched(state.authResponse!),
                    );
                  } else if (state is ProfileSwitchFailure) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
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
                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<ProfileCubit>().loadProfiles(),
                    child: ListView(
                      key: const PageStorageKey('shared-account'),
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(
                        top: AppSpacing.sm,
                        bottom: AppSpacing.xxl,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenPadding,
                          ),
                          child: ProfileCard(
                            user: user,
                            activeProfile: activeProfile,
                            onEditProfile: () => _edit(context),
                          ),
                        ),
                        AppSpacing.vGap16,
                        if (state is ProfileLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenPadding,
                            ),
                            child: LinearProgressIndicator(),
                          ),
                        if (state is ProfileFailure)
                          Padding(
                            padding: AppSpacing.paddingScreenAll,
                            child: Column(
                              children: [
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                ),
                                TextButton.icon(
                                  onPressed: () => context
                                      .read<ProfileCubit>()
                                      .loadProfiles(),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Thử lại vai trò'),
                                ),
                              ],
                            ),
                          ),
                        if (profiles.length > 1) ...[
                          SwitchProfileSection(
                            profiles: profiles,
                            activeProfile: activeProfile,
                            isLoading: state is ProfileSwitching,
                            switchingId: state is ProfileSwitching
                                ? state.switchingProfileId
                                : null,
                            onProfileSelected: (profile) {
                              if (profile.id != activeProfile?.id) {
                                context.read<ProfileCubit>().switchProfile(
                                  profile,
                                );
                              }
                            },
                          ),
                          AppSpacing.vGap16,
                        ],
                        SettingsSection(
                          items: [
                            SettingItem(
                              icon: Icons.person_outline_rounded,
                              iconColor: cs.primary,
                              title: l10n.profileTitle,
                              subtitle: l10n.updatePersonalDetails,
                              onTap: () => _edit(context),
                            ),
                            ...?roleSettings?.call(context),
                            SettingItem(
                              icon: Icons.shield_outlined,
                              iconColor: cs.blue500,
                              title: l10n.passwordAndSecurity,
                              subtitle: l10n.passwordSecurityHint,
                              onTap: () =>
                                  _open(context, const SecurityScreen()),
                              showDivider: false,
                            ),
                          ],
                        ),
                        AppSpacing.vGap24,
                        GeneralSection(
                          onSettingsTap: () =>
                              _open(context, const SettingsScreen()),
                          onHelpTap: () =>
                              _open(context, const HelpCenterScreen()),
                          onAboutTap: () => showAboutDialog(
                            context: context,
                            applicationName: '40Study',
                          ),
                        ),
                        AppSpacing.vGap24,
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenPadding,
                          ),
                          child: LogoutTile(
                            onTap: () => showLogoutConfirmation(context),
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
