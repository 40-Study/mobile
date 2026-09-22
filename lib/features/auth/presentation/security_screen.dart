import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/bloc/security/security_cubit.dart';
import 'package:study/features/auth/bloc/security/security_state.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/change_password_screen.dart';
import 'package:study/features/auth/presentation/widgets/security/widgets.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/widgets/app_header_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  late final SecurityCubit _cubit;
  AuthBloc? _authBloc;

  @override
  void initState() {
    super.initState();
    _cubit = SecurityCubit(authRepository: context.read<AuthRepository>())
      ..loadDevices();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Store AuthBloc ref early để tránh deactivated widget issue
    _authBloc ??= context.read<AuthBloc>();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: cs.surfaceContainerLowest,
        appBar: AppHeaderBar(
          title: l10n.passwordAndSecurity,
          showBackButton: true,
          showNotification: false,
          backgroundColor: cs.surfaceContainerLowest,
        ),
        body: BlocConsumer<SecurityCubit, SecurityState>(
          listener: _handleStateChange,
          builder: (context, state) {
            final devices = _getDevices(state);
            final linkedAccounts = _getLinkedAccounts(state);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Login section
                SectionHeader(title: l10n.loginSection),
                const SizedBox(height: 12),
                SettingsCard(
                  children: [
                    SettingsItem(
                      icon: Icons.lock_outline,
                      title: l10n.changePassword,
                      subtitle: l10n.changePasswordHint,
                      onTap: _showChangePasswordDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Linked accounts section
                SectionHeader(title: l10n.linkedAccounts),
                const SizedBox(height: 12),
                LinkedAccountsList(
                  linkedAccounts: linkedAccounts,
                  isLoading: state is SecurityLoading,
                  unlinkingProvider: state is SecurityUnlinkingAccount
                      ? state.provider
                      : null,
                  onUnlink: _showUnlinkDialog,
                  onLink: _linkAccount,
                ),
                const SizedBox(height: 24),

                // Devices section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SectionHeader(title: l10n.whereYouLoggedIn),
                    if (devices.length > 1)
                      TextButton(
                        onPressed: _showLogoutAllDialog,
                        child: Text(
                          l10n.logoutAll,
                          style: TextStyle(color: cs.error),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                DevicesList(
                  devices: devices,
                  isLoading: state is SecurityLoading,
                  onRefresh: () => _cubit.loadDevices(),
                ),
                const SizedBox(height: 24),

                // Advanced section
                SectionHeader(title: l10n.advanced),
                const SizedBox(height: 12),
                SettingsCard(
                  children: [
                    SettingsItem(
                      icon: Icons.email_outlined,
                      title: l10n.securityEmails,
                      subtitle: l10n.securityEmailsHint,
                      onTap: () {},
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: cs.outlineVariant.withValues(alpha: 0.5),
                    ),
                    SettingsItem(
                      icon: Icons.history,
                      title: l10n.activityHistory,
                      subtitle: l10n.activityHistoryHint,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Footer
                _buildFooter(tt, cs, l10n),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooter(TextTheme tt, ColorScheme cs, AppLocalizations l10n) {
    return Center(
      child: Column(
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              var accountId = 'N/A';
              if (authState is AuthAuthenticated) {
                final id = authState.user.id;
                final shortId = id.substring(0, id.length > 8 ? 8 : id.length);
                accountId = 'ID-${shortId.toUpperCase()}';
              }
              return Text(
                l10n.accountId(accountId),
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            '40STUDY SECURITY HUB',
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  void _handleStateChange(BuildContext context, SecurityState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is SecurityPasswordChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.passwordChangedSuccess)),
      );
    }
    if (state is SecurityLoggedOutAll) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loggedOutAllDevices)),
      );
      _authBloc?.add(AuthLoggedOut());
    }
    if (state is SecurityAccountUnlinked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.unlinkedAccount(_getProviderName(state.provider))),
        ),
      );
    }
    if (state is SecurityFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  }

  List<DeviceModel> _getDevices(SecurityState state) {
    return switch (state) {
      SecurityLoaded(:final devices) => devices,
      SecurityChangingPassword(:final devices) => devices,
      SecurityPasswordChanged(:final devices) => devices,
      SecurityLoggingOutAll(:final devices) => devices,
      SecurityUnlinkingAccount(:final devices) => devices,
      SecurityAccountUnlinked(:final devices) => devices,
      SecurityFailure(:final devices) => devices,
      _ => [],
    };
  }

  List<LinkedAccountModel> _getLinkedAccounts(SecurityState state) {
    return switch (state) {
      SecurityLoaded(:final linkedAccounts) => linkedAccounts,
      SecurityChangingPassword(:final linkedAccounts) => linkedAccounts,
      SecurityPasswordChanged(:final linkedAccounts) => linkedAccounts,
      SecurityLoggingOutAll(:final linkedAccounts) => linkedAccounts,
      SecurityUnlinkingAccount(:final linkedAccounts) => linkedAccounts,
      SecurityAccountUnlinked(:final linkedAccounts) => linkedAccounts,
      SecurityFailure(:final linkedAccounts) => linkedAccounts,
      _ => [],
    };
  }

  String _getProviderName(String provider) {
    return switch (provider.toLowerCase()) {
      'google' => 'Google',
      'facebook' => 'Facebook',
      'github' => 'GitHub',
      _ => provider,
    };
  }

  void _showChangePasswordDialog() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const ChangePasswordScreen()),
    );
  }

  void _showLogoutAllDialog() {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logoutAllDevicesTitle),
        content: Text(l10n.logoutAllDevicesContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cubit.logoutAllDevices();
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: Text(l10n.logoutAll),
          ),
        ],
      ),
    );
  }

  void _showUnlinkDialog(String provider) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final providerName = _getProviderName(provider);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.unlinkAccount(providerName)),
        content: Text(l10n.unlinkAccountContent(providerName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cubit.unlinkAccount(provider);
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: Text(l10n.logoutAll),
          ),
        ],
      ),
    );
  }

  Future<void> _linkAccount(String provider) async {
    final l10n = AppLocalizations.of(context)!;
    final providerName = _getProviderName(provider);
    final baseUrl = dotenv.get('BASE_URL', fallback: '');

    // Check localhost (dev environment)
    if (baseUrl.contains('127.0.0.1') || baseUrl.contains('localhost')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.linkOnlyProduction(providerName))),
      );
      return;
    }

    try {
      if (baseUrl.isEmpty) {
        throw Exception(l10n.serverNotConfigured);
      }

      // OAuth link endpoint
      final oauthUrl = '$baseUrl/api/auth/oauth/$provider?mode=link';
      final uri = Uri.parse(oauthUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception(l10n.cannotOpenBrowser);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cannotLink(providerName)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
