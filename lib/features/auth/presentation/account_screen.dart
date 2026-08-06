import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart' show AppLayout;
import 'package:study/features/auth/bloc/account/account_cubit.dart';
import 'package:study/features/auth/bloc/account/account_state.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/edit_profile_screen.dart';
import 'package:study/features/auth/presentation/security_screen.dart';
import 'package:study/features/auth/presentation/utils/role_utils.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

enum AccountRoleType { teacher, student, parent, organization }

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key, this.roleType = AccountRoleType.teacher});

  final AccountRoleType roleType;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with SingleTickerProviderStateMixin {
  late final AccountCubit _cubit;
  late final TabController? _tabController;

  int get _tabCount {
    switch (widget.roleType) {
      case AccountRoleType.student:
        return 0;
      case AccountRoleType.teacher:
        return 0; // Teacher now uses single-page profile design
      case AccountRoleType.parent:
        return 3;
      case AccountRoleType.organization:
        return 0; // Organization uses single-page profile design
    }
  }

  @override
  void initState() {
    super.initState();
    _cubit = AccountCubit(authRepository: context.read<AuthRepository>())
      ..loadAccount();
    _tabController = _tabCount > 0
        ? TabController(length: _tabCount, vsync: this)
        : null;
  }

  @override
  void dispose() {
    _cubit.close();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocConsumer<AccountCubit, AccountState>(
          listener: (context, state) {
            final l10n = AppLocalizations.of(context)!;
            if (state is AccountUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.saveChanges),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                ),
              );
              context.read<AuthBloc>().add(AuthUserUpdated(state.user));
            }
            if (state is AccountFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is AccountLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                final l10n = AppLocalizations.of(context)!;
                if (authState is! AuthAuthenticated) {
                  return Center(child: Text(l10n.login));
                }

                final user = authState.user;
                final profile = authState.activeProfile;

                // Teacher uses new beautiful single-page profile
                if (widget.roleType == AccountRoleType.teacher) {
                  return _buildTeacherProfile(context, user, profile);
                }

                // Parent uses beautiful single-page profile
                if (widget.roleType == AccountRoleType.parent) {
                  return _buildParentProfile(context, user, profile);
                }

                // Student uses the original tabbed layout
                return NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    _buildSliverAppBar(context, user, profile),
                  ],
                  body: _buildTabContent(context, user),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTeacherProfile(
    BuildContext context,
    UserModel user,
    ProfileModel? profile,
  ) {
    final cs = Theme.of(context).colorScheme;
    final textColor = cs.onSurface;
    final secondaryColor = cs.onSurface.withValues(alpha: 0.6);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppLayout.screenMargin,
          AppSpacing.md,
          AppLayout.screenMargin,
          100,
        ),
        children: [
          // Settings button row
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => _showOptionsMenu(context),
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: cs.shadowCard,
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: cs.onSurface,
                  size: 20,
                ),
              ),
            ),
          ),

          // Avatar Section
          _buildTeacherAvatarSection(context, user, profile, textColor),
          const SizedBox(height: AppSpacing.xl),

          // Skills Chips
          _buildSkillsSection(context),
          const SizedBox(height: AppSpacing.xxl),

          // Stats Row
          _buildStatsCard(context),
          const SizedBox(height: AppSpacing.xxxl),

          // About Me Section
          _buildAboutSection(context, user, textColor, secondaryColor),
          const SizedBox(height: AppSpacing.xxxl),

          // Featured Courses Section
          _buildFeaturedCoursesSection(context, textColor),
        ],
      ),
    );
  }

  Widget _buildTeacherAvatarSection(
    BuildContext context,
    UserModel user,
    ProfileModel? profile,
    Color textColor,
  ) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        // Avatar with gradient ring
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [cs.primary, cs.tertiary, cs.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.surface,
                ),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: cs.surfaceTintedPrimary,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          _getInitials(
                            user.fullName ?? user.username ?? 'User',
                          ),
                          style: tt.headlineMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            // Camera button
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _changeAvatar,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.surface, width: 3),
                    boxShadow: cs.shadowCard,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Verified badge
        Icon(Icons.verified_rounded, size: 24, color: cs.primary),
        const SizedBox(height: AppSpacing.md),

        // Name
        Text(
          user.fullName ?? user.username ?? 'User',
          style: tt.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),

        // Title / Role
        Text(
          AppLocalizations.of(context)!.roleTeacher.toUpperCase(),
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSkillsSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final skills = ['Flutter', 'UI/UX Design', 'Dart', 'Figma', 'Data Science'];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: AppRadius.borderXxl,
            border: Border.all(color: cs.outline),
            boxShadow: cs.shadowCard,
          ),
          child: Text(
            skill,
            style: tt.labelMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: cs.outline),
        boxShadow: cs.shadowCard,
      ),
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Row(
            children: [
              Expanded(
                child: _TeacherStatColumn(
                  value: '5.2k',
                  label: l10n.students.toUpperCase(),
                  showStar: false,
                ),
              ),
              Container(width: 1, height: 40, color: cs.outlineVariant),
              Expanded(
                child: _TeacherStatColumn(
                  value: '14',
                  label: l10n.courses.toUpperCase(),
                  showStar: false,
                ),
              ),
              Container(width: 1, height: 40, color: cs.outlineVariant),
              Expanded(
                child: _TeacherStatColumn(
                  value: '4.8',
                  label: l10n.rating.toUpperCase(),
                  showStar: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAboutSection(
    BuildContext context,
    UserModel user,
    Color textColor,
    Color secondaryColor,
  ) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: AppRadius.borderXs,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              AppLocalizations.of(context)!.bioLabel,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: cs.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Giảng viên chuyên ngành Công nghệ thông tin với hơn 5 năm '
                'kinh nghiệm giảng dạy UI/UX Design và lập trình Flutter. '
                'Đam mê chia sẻ kiến thức và giúp học viên phát triển kỹ '
                'năng thực tế.',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildInfoRow(context, Icons.email_outlined, user.email),
              if (user.phone != null && user.phone!.isNotEmpty)
                _buildInfoRow(context, Icons.phone_outlined, user.phone!),
              _buildInfoRow(
                context,
                Icons.calendar_today_outlined,
                'Tham gia từ ${_formatJoinDate(user.createdAt)}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCoursesSection(BuildContext context, Color textColor) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: AppRadius.borderXs,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                l10n.featuredCourses,
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.viewAll,
                    style: tt.labelMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: cs.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const _FeaturedCourseCard(
          title: 'Thiết kế UI/UX Nâng cao',
          duration: '24 bài học',
          price: '1.200.000đ',
          rating: 4.9,
          students: 156,
        ),
        const SizedBox(height: AppSpacing.md),
        const _FeaturedCourseCard(
          title: 'Flutter từ Zero đến Hero',
          duration: '36 bài học',
          price: '1.500.000đ',
          rating: 4.8,
          students: 234,
        ),
        const SizedBox(height: AppSpacing.md),
        const _FeaturedCourseCard(
          title: 'Data Science với Python',
          duration: '28 bài học',
          price: '1.800.000đ',
          rating: 4.7,
          students: 89,
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  STUDENT & PARENT PROFILE - Original Design with SliverAppBar
  // ══════════════════════════════════════════════════════════════

  Widget _buildSliverAppBar(
    BuildContext context,
    UserModel user,
    ProfileModel? profile,
  ) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final gradient = _gradientForRole(widget.roleType, cs);

    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: cs.surface,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
          ),
          onPressed: () => _showOptionsMenu(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(gradient: gradient),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PatternPainter(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!.editCover,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 160,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [cs.primary, cs.tertiary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cs.surface,
                            ),
                            child: CircleAvatar(
                              radius: 44,
                              backgroundColor: cs.primaryContainer,
                              backgroundImage: user.avatarUrl != null
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                              child: user.avatarUrl == null
                                  ? Text(
                                      _getInitials(
                                        user.fullName ??
                                            user.username ??
                                            'User',
                                      ),
                                      style: tt.headlineMedium?.copyWith(
                                        color: cs.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: _changeAvatar,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: cs.surface, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user.fullName ?? user.username ?? 'User',
                                  style: tt.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.verified, size: 20, color: cs.primary),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (profile != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    RoleUtils.getIcon(profile.roleName),
                                    size: 14,
                                    color: cs.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    RoleUtils.getLabel(profile.roleName),
                                    style: tt.labelMedium?.copyWith(
                                      color: cs.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return Row(
                                children: [
                                  _buildStat(tt, cs, '12', l10n.courses),
                                  const SizedBox(width: 24),
                                  _buildStat(tt, cs, '2.5k', l10n.xpPoints),
                                  const SizedBox(width: 24),
                                  _buildStat(tt, cs, '7 🔥', l10n.streak),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: _tabController != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: cs.surface,
                child: TabBar(
                  controller: _tabController,
                  labelColor: cs.primary,
                  unselectedLabelColor: cs.onSurfaceVariant,
                  indicatorColor: cs.primary,
                  indicatorWeight: 3,
                  tabs: _tabsForRole(context, widget.roleType),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildTabContent(BuildContext context, UserModel user) {
    if (_tabController == null) {
      return _tabViewsForRole(widget.roleType, user).first;
    }
    return TabBarView(
      controller: _tabController,
      children: _tabViewsForRole(widget.roleType, user),
    );
  }

  // ── Role-specific configuration ──────────────────────────────

  static LinearGradient _gradientForRole(AccountRoleType role, ColorScheme cs) {
    switch (role) {
      case AccountRoleType.teacher:
        return LinearGradient(
          colors: [cs.primary, cs.inversePrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AccountRoleType.student:
        return LinearGradient(
          colors: [cs.secondary, cs.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AccountRoleType.parent:
        return LinearGradient(
          colors: [cs.tertiary, cs.tertiaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AccountRoleType.organization:
        return LinearGradient(
          colors: [cs.primary, cs.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  List<Tab> _tabsForRole(BuildContext context, AccountRoleType role) {
    final l10n = AppLocalizations.of(context)!;
    switch (role) {
      case AccountRoleType.teacher:
        return [
          Tab(text: l10n.tabOverview),
          Tab(text: l10n.courses),
          Tab(text: l10n.tabAchievements),
        ];
      case AccountRoleType.student:
        return [Tab(text: l10n.tabOverview)];
      case AccountRoleType.parent:
        return [
          Tab(text: l10n.tabOverview),
          Tab(text: l10n.tabChildren),
          Tab(text: l10n.tabNotifications),
        ];
      case AccountRoleType.organization:
        return [Tab(text: l10n.tabOverview)];
    }
  }

  List<Widget> _tabViewsForRole(AccountRoleType role, UserModel user) {
    switch (role) {
      case AccountRoleType.teacher:
        return [
          _TeacherOverviewTab(user: user),
          _TeacherCoursesTab(),
          _AchievementsTab(),
        ];
      case AccountRoleType.student:
        return [_StudentOverviewTab(user: user)];
      case AccountRoleType.parent:
        return [
          _ParentOverviewTab(user: user),
          _ParentChildrenTab(),
          _ParentNotificationsTab(),
        ];
      case AccountRoleType.organization:
        return [
          _TeacherOverviewTab(user: user), // Reuse teacher overview for now
        ];
    }
  }

  // ── Shared helpers ───────────────────────────────────────────

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _formatJoinDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return 'tháng ${date.month}/${date.year}';
    } on FormatException {
      return dateStr;
    }
  }

  Widget _buildStat(TextTheme tt, ColorScheme cs, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }

  void _showOptionsMenu(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppSpacing.xl - 4),
            ListTile(
              leading: _buildMenuIcon(context, Icons.edit_outlined),
              title: Text(l10n.editProfile),
              onTap: () {
                Navigator.pop(context);
                _navigateToEditProfile();
              },
            ),
            ListTile(
              leading: _buildMenuIcon(context, Icons.share_outlined),
              title: Text(l10n.profileTitle),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: _buildMenuIcon(context, Icons.swap_horiz),
              title: Text(l10n.selectRoleTitle),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement switch role
              },
            ),
            ListTile(
              leading: _buildMenuIcon(context, Icons.security),
              title: Text(l10n.securityTitle),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const SecurityScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: _buildMenuIcon(context, Icons.qr_code),
              title: Text(l10n.profileTitle),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: _buildMenuIcon(context, Icons.link),
              title: Text(l10n.profileTitle),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            // Student-specific menu items removed
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                ),
                child: Icon(Icons.logout, color: cs.error, size: 20),
              ),
              title: Text(l10n.logout, style: TextStyle(color: cs.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmLogout(context);
              },
            ),
            AppSpacing.vGap16,
          ],
        ),
      ),
    );
  }

  Widget _buildMenuIcon(BuildContext context, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: cs.primary, size: 20),
    );
  }

  void _confirmLogout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Store bloc reference before showing dialog to avoid context issues
    final authBloc = context.read<AuthBloc>();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Use stored bloc reference to avoid deactivated widget issue
              authBloc.add(AuthLoggedOut());
            },
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  void _changeAvatar() {
    // TODO: Implement avatar change
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            BlocProvider.value(value: _cubit, child: const EditProfileScreen()),
      ),
    );
  }


  // ══════════════════════════════════════════════════════════════
  //  PARENT PROFILE - Beautiful Single Page Design
  // ══════════════════════════════════════════════════════════════

  Widget _buildParentProfile(
    BuildContext context,
    UserModel user,
    ProfileModel? profile,
  ) {
    final cs = Theme.of(context).colorScheme;
    final textColor = cs.onSurface;
    final secondaryColor = cs.onSurface.withValues(alpha: 0.6);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppLayout.screenMargin,
          AppSpacing.md,
          AppLayout.screenMargin,
          100,
        ),
        children: [
          // Settings button row
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => _showOptionsMenu(context),
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: cs.shadowCard,
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: cs.onSurface,
                  size: 20,
                ),
              ),
            ),
          ),

          // Avatar Section
          _buildParentAvatarSection(context, user, profile, textColor),
          const SizedBox(height: AppSpacing.xxl),

          // Stats Card
          _buildParentStatsCard(context),
          const SizedBox(height: AppSpacing.xxxl),

          // Account Info Section
          _buildParentAccountInfo(context, user, textColor, secondaryColor),
          const SizedBox(height: AppSpacing.xxxl),

          // Quick Actions
          _buildParentQuickActions(context, textColor),
        ],
      ),
    );
  }

  Widget _buildParentAvatarSection(
    BuildContext context,
    UserModel user,
    ProfileModel? profile,
    Color textColor,
  ) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        // Avatar with gradient ring (tertiary for parent)
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [cs.tertiary, cs.tertiaryContainer, cs.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.tertiary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.surface,
                ),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: cs.tertiaryContainer.withValues(alpha: 0.3),
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          _getInitials(
                            user.fullName ?? user.username ?? 'User',
                          ),
                          style: tt.headlineMedium?.copyWith(
                            color: cs.tertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            // Camera button
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _changeAvatar,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.tertiary,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.surface, width: 3),
                    boxShadow: cs.shadowCard,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Family icon badge
        Icon(Icons.family_restroom_rounded, size: 24, color: cs.tertiary),
        const SizedBox(height: AppSpacing.md),

        // Name
        Text(
          user.fullName ?? user.username ?? 'User',
          style: tt.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),

        // Role label
        Text(
          AppLocalizations.of(context)!.roleParent.toUpperCase(),
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildParentStatsCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderXxl,
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
        boxShadow: cs.shadowCard,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ParentStatItem(
            icon: Icons.child_care,
            value: '2',
            label: l10n.children,
            color: cs.tertiary,
          ),
          Container(
            width: 1,
            height: 40,
            color: cs.outline.withValues(alpha: 0.3),
          ),
          _ParentStatItem(
            icon: Icons.school,
            value: '5',
            label: l10n.classes,
            color: cs.primary,
          ),
          Container(
            width: 1,
            height: 40,
            color: cs.outline.withValues(alpha: 0.3),
          ),
          _ParentStatItem(
            icon: Icons.notifications_active,
            value: '12',
            label: l10n.notifications,
            color: cs.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildParentAccountInfo(
    BuildContext context,
    UserModel user,
    Color textColor,
    Color secondaryColor,
  ) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.accountInfo,
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: AppRadius.borderXxl,
            border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              _buildParentInfoRow(
                context,
                Icons.email_outlined,
                l10n.emailLabel,
                user.email,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildParentInfoRow(
                context,
                Icons.phone_outlined,
                l10n.phoneLabel,
                user.phone ?? l10n.notUpdated,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildParentInfoRow(
                context,
                Icons.calendar_today_outlined,
                l10n.joinedDate,
                _formatJoinDate(user.createdAt),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParentInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.tertiaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: cs.tertiary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              Text(
                value,
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParentQuickActions(BuildContext context, Color textColor) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.options,
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: AppRadius.borderXxl,
            border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              _buildParentActionTile(
                context,
                icon: Icons.edit_outlined,
                title: l10n.editProfile,
                onTap: _navigateToEditProfile,
              ),
              Divider(height: 1, color: cs.outline.withValues(alpha: 0.2)),
              _buildParentActionTile(
                context,
                icon: Icons.lock_outline,
                title: l10n.securityTitle,
                onTap: _navigateToSecurity,
              ),
              Divider(height: 1, color: cs.outline.withValues(alpha: 0.2)),
              _buildParentActionTile(
                context,
                icon: Icons.swap_horiz,
                title: l10n.switchRole,
                onTap: _navigateToSwitchRole,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParentActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      leading: Icon(icon, color: cs.tertiary),
      title: Text(
        title,
        style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
      onTap: onTap,
    );
  }

  void _navigateToSecurity() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const SecurityScreen()),
    );
  }

  void _navigateToSwitchRole() {
    // TODO: Implement switch role screen
  }
}

// ══════════════════════════════════════════════════════════════
//  PARENT STAT ITEM
// ══════════════════════════════════════════════════════════════

class _ParentStatItem extends StatelessWidget {
  const _ParentStatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: tt.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  TEACHER WIDGETS
// ══════════════════════════════════════════════════════════════

class _TeacherStatColumn extends StatelessWidget {
  const _TeacherStatColumn({
    required this.value,
    required this.label,
    required this.showStar,
  });

  final String value;
  final String label;
  final bool showStar;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
            if (showStar) ...[
              const SizedBox(width: 2),
              Icon(Icons.star_rounded, size: 18, color: cs.tertiary),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _FeaturedCourseCard extends StatelessWidget {
  const _FeaturedCourseCard({
    required this.title,
    required this.duration,
    required this.price,
    required this.rating,
    required this.students,
  });

  final String title;
  final String duration;
  final String price;
  final double rating;
  final int students;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: AppLayout.cardPaddingCompact,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: cs.outline),
        boxShadow: cs.shadowCard,
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.primary.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.borderMd,
            ),
            child: const Icon(
              Icons.play_circle_filled_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      duration,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(
                      Icons.people_outline_rounded,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '$students',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      price,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceTintedPrimary,
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: cs.tertiary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$rating',
                            style: tt.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  STUDENT TABS (Original)
// ══════════════════════════════════════════════════════════════

class _StudentOverviewTab extends StatelessWidget {
  const _StudentOverviewTab({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // BIO
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            children: [
              Text(
                '"',
                style: tt.displaySmall?.copyWith(
                  color: cs.primary.withValues(alpha: 0.3),
                  fontFamily: 'Georgia',
                  height: 0.5,
                ),
              ),
              Text(
                'Đam mê học hỏi về công nghệ và thiết kế sáng tạo.\n'
                'Hiện đang theo đuổi các khóa học về lập trình di động.',
                style: tt.bodyLarge?.copyWith(
                  color: cs.onSurface,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Hà Nội, Việt Nam',
                    style: tt.labelMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // SKILLS
        _PortfolioSection(
          title: AppLocalizations.of(context)!.skills,
          child: const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SkillTag(label: 'Flutter', level: 3),
              _SkillTag(label: 'UI/UX Design', level: 2),
              _SkillTag(label: 'Python', level: 2),
              _SkillTag(label: 'Data Science', level: 1),
              _SkillTag(label: 'React', level: 1),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // INTERESTS
        _PortfolioSection(
          title: AppLocalizations.of(context)!.interests,
          child: const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InterestChip(emoji: '🤖', label: 'AI/ML'),
              _InterestChip(emoji: '📱', label: 'Mobile Dev'),
              _InterestChip(emoji: '🎨', label: 'Design'),
              _InterestChip(emoji: '☁️', label: 'Cloud'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ACHIEVEMENTS
        _PortfolioSection(
          title: AppLocalizations.of(context)!.achievements,
          trailing: Text(
            AppLocalizations.of(context)!.viewAll,
            style: tt.labelSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Column(
            children: [
              _AchievementRow(
                emoji: '🏆',
                title: 'Top 10 Learner',
                subtitle: 'Tháng 3/2024',
                color: Color(0xFFF59E0B),
              ),
              SizedBox(height: 12),
              _AchievementRow(
                emoji: '🎓',
                title: 'Flutter Professional',
                subtitle: 'Chứng chỉ • 40Study Academy',
                color: Color(0xFF2563EB),
              ),
              SizedBox(height: 12),
              _AchievementRow(
                emoji: '🔥',
                title: '30 Days Streak',
                subtitle: 'Hoàn thành 15/02/2024',
                color: Color(0xFFEF4444),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // CONTACT
        _PortfolioSection(
          title: AppLocalizations.of(context)!.contact,
          child: Column(
            children: [
              _ContactRow(icon: Icons.email_outlined, text: user.email),
              if (user.phone != null && user.phone!.isNotEmpty)
                _ContactRow(icon: Icons.phone_outlined, text: user.phone!),
              _ContactRow(
                icon: Icons.calendar_today_outlined,
                text: _formatJoinDate(context, user.createdAt),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  String _formatJoinDate(BuildContext context, String? dateStr) {
    final l10n = AppLocalizations.of(context)!;
    if (dateStr == null) return l10n.notUpdated;
    try {
      final date = DateTime.parse(dateStr);
      return l10n.joinedOn('${date.month}/${date.year}');
    } on FormatException {
      return dateStr;
    }
  }
}

// ══════════════════════════════════════════════════════════════
//  TEACHER TABS (Original - for fallback)
// ══════════════════════════════════════════════════════════════

class _TeacherOverviewTab extends StatelessWidget {
  const _TeacherOverviewTab({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [cs.primary, cs.inversePrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.totalEarnings,
                      style: tt.labelMedium?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '42.500.000đ',
                      style: tt.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context)!.thisMonth,
                      style: tt.bodySmall?.copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _TeacherCoursesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _CourseItem(
          title: 'Thiết kế UI/UX Nâng cao',
          progress: 1.0,
          subtitle: '32 học viên • 24 bài học',
        ),
        SizedBox(height: 12),
        _CourseItem(
          title: 'Flutter từ Zero đến Hero',
          progress: 0.45,
          subtitle: '78 học viên • 36 bài học',
        ),
        SizedBox(height: 32),
      ],
    );
  }
}

class _AchievementsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(AppLocalizations.of(context)!.tabAchievements));
  }
}

// ══════════════════════════════════════════════════════════════
//  PARENT TABS
// ══════════════════════════════════════════════════════════════

class _ParentOverviewTab extends StatelessWidget {
  const _ParentOverviewTab({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(AppLocalizations.of(context)!.parentOverview));
  }
}

class _ParentChildrenTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(AppLocalizations.of(context)!.tabChildren));
  }
}

class _ParentNotificationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(AppLocalizations.of(context)!.tabNotifications));
  }
}

// ══════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ══════════════════════════════════════════════════════════════

class _PortfolioSection extends StatelessWidget {
  const _PortfolioSection({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SkillTag extends StatelessWidget {
  const _SkillTag({required this.label, required this.level});

  final String label;
  final int level;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: tt.labelMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          ...List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Icon(
                Icons.circle,
                size: 6,
                color: i < level
                    ? cs.primary
                    : cs.primary.withValues(alpha: 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  const _InterestChip({required this.emoji, required this.label});

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            label,
            style: tt.labelMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  const _AchievementRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseItem extends StatelessWidget {
  const _CourseItem({
    required this.title,
    required this.progress,
    required this.subtitle,
  });

  final String title;
  final double progress;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: cs.outlineVariant,
            color: cs.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  _PatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 30.0;
    const radius = 3.0;

    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

