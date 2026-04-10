import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/bloc/login/login_bloc.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/data/device_info_helper.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/utils/role_utils.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/routes/router.dart';

/// Screen để chọn role khi user có nhiều roles (login trả về completed=false)
class LoginRolePickerScreen extends StatefulWidget {
  const LoginRolePickerScreen({
    super.key,
    required this.sessionToken,
    required this.roles,
  });

  final String sessionToken;
  final List<RoleModel> roles; // UnifiedRoleDto[] từ API

  @override
  State<LoginRolePickerScreen> createState() => _LoginRolePickerScreenState();
}

class _LoginRolePickerScreenState extends State<LoginRolePickerScreen>
    with SingleTickerProviderStateMixin {
  late final LoginBloc _loginBloc;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loginBloc = LoginBloc(
      authRepository: diContainer.get<AuthRepository>(),
      deviceInfoHelper: DeviceInfoHelper(diContainer.get<AuthStorage>()),
    );

    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _loginBloc.close();
    super.dispose();
  }

  void _onRoleSelected(RoleModel role) {
    _loginBloc.add(LoginRoleSelected(
      sessionToken: widget.sessionToken,
      roleId: role.id,
      roleType: role.type ?? 'system',
      organizationId: role.organizationId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final navigator = NavigationService.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Tách system roles và organization roles
    final systemRoles =
        widget.roles.where((r) => r.type == 'system').toList();
    final orgRoles =
        widget.roles.where((r) => r.type == 'organization').toList();

    return BlocProvider.value(
      value: _loginBloc,
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            context.read<AuthBloc>().add(AuthLoggedIn(state.response));
            Future.delayed(const Duration(milliseconds: 100), () {
              if (!mounted) return;
              navigator.pushAndRemoveAll(Routes.app);
            });
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              if (state is LoginInProgress) {
                return const Center(child: CircularProgressIndicator());
              }

              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        // Header
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  cs.primary,
                                  cs.primary.withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: cs.primary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.switch_account_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Chọn vai trò',
                          style: tt.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bạn có nhiều vai trò, hãy chọn một để tiếp tục',
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // System Roles Section
                        if (systemRoles.isNotEmpty) ...[
                          _SectionHeader(
                            title: 'Vai trò cá nhân',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 12),
                          ...systemRoles.map((role) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _RoleCard(
                                  role: role,
                                  onTap: () => _onRoleSelected(role),
                                ),
                              )),
                        ],

                        // Organization Roles Section
                        if (orgRoles.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _SectionHeader(
                            title: 'Vai trò tổ chức',
                            icon: Icons.business_outlined,
                          ),
                          const SizedBox(height: 12),
                          ...orgRoles.map((role) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _RoleCard(
                                  role: role,
                                  onTap: () => _onRoleSelected(role),
                                  isOrgRole: true,
                                ),
                              )),
                        ],

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          title,
          style: tt.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.onTap,
    this.isOrgRole = false,
  });

  final RoleModel role;
  final VoidCallback onTap;
  final bool isOrgRole;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Dùng display_name nếu có, không thì dùng role_name
    final displayName = role.displayName ?? RoleUtils.getLabel(role.name);
    final hasOrg = role.organizationName != null;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isOrgRole
                      ? cs.tertiaryContainer
                      : cs.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  RoleUtils.getIcon(role.name),
                  size: 26,
                  color: isOrgRole ? cs.tertiary : cs.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    if (hasOrg) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.apartment_rounded,
                            size: 14,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              role.organizationName!,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
