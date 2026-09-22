import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/bloc/login/login_bloc.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/data/device_info_helper.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/widgets/role_card.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/routes/router.dart';
import 'package:study/theme/theme.dart';

class LoginRolePickerScreen extends StatefulWidget {
  const LoginRolePickerScreen({
    super.key,
    required this.sessionToken,
    required this.roles,
  });

  final String sessionToken;
  final List<RoleModel> roles;

  @override
  State<LoginRolePickerScreen> createState() => _LoginRolePickerScreenState();
}

class _LoginRolePickerScreenState extends State<LoginRolePickerScreen>
    with SingleTickerProviderStateMixin {
  late final LoginBloc _loginBloc;
  late final PageController _pageController;
  late final AnimationController _fadeController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loginBloc = LoginBloc(
      authRepository: context.read<AuthRepository>(),
      deviceInfoHelper: DeviceInfoHelper(context.read<AuthStorage>()),
    );
    _pageController = PageController(viewportFraction: 0.82);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _loginBloc.close();
    super.dispose();
  }

  void _onRoleSelected(RoleModel role) {
    _loginBloc.add(
      LoginRoleSelected(
        sessionToken: widget.sessionToken,
        roleId: role.id,
        roleType: role.type ?? 'system',
        organizationId: role.organizationId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigator = NavigationService.of(context);
    final cs = Theme.of(context).colorScheme;

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
                shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: cs.surface,
          body: BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              if (state is LoginInProgress) {
                return Center(
                  child: CircularProgressIndicator(color: cs.brandBlue),
                );
              }
              return Stack(
                children: [
                  // Subtle background decoration
                  Positioned(
                    top: -120,
                    right: -80,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.blue100.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -60,
                    left: -100,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.blue50.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  // Content
                  SafeArea(
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _fadeController,
                        curve: Curves.easeOut,
                      ),
                      child: Column(
                        children: [
                          AppSpacing.vGap8,
                          _buildHeader(context),
                          Expanded(child: _buildCarousel(context)),
                          _buildPageIndicator(context),
                          AppSpacing.vGap16,
                          _buildContinueButton(context),
                          AppSpacing.vGap12,
                          _buildSwitchAccountLink(context),
                          AppSpacing.vGap16,
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          // Title
          Text(
            l10n.chooseProfileTitle,
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vGap4,
          // Subtitle
          Text(
            l10n.chooseProfileSubtitle,
            style: tt.bodySmall?.copyWith(
              color: cs.slate500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      physics: const BouncingScrollPhysics(),
      itemCount: widget.roles.length,
      itemBuilder: (context, index) {
        final role = widget.roles[index];
        final isSelected = index == _currentIndex;
        return AnimatedScale(
          scale: isSelected ? 1.0 : 0.92,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.7,
            duration: const Duration(milliseconds: 250),
            child: RoleCard(
              role: role,
              isSelected: isSelected,
              onTap: () {
                if (!isSelected) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.roles.length, (index) {
        final isActive = index == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? cs.brandBlue : cs.slate200,
            borderRadius: AppRadius.borderFull,
          ),
        );
      }),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final currentRole = widget.roles[_currentIndex];

    return Padding(
      padding: AppSpacing.paddingHorizontalXl,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.borderMd,
          boxShadow: [
            BoxShadow(
              color: cs.brandBlue.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton(
            onPressed: () => _onRoleSelected(currentRole),
            style: FilledButton.styleFrom(
              backgroundColor: cs.brandBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.loginWithThisProfile,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                AppSpacing.hGap8,
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchAccountLink(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return TextButton(
      onPressed: () {
        context.read<AuthBloc>().add(AuthLoggedOut());
        Navigator.of(context).pop();
      },
      style: TextButton.styleFrom(
        foregroundColor: cs.brandBlue,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),
      child: Text(
        '${l10n.logout} & ${l10n.switchProfile}',
        style: TextStyle(
          color: cs.brandBlue,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
