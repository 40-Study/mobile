import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/select_role/select_role_cubit.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/routes/router.dart';
import 'package:study/theme/theme.dart';

class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen>
    with TickerProviderStateMixin {
  late final SelectRoleCubit _selectRoleCubit;
  late final PageController _pageController;
  late final AnimationController _fadeController;

  double _currentPageValue = 0;

  @override
  void initState() {
    super.initState();
    _selectRoleCubit = SelectRoleCubit(
      authRepository: context.read<AuthRepository>(),
    )..loadRoles();

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
    _selectRoleCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: _selectRoleCubit,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: BlocBuilder<SelectRoleCubit, SelectRoleState>(
                    builder: (context, state) {
                      return switch (state) {
                        SelectRoleInitial() || SelectRoleLoading() =>
                          const Center(child: CircularProgressIndicator()),
                        SelectRoleLoaded(:final roles) => _buildContent(
                          context,
                          roles,
                        ),
                        SelectRoleFailure(:final message) => _buildError(
                          context,
                          message,
                        ),
                      };
                    },
                  ),
                ),
              ],
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
                  l10n.selectRoleTitle,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                AppSpacing.vGap4,
                Text(
                  l10n.selectRoleSubtitle,
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

  Widget _buildContent(BuildContext context, List<RoleModel> roles) {
    return Column(
      children: [
        const SizedBox(height: 2),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: roles.length,
            itemBuilder: (context, index) {
              return _buildAnimatedCard(context, roles[index], index);
            },
          ),
        ),
        AppSpacing.vGap12,
        _buildPageIndicator(context, roles.length),
        AppSpacing.vGap16,
        _buildConfirmButton(context, roles),
        AppSpacing.vGap8,
        _buildLoginLink(context),
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

  Widget _buildPageIndicator(BuildContext context, int count) {
    final cs = Theme.of(context).colorScheme;
    final currentIndex = _currentPageValue.round();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
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

  Widget _buildConfirmButton(BuildContext context, List<RoleModel> roles) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final navigator = NavigationService.of(context);
    final currentIndex = _currentPageValue.round().clamp(0, roles.length - 1);
    final currentRole = roles[currentIndex];
    final label = currentRole.displayName ?? currentRole.name;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          onPressed: () {
            navigator.navigateTo(Routes.registerForm, {'role': currentRole});
          },
          style: FilledButton.styleFrom(
            backgroundColor: cs.brandBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.continueWithRole(label),
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

  Widget _buildLoginLink(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${l10n.alreadyHaveAccount} ',
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            l10n.login,
            style: TextStyle(
              color: cs.brandBlue,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: cs.error),
            AppSpacing.vGap16,
            Text(
              message,
              style: TextStyle(color: cs.error),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap24,
            FilledButton.icon(
              onPressed: _selectRoleCubit.loadRoles,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.tryAgainButton),
            ),
          ],
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
    final label = role.displayName ?? role.name;
    final description = role.description?.isNotEmpty == true
        ? role.description!
        : _getDefaultDescription(role.name);
    final benefits = _roleBenefits(role.name);
    final spotlight = _roleSpotlight(role.name);

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
                                  _RolePill(
                                    color: theme.primaryColor,
                                    icon: Icons.person_add_alt_1_rounded,
                                    label: l10n.tapToSelect,
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
                                        : 'Lướt để xem vai trò này',
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

  String _getDefaultDescription(String roleName) {
    final name = roleName.toUpperCase();
    if (name.contains('STUDENT')) {
      return 'Khám phá kiến thức mới và theo dõi tiến độ học tập của bạn.';
    }
    if (name.contains('TEACHER')) {
      return 'Chia sẻ kiến thức, tạo khóa học và truyền cảm hứng cho học viên.';
    }
    if (name.contains('PARENT')) {
      return 'Theo dõi và hỗ trợ hành trình học tập của con em.';
    }
    if (name.contains('OWNER') || name.contains('ORG')) {
      return 'Quản lý tổ chức giáo dục và phát triển đội ngũ.';
    }
    return 'Tham gia cộng đồng học tập và phát triển bản thân.';
  }

  List<_RoleBenefit> _roleBenefits(String roleName) {
    final name = roleName.toUpperCase();
    if (name.contains('STUDENT')) {
      return const [
        _RoleBenefit(Icons.play_lesson_rounded, 'Khóa học'),
        _RoleBenefit(Icons.assignment_rounded, 'Bài tập'),
        _RoleBenefit(Icons.workspace_premium_rounded, 'Chứng chỉ'),
      ];
    }
    if (name.contains('TEACHER')) {
      return const [
        _RoleBenefit(Icons.edit_note_rounded, 'Tạo khóa học'),
        _RoleBenefit(Icons.groups_rounded, 'Quản lý'),
        _RoleBenefit(Icons.payments_rounded, 'Thu nhập'),
      ];
    }
    if (name.contains('PARENT')) {
      return const [
        _RoleBenefit(Icons.child_care_rounded, 'Theo dõi'),
        _RoleBenefit(Icons.fact_check_rounded, 'Báo cáo'),
        _RoleBenefit(Icons.notifications_active_rounded, 'Thông báo'),
      ];
    }
    if (name.contains('OWNER') || name.contains('ORG')) {
      return const [
        _RoleBenefit(Icons.domain_rounded, 'Quản lý'),
        _RoleBenefit(Icons.query_stats_rounded, 'Thống kê'),
        _RoleBenefit(Icons.people_alt_rounded, 'Nhân sự'),
      ];
    }
    return const [
      _RoleBenefit(Icons.auto_stories_rounded, 'Học tập'),
      _RoleBenefit(Icons.forum_rounded, 'Cộng đồng'),
    ];
  }

  _RoleSpotlight _roleSpotlight(String roleName) {
    final name = roleName.toUpperCase();
    if (name.contains('STUDENT')) {
      return const _RoleSpotlight(
        Icons.school_rounded,
        'Bắt đầu hành trình học',
        'Nhận khóa học phù hợp, làm bài tập và lưu lại thành tích của bạn.',
      );
    }
    if (name.contains('TEACHER')) {
      return const _RoleSpotlight(
        Icons.psychology_rounded,
        'Xây lớp học của bạn',
        'Tạo nội dung, quản lý học viên và theo dõi hiệu quả giảng dạy.',
      );
    }
    if (name.contains('PARENT')) {
      return const _RoleSpotlight(
        Icons.family_restroom_rounded,
        'Đồng hành cùng con',
        'Theo dõi tiến độ, kết quả học tập và nhận thông báo quan trọng.',
      );
    }
    if (name.contains('OWNER') || name.contains('ORG')) {
      return const _RoleSpotlight(
        Icons.domain_rounded,
        'Vận hành trung tâm',
        'Quản lý đội ngũ, học viên, khóa học và số liệu tăng trưởng.',
      );
    }
    return const _RoleSpotlight(
      Icons.dashboard_customize_rounded,
      'Thiết lập không gian riêng',
      'Chọn vai trò phù hợp để cá nhân hóa trải nghiệm trong ứng dụng.',
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

class _RolePill extends StatelessWidget {
  const _RolePill({
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

  factory _RoleTheme.fromName(String roleName, [ColorScheme? cs]) {
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
      primaryColor: cs?.slate500 ?? const Color(0xFF64748B),
      secondaryColor: cs?.slate300 ?? const Color(0xFFCBD5E1),
    );
  }

  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
}
