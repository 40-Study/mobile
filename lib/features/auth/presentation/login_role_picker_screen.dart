import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/bloc/login/login_bloc.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/data/device_info_helper.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/utils/role_utils.dart';
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
    with TickerProviderStateMixin {
  late final LoginBloc _loginBloc;
  late final PageController _pageController;
  late final AnimationController _fadeController;

  double _currentPageValue = 0;

  @override
  void initState() {
    super.initState();
    _loginBloc = LoginBloc(
      authRepository: context.read<AuthRepository>(),
      deviceInfoHelper: DeviceInfoHelper(context.read<AuthStorage>()),
    );

    _pageController = PageController(viewportFraction: 0.8);
    _pageController.addListener(_onPageChanged);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }

  void _onPageChanged() {
    setState(() {
      _currentPageValue = _pageController.page ?? 0;
    });
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
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: cs.surface,
          body: SafeArea(
            child: BlocBuilder<LoginBloc, LoginState>(
              builder: (context, state) {
                if (state is LoginInProgress) {
                  return Center(
                    child: CircularProgressIndicator(color: cs.primary),
                  );
                }

                return FadeTransition(
                  opacity: _fadeController,
                  child: Column(
                    children: [
                      _buildHeader(context),
                      Expanded(child: _buildContent(context)),
                    ],
                  ),
                );
              },
            ),
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
      padding: const EdgeInsets.fromLTRB(8, 4, 20, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: cs.onSurfaceVariant,
              size: 20,
            ),
          ),
          AppSpacing.hGap8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.chooseProfileTitle,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                AppSpacing.vGap4,
                Text(
                  l10n.chooseProfileSubtitle,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 2),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.roles.length,
            itemBuilder: (context, index) {
              return _buildAnimatedCard(context, widget.roles[index], index);
            },
          ),
        ),
        AppSpacing.vGap12,
        _buildPageIndicator(context),
        AppSpacing.vGap16,
        _buildConfirmButton(context),
        AppSpacing.vGap16,
      ],
    );
  }

  Widget _buildAnimatedCard(BuildContext context, RoleModel role, int index) {
    final diff = (_currentPageValue - index);
    final scale = 1 - (diff.abs() * 0.1).clamp(0.0, 0.2);
    final opacity = 1 - (diff.abs() * 0.3).clamp(0.0, 0.5);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: scale, end: scale),
      duration: const Duration(milliseconds: 150),
      builder: (context, scaleValue, child) {
        return Transform.scale(
          scale: scaleValue,
          child: Opacity(
            opacity: opacity,
            child: _CompactRoleCard(role: role, isActive: diff.abs() < 0.5),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currentIndex = _currentPageValue.round();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.roles.length, (index) {
        final isActive = currentIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? cs.brandBlue : cs.slate300,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = _currentPageValue.round().clamp(
      0,
      widget.roles.length - 1,
    );
    final currentRole = widget.roles[currentIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          onPressed: () => _onRoleSelected(currentRole),
          style: FilledButton.styleFrom(
            backgroundColor: cs.brandBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.loginWithThisProfile,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.hGap8,
              const Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact role card - nhỏ gọn, xinh xắn
class _CompactRoleCard extends StatelessWidget {
  const _CompactRoleCard({required this.role, required this.isActive});

  final RoleModel role;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final theme = _RoleTheme.fromName(role.name, cs);
    final label = role.displayName ?? RoleUtils.getLabel(role.name);
    final description = role.description?.isNotEmpty == true
        ? role.description!
        : RoleUtils.getDescription(role.name);
    final orgName = role.organizationName;
    final isOrgRole = role.type == 'organization';
    final roleName = role.name;
    final benefits = _roleBenefits(roleName);
    final spotlight = _roleSpotlight(roleName);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.borderXl,
          border: Border.all(
            color: isActive ? theme.primaryColor : cs.slate200,
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive ? cs.shadowPrimary : cs.shadowCard,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              top: -46,
              right: -32,
              child: Container(
                width: 148,
                height: 148,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.primaryColor.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -34,
              left: -28,
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.secondaryColor.withValues(alpha: 0.08),
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.secondaryColor],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.primaryColor,
                                    theme.secondaryColor,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: AppRadius.borderLg,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primaryColor.withValues(
                                      alpha: 0.22,
                                    ),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                theme.icon,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            AppSpacing.hGap16,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    label,
                                    style: tt.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: cs.onSurface,
                                      height: 1.15,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  AppSpacing.vGap8,
                                  _ProfilePill(
                                    color: theme.primaryColor,
                                    icon: isOrgRole
                                        ? Icons.business_center_rounded
                                        : Icons.verified_user_rounded,
                                    label: isOrgRole
                                        ? l10n.organizationProfile
                                        : l10n.systemProfile,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.vGap16,
                        Text(
                          description,
                          style: tt.bodyMedium?.copyWith(
                            color: cs.slate600,
                            height: 1.45,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (orgName != null && orgName.isNotEmpty) ...[
                          AppSpacing.vGap12,
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: cs.slate50,
                              borderRadius: AppRadius.borderMd,
                              border: Border.all(color: cs.slate200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: AppRadius.borderSm,
                                  ),
                                  child: Icon(
                                    Icons.apartment_rounded,
                                    size: 18,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                AppSpacing.hGap12,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tổ chức',
                                        style: tt.labelSmall?.copyWith(
                                          color: cs.slate500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        orgName,
                                        style: tt.bodySmall?.copyWith(
                                          color: cs.slate700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        AppSpacing.vGap12,
                        Expanded(
                          child: _SpotlightPanel(
                            color: theme.primaryColor,
                            icon: spotlight.icon,
                            title: spotlight.title,
                            body: spotlight.body,
                          ),
                        ),
                        AppSpacing.vGap12,
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: benefits
                              .map(
                                (benefit) => _BenefitChip(
                                  icon: benefit.icon,
                                  label: benefit.label,
                                  color: theme.primaryColor,
                                ),
                              )
                              .toList(),
                        ),
                        AppSpacing.vGap12,
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isActive ? 1 : 0.54,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? theme.primaryColor.withValues(alpha: 0.1)
                                  : cs.slate50,
                              borderRadius: AppRadius.borderMd,
                              border: Border.all(
                                color: isActive
                                    ? theme.primaryColor.withValues(alpha: 0.18)
                                    : cs.slate200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isActive
                                      ? Icons.check_circle_rounded
                                      : Icons.swipe_rounded,
                                  size: 18,
                                  color: isActive
                                      ? theme.primaryColor
                                      : cs.slate500,
                                ),
                                AppSpacing.hGap8,
                                Expanded(
                                  child: Text(
                                    isActive
                                        ? l10n.tapToSelect
                                        : 'Lướt để xem profile này',
                                    style: tt.labelMedium?.copyWith(
                                      color: isActive
                                          ? theme.primaryColor
                                          : cs.slate500,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<_RoleBenefit> _roleBenefits(String roleName) {
    final name = roleName.toUpperCase();

    if (name.contains('STUDENT')) {
      return const [
        _RoleBenefit(Icons.play_lesson_rounded, 'Bài học'),
        _RoleBenefit(Icons.timeline_rounded, 'Tiến độ'),
        _RoleBenefit(Icons.emoji_events_rounded, 'Thành tích'),
      ];
    }

    if (name.contains('TEACHER')) {
      return const [
        _RoleBenefit(Icons.edit_note_rounded, 'Soạn bài'),
        _RoleBenefit(Icons.groups_rounded, 'Lớp học'),
        _RoleBenefit(Icons.insights_rounded, 'Báo cáo'),
      ];
    }

    if (name.contains('PARENT')) {
      return const [
        _RoleBenefit(Icons.child_care_rounded, 'Con em'),
        _RoleBenefit(Icons.fact_check_rounded, 'Kết quả'),
        _RoleBenefit(Icons.notifications_active_rounded, 'Nhắc nhở'),
      ];
    }

    if (name.contains('OWNER') || name.contains('ORG')) {
      return const [
        _RoleBenefit(Icons.domain_rounded, 'Tổ chức'),
        _RoleBenefit(Icons.people_alt_rounded, 'Nhân sự'),
        _RoleBenefit(Icons.bar_chart_rounded, 'Vận hành'),
      ];
    }

    return const [
      _RoleBenefit(Icons.dashboard_customize_rounded, 'Không gian riêng'),
      _RoleBenefit(Icons.security_rounded, 'Quyền truy cập'),
      _RoleBenefit(Icons.bolt_rounded, 'Tiếp tục nhanh'),
    ];
  }

  _RoleSpotlight _roleSpotlight(String roleName) {
    final name = roleName.toUpperCase();

    if (name.contains('STUDENT')) {
      return const _RoleSpotlight(
        Icons.auto_stories_rounded,
        'Vào lớp học của bạn',
        'Tiếp tục bài đang học, xem lịch học và cập nhật thành tích mới nhất.',
      );
    }

    if (name.contains('TEACHER')) {
      return const _RoleSpotlight(
        Icons.workspace_premium_rounded,
        'Không gian giảng dạy',
        'Quản lý lớp, giao bài và theo dõi tiến độ học sinh trong một nơi.',
      );
    }

    if (name.contains('PARENT')) {
      return const _RoleSpotlight(
        Icons.family_restroom_rounded,
        'Theo sát con em',
        'Xem kết quả, lịch học và những cập nhật quan trọng từ giáo viên.',
      );
    }

    if (name.contains('OWNER') || name.contains('ORG')) {
      return const _RoleSpotlight(
        Icons.query_stats_rounded,
        'Bảng điều hành tổ chức',
        'Nắm nhanh học viên, giáo viên, doanh thu và hiệu suất vận hành.',
      );
    }

    return const _RoleSpotlight(
      Icons.dashboard_customize_rounded,
      'Không gian làm việc',
      'Mở đúng quyền truy cập và tiếp tục công việc của bạn.',
    );
  }
}

class _SpotlightPanel extends StatelessWidget {
  const _SpotlightPanel({
    required this.color,
    required this.icon,
    required this.title,
    required this.body,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.titleSmall?.copyWith(
                    color: cs.slate800,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vGap4,
                Text(
                  body,
                  style: tt.bodySmall?.copyWith(
                    color: cs.slate600,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: tt.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: cs.slate700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBenefit {
  const _RoleBenefit(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _RoleSpotlight {
  const _RoleSpotlight(this.icon, this.title, this.body);

  final IconData icon;
  final String title;
  final String body;
}

/// Role theme - Professional Blue variations
class _RoleTheme {
  const _RoleTheme({
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });

  factory _RoleTheme.fromName(String roleName, ColorScheme cs) {
    final name = roleName.toUpperCase();

    if (name.contains('STUDENT')) {
      return const _RoleTheme(
        icon: Icons.school_rounded,
        primaryColor: RoleColors.studentPrimary,
        secondaryColor: RoleColors.studentSecondary,
      );
    }

    if (name.contains('TEACHER')) {
      return const _RoleTheme(
        icon: Icons.psychology_rounded,
        primaryColor: RoleColors.teacherPrimary,
        secondaryColor: RoleColors.teacherSecondary,
      );
    }

    if (name.contains('PARENT')) {
      return const _RoleTheme(
        icon: Icons.family_restroom_rounded,
        primaryColor: RoleColors.parentPrimary,
        secondaryColor: RoleColors.parentSecondary,
      );
    }

    if (name.contains('OWNER') || name.contains('ORG')) {
      return const _RoleTheme(
        icon: Icons.domain_rounded,
        primaryColor: RoleColors.orgPrimary,
        secondaryColor: RoleColors.orgSecondary,
      );
    }

    return _RoleTheme(
      icon: Icons.person_rounded,
      primaryColor: cs.slate500,
      secondaryColor: cs.slate300,
    );
  }

  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
}
