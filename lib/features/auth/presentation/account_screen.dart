import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/auth/bloc/account/account_cubit.dart';
import 'package:study/features/auth/bloc/account/account_state.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/edit_profile_screen.dart';
import 'package:study/features/auth/presentation/security_screen.dart';
import 'package:study/features/auth/presentation/utils/role_utils.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/teacher/presentation/screens/switch_role_screen.dart';

enum AccountRoleType { teacher, student, parent }

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
      case AccountRoleType.parent:
        return 3;
    }
  }

  @override
  void initState() {
    super.initState();
    _cubit = AccountCubit(
      authRepository: diContainer.get<AuthRepository>(),
    )..loadAccount();
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
    final cs = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: cs.surfaceContainerLowest,
        body: BlocConsumer<AccountCubit, AccountState>(
          listener: (context, state) {
            if (state is AccountUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cập nhật thành công'),
                  backgroundColor:
                      Theme.of(context).colorScheme.tertiary,
                ),
              );
              context.read<AuthBloc>().add(AuthUserUpdated(state.user));
            }
            if (state is AccountFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is AccountLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is! AuthAuthenticated) {
                  return const Center(child: Text('Chưa đăng nhập'));
                }

                final user = authState.user;
                final profile = authState.activeProfile;

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

  Widget _buildSliverAppBar(
    BuildContext context,
    UserModel user,
    ProfileModel? profile,
  ) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final gradient = _gradientForRole(widget.roleType, cs);

    return SliverAppBar(
      expandedHeight: 300,
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
            child:
                const Icon(Icons.more_horiz, color: Colors.white, size: 20),
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt,
                              color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Sửa ảnh bìa',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 130,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.surface, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: cs.shadow.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: cs.primaryContainer,
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null
                              ? Text(
                                  _getInitials(
                                      user.fullName ?? user.username),
                                  style: tt.headlineMedium?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
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
                              border:
                                  Border.all(color: cs.surface, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName ?? user.username,
                    style: tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (profile != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                RoleUtils.getIcon(profile.roleName),
                                size: 14,
                                color: cs.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                RoleUtils.getLabel(profile.roleName),
                                style: tt.labelSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: cs.primary,
                      ),
                    ],
                  ),
                ],
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
                  tabs: _tabsForRole(widget.roleType),
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
    }
  }

  static List<Tab> _tabsForRole(AccountRoleType role) {
    switch (role) {
      case AccountRoleType.teacher:
        return const [
          Tab(text: 'Tổng quan'),
          Tab(text: 'Khóa học'),
          Tab(text: 'Thành tích'),
        ];
      case AccountRoleType.student:
        return const [
          Tab(text: 'Tổng quan'),
        ];
      case AccountRoleType.parent:
        return const [
          Tab(text: 'Tổng quan'),
          Tab(text: 'Con em'),
          Tab(text: 'Thông báo'),
        ];
    }
  }

  static List<Widget> _tabViewsForRole(
    AccountRoleType role,
    UserModel user,
  ) {
    switch (role) {
      case AccountRoleType.teacher:
        return [
          _TeacherOverviewTab(user: user),
          _TeacherCoursesTab(),
          _AchievementsTab(),
        ];
      case AccountRoleType.student:
        return [
          _StudentOverviewTab(user: user),
        ];
      case AccountRoleType.parent:
        return [
          _ParentOverviewTab(user: user),
          _ParentChildrenTab(),
          _ParentNotificationsTab(),
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

  void _showOptionsMenu(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Chỉnh sửa trang cá nhân'),
              onTap: () {
                Navigator.pop(context);
                _navigateToEditProfile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Chia sẻ trang cá nhân'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Chuyển đổi vai trò'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const SwitchRoleScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Bảo mật tài khoản'),
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
              leading: const Icon(Icons.qr_code),
              title: const Text('Mã QR của tôi'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Sao chép liên kết'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.logout, color: cs.error),
              title: Text('Đăng xuất', style: TextStyle(color: cs.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmLogout(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(AuthLoggedOut());
            },
            child: const Text('Đăng xuất'),
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
        builder: (_) => BlocProvider.value(
          value: _cubit,
          child: const EditProfileScreen(),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  TEACHER TABS
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
        // Revenue highlight card
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
                      'Tổng thu nhập',
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
                      'tháng này',
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
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.school,
                value: '8',
                label: 'Khóa học',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.people,
                value: '156',
                label: 'Học viên',
                color: Colors.teal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.star,
                value: '4.9',
                label: 'Đánh giá',
                color: Colors.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Giới thiệu',
          icon: Icons.info_outline,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Giảng viên chuyên ngành Công nghệ thông tin. '
                'Hơn 5 năm kinh nghiệm giảng dạy UI/UX và lập trình Flutter.',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              _InfoRow(icon: Icons.email_outlined, text: user.email),
              if (user.phone != null && user.phone!.isNotEmpty)
                _InfoRow(icon: Icons.phone_outlined, text: user.phone!),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                text: _formatJoinDate(user.createdAt),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Chuyên môn',
          icon: Icons.workspace_premium,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _SkillChip(label: 'Flutter'),
              _SkillChip(label: 'UI/UX Design'),
              _SkillChip(label: 'Dart'),
              _SkillChip(label: 'Figma'),
              _SkillChip(label: 'Data Science'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Đánh giá từ học viên',
          icon: Icons.rate_review_outlined,
          child: Column(
            children: [
              _ReviewItem(
                name: 'Nguyễn Văn A',
                rating: 5,
                comment: 'Giảng viên rất tận tâm, bài giảng dễ hiểu!',
                time: '2 ngày trước',
              ),
              const Divider(height: 24),
              _ReviewItem(
                name: 'Trần Thị B',
                rating: 5,
                comment: 'Khóa Flutter rất hay, học xong làm được project thực tế.',
                time: '1 tuần trước',
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
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CourseItem(
          title: 'Thiết kế UI/UX Nâng cao',
          progress: 1.0,
          subtitle: '32 học viên • 24 bài học',
        ),
        const SizedBox(height: 12),
        _CourseItem(
          title: 'Nguyên lý Hệ điều hành',
          progress: 0.7,
          subtitle: '45 học viên • 18 bài học',
        ),
        const SizedBox(height: 12),
        _CourseItem(
          title: 'Flutter từ Zero đến Hero',
          progress: 0.45,
          subtitle: '78 học viên • 36 bài học',
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {},
            child: Text(
              'Xem tất cả khóa học',
              style: TextStyle(color: cs.primary),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  STUDENT TABS
// ══════════════════════════════════════════════════════════════

class _StudentOverviewTab extends StatelessWidget {
  const _StudentOverviewTab({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Learning progress highlight
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [cs.secondary, cs.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tiến độ học tập',
                      style: tt.labelMedium?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    '72%',
                    style: tt.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: 0.72,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '48/67 bài học hoàn thành',
                style: tt.bodySmall?.copyWith(color: Colors.white60),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.class_outlined,
                value: '5',
                label: 'Lớp học',
                color: Colors.indigo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.emoji_events,
                value: '5',
                label: 'Chứng chỉ',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.schedule,
                value: '128h',
                label: 'Giờ học',
                color: Colors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Giới thiệu',
          icon: Icons.info_outline,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đam mê học hỏi về công nghệ và thiết kế sáng tạo. '
                'Hiện đang theo đuổi các khóa học về Khoa học dữ liệu.',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              _InfoRow(icon: Icons.email_outlined, text: user.email),
              if (user.phone != null && user.phone!.isNotEmpty)
                _InfoRow(icon: Icons.phone_outlined, text: user.phone!),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                text: _formatJoinDate(user.createdAt),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.child_care,
                value: '2',
                label: 'Con em',
                color: Colors.teal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.class_,
                value: '5',
                label: 'Lớp học',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.trending_up,
                value: '92%',
                label: 'Chuyên cần',
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionCard(
          title: 'Thông tin phụ huynh',
          icon: Icons.info_outline,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phụ huynh đang theo dõi tiến độ học tập và '
                'chuyên cần của con em tại hệ thống.',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              _InfoRow(icon: Icons.email_outlined, text: user.email),
              if (user.phone != null && user.phone!.isNotEmpty)
                _InfoRow(icon: Icons.phone_outlined, text: user.phone!),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                text: _formatJoinDate(user.createdAt),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _ParentChildrenTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ChildSummaryCard(
          name: 'Nguyễn Văn A',
          grade: 'Lớp 10',
          attendance: '95%',
          avgScore: '8.5',
        ),
        const SizedBox(height: 12),
        _ChildSummaryCard(
          name: 'Nguyễn Văn B',
          grade: 'Lớp 7',
          attendance: '88%',
          avgScore: '7.2',
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _ParentNotificationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _ActivityItem(
          icon: Icons.assignment,
          iconColor: Colors.blue,
          title: 'Nguyễn Văn A đã nộp bài tập Toán',
          time: '1 giờ trước',
        ),
        _ActivityItem(
          icon: Icons.event_available,
          iconColor: Colors.green,
          title: 'Nguyễn Văn B có mặt buổi học hôm nay',
          time: '3 giờ trước',
        ),
        _ActivityItem(
          icon: Icons.warning_amber,
          iconColor: Colors.orange,
          title: 'Nguyễn Văn A vắng buổi học Lý',
          time: 'Hôm qua',
        ),
        _ActivityItem(
          icon: Icons.grade,
          iconColor: Colors.purple,
          title: 'Nguyễn Văn B đạt 9.0 bài kiểm tra Anh văn',
          time: '2 ngày trước',
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SHARED / REUSABLE WIDGETS
// ══════════════════════════════════════════════════════════════

class _PatternPainter extends CustomPainter {
  _PatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 30.0;
    for (var i = 0.0; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(0, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _formatJoinDate(String? dateStr) {
  if (dateStr == null) return 'Tham gia gần đây';
  final date = DateTime.tryParse(dateStr);
  if (date == null) return 'Tham gia gần đây';

  const months = [
    '', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
    'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
    'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
  ];
  return 'Tham gia ${months[date.month]} ${date.year}';
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          Text(
            label,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: tt.bodyMedium?.copyWith(color: cs.onSurface),
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
    this.subtitle,
  });

  final String title;
  final double progress;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.play_arrow, color: cs.primary),
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
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: tt.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: cs.surfaceContainerHighest,
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: tt.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
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

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.time,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style:
                      tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: const [
        _AchievementBadge(
          icon: Icons.local_fire_department,
          label: '7 ngày liên tiếp',
          color: Colors.orange,
          unlocked: true,
        ),
        _AchievementBadge(
          icon: Icons.school,
          label: 'Học viên xuất sắc',
          color: Colors.blue,
          unlocked: true,
        ),
        _AchievementBadge(
          icon: Icons.speed,
          label: 'Nhanh như chớp',
          color: Colors.purple,
          unlocked: true,
        ),
        _AchievementBadge(
          icon: Icons.star,
          label: 'Ngôi sao mới',
          color: Colors.amber,
          unlocked: true,
        ),
        _AchievementBadge(
          icon: Icons.emoji_events,
          label: 'Vô địch quiz',
          color: Colors.green,
          unlocked: false,
        ),
        _AchievementBadge(
          icon: Icons.rocket_launch,
          label: 'Tiên phong',
          color: Colors.red,
          unlocked: false,
        ),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.unlocked,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: unlocked
            ? Border.all(color: color.withValues(alpha: 0.3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: unlocked
                  ? color.withValues(alpha: 0.1)
                  : cs.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: unlocked
                  ? color
                  : cs.onSurfaceVariant.withValues(alpha: 0.5),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: unlocked ? cs.onSurface : cs.onSurfaceVariant,
              fontWeight: unlocked ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: cs.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({
    required this.name,
    required this.rating,
    required this.comment,
    required this.time,
  });

  final String name;
  final int rating;
  final String comment;
  final String time;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: cs.primaryContainer,
          child: Text(
            name.isNotEmpty ? name[0] : '?',
            style: TextStyle(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    time,
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < rating ? Icons.star : Icons.star_border,
                    size: 14,
                    color: Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                comment,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChildSummaryCard extends StatelessWidget {
  const _ChildSummaryCard({
    required this.name,
    required this.grade,
    required this.attendance,
    required this.avgScore,
  });

  final String name;
  final String grade;
  final String attendance;
  final String avgScore;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.person, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '$grade • Chuyên cần $attendance • TB $avgScore',
                  style:
                      tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}
