import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/select_role/select_role_cubit.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/utils/role_utils.dart';
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
    with SingleTickerProviderStateMixin {
  late final SelectRoleCubit _selectRoleCubit;
  late final PageController _pageController;
  late final AnimationController _fadeController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectRoleCubit = SelectRoleCubit(
      authRepository: context.read<AuthRepository>(),
    )..loadRoles();
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
        body: Stack(
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
                    Expanded(
                      child: BlocBuilder<SelectRoleCubit, SelectRoleState>(
                        builder: (context, state) {
                          return switch (state) {
                            SelectRoleInitial() || SelectRoleLoading() =>
                              Center(
                                child: CircularProgressIndicator(
                                  color: cs.brandBlue,
                                ),
                              ),
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
          ],
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
            l10n.selectRoleTitle,
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
            l10n.selectRoleSubtitle,
            style: tt.bodySmall?.copyWith(
              color: cs.slate500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<RoleModel> roles) {
    return Column(
      children: [
        Expanded(child: _buildCarousel(context, roles)),
        _buildPageIndicator(context, roles.length),
        AppSpacing.vGap16,
        _buildContinueButton(context, roles),
        AppSpacing.vGap12,
        _buildLoginLink(context),
        AppSpacing.vGap16,
      ],
    );
  }

  Widget _buildCarousel(BuildContext context, List<RoleModel> roles) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      physics: const BouncingScrollPhysics(),
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final role = roles[index];
        final isSelected = index == _currentIndex;
        return AnimatedScale(
          scale: isSelected ? 1.0 : 0.92,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.7,
            duration: const Duration(milliseconds: 250),
            child: _RoleCard(
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

  Widget _buildPageIndicator(BuildContext context, int count) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
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

  Widget _buildContinueButton(BuildContext context, List<RoleModel> roles) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final navigator = NavigationService.of(context);
    final currentRole = roles[_currentIndex];
    final label = currentRole.displayName ?? RoleUtils.getLabel(currentRole.name);

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
            onPressed: () {
              navigator.navigateTo(Routes.registerForm, {'role': currentRole});
            },
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
                  l10n.continueWithRole(label),
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

  Widget _buildLoginLink(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${l10n.alreadyHaveAccount} ',
          style: TextStyle(color: cs.slate500, fontSize: 14),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            l10n.login,
            style: TextStyle(
              color: cs.brandBlue,
              fontWeight: FontWeight.w600,
              fontSize: 14,
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
        padding: const EdgeInsets.all(AppSpacing.xxl),
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

/// Role card - soft, refined design
class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  final RoleModel role;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final label = role.displayName ?? RoleUtils.getLabel(role.name);
    final description = role.description?.isNotEmpty == true
        ? role.description!
        : _getDefaultDescription(role.name);
    final icon = RoleUtils.getIcon(role.name);
    final capabilities = _getCapabilities(role.name);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.borderXl,
          border: Border.all(
            color: isSelected ? cs.brandBlue.withValues(alpha: 0.5) : cs.slate200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? cs.brandBlue.withValues(alpha: 0.12)
                  : cs.slate900.withValues(alpha: 0.06),
              blurRadius: isSelected ? 24 : 12,
              offset: Offset(0, isSelected ? 8 : 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              // Selected badge
              AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cs.blue50,
                    borderRadius: AppRadius.borderFull,
                    border: Border.all(
                      color: cs.brandBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    'Đang chọn',
                    style: tt.labelSmall?.copyWith(
                      color: cs.brandBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              AppSpacing.vGap16,

              // Icon with soft background
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: cs.blue50,
                  borderRadius: AppRadius.borderLg,
                ),
                child: Icon(icon, size: 36, color: cs.brandBlue),
              ),

              AppSpacing.vGap16,

              // Role name
              Text(
                label,
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),

              AppSpacing.vGap8,

              // Description
              Text(
                description,
                style: tt.bodyMedium?.copyWith(
                  color: cs.slate500,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              AppSpacing.vGap24,

              // Capabilities
              Expanded(
                child: Column(
                  children: capabilities.map((cap) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: cs.blue50,
                              borderRadius: AppRadius.borderSm,
                            ),
                            child: Icon(
                              cap.icon,
                              size: 18,
                              color: cs.brandBlue,
                            ),
                          ),
                          AppSpacing.hGap12,
                          Expanded(
                            child: Text(
                              cap.label,
                              style: tt.bodyMedium?.copyWith(
                                color: cs.slate700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Radio indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? cs.brandBlue : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? cs.brandBlue : cs.slate300,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDefaultDescription(String roleName) {
    final name = roleName.toUpperCase();
    if (name.contains('STUDENT')) {
      return 'Học tập, làm bài và theo dõi tiến độ của bản thân.';
    }
    if (name.contains('TEACHER')) {
      return 'Quản lý lớp học, tạo bài giảng và theo dõi học sinh.';
    }
    if (name.contains('PARENT')) {
      return 'Theo dõi quá trình học tập và hỗ trợ con hiệu quả hơn.';
    }
    if (name.contains('OWNER') || name.contains('ORG')) {
      return 'Quản lý tổ chức giáo dục và phát triển đội ngũ.';
    }
    return 'Tham gia cộng đồng học tập.';
  }

  List<_Capability> _getCapabilities(String roleName) {
    final name = roleName.toUpperCase();

    if (name.contains('STUDENT')) {
      return const [
        _Capability(Icons.menu_book_outlined, 'Học tập mọi lúc mọi nơi'),
        _Capability(Icons.assignment_outlined, 'Làm bài và kiểm tra'),
        _Capability(Icons.insights_outlined, 'Theo dõi tiến độ cá nhân'),
      ];
    }

    if (name.contains('PARENT')) {
      return const [
        _Capability(Icons.visibility_outlined, 'Theo dõi tiến độ học tập'),
        _Capability(Icons.notifications_outlined, 'Nhận thông báo, báo cáo'),
        _Capability(Icons.chat_outlined, 'Kết nối với giáo viên'),
      ];
    }

    if (name.contains('TEACHER')) {
      return const [
        _Capability(Icons.groups_outlined, 'Quản lý lớp học dễ dàng'),
        _Capability(Icons.add_task_outlined, 'Tạo và giao bài giảng'),
        _Capability(Icons.analytics_outlined, 'Theo dõi kết quả học sinh'),
      ];
    }

    if (name.contains('OWNER') || name.contains('ORG')) {
      return const [
        _Capability(Icons.domain_outlined, 'Quản lý tổ chức'),
        _Capability(Icons.people_outline, 'Quản lý nhân sự'),
        _Capability(Icons.bar_chart_outlined, 'Báo cáo và thống kê'),
      ];
    }

    return const [
      _Capability(Icons.dashboard_outlined, 'Không gian làm việc riêng'),
      _Capability(Icons.security_outlined, 'Quyền truy cập phù hợp'),
    ];
  }
}

class _Capability {
  const _Capability(this.icon, this.label);
  final IconData icon;
  final String label;
}
