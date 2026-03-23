import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/presentation/account_screen.dart';
import 'package:study/features/auth/presentation/security_screen.dart';
import 'package:study/features/auth/presentation/utils/role_utils.dart';
import 'package:study/features/teacher/presentation/screens/switch_role_screen.dart';

class TeacherSettingsScreen extends StatelessWidget {
  const TeacherSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cs.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Cài đặt'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.circle, color: cs.primary, size: 12),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card
          const _ProfileCard(),
          const SizedBox(height: 24),

          // Account settings section
          _SectionHeader(title: 'CÀI ĐẶT TÀI KHOẢN'),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _SettingsItem(
                icon: Icons.person_outline,
                iconBgColor: cs.primary,
                title: 'Thông tin cá nhân',
                subtitle: 'Tên, Email & Số điện thoại',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AccountScreen(),
                  ),
                ),
              ),
              _SettingsItem(
                icon: Icons.shield_outlined,
                iconBgColor: cs.primary,
                title: 'Bảo mật & Mật khẩu',
                subtitle: 'Đổi mật khẩu, xác thực 2 lớp',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const SecurityScreen(),
                  ),
                ),
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  String currentRole = 'Chưa xác định';
                  if (state is AuthAuthenticated) {
                    final profile = state.activeProfile;
                    if (profile != null) {
                      currentRole = RoleUtils.getLabel(profile.roleName);
                    }
                  }
                  return _SettingsItem(
                    icon: Icons.swap_horiz,
                    iconBgColor: cs.primary,
                    title: 'Chuyển đổi vai trò',
                    subtitle: 'Vai trò hiện tại: $currentRole',
                    showDivider: false,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const SwitchRoleScreen(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // App & Support section
          _SectionHeader(title: 'ỨNG DỤNG & HỖ TRỢ'),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _SettingsItem(
                icon: Icons.notifications_outlined,
                iconBgColor: Colors.red.shade400,
                title: 'Thông báo',
                subtitle: 'Âm thanh, tin nhắn & email',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.help_outline,
                iconBgColor: cs.primary,
                title: 'Trợ giúp & Hỗ trợ',
                subtitle: 'Điều khoản, phản hồi',
                showDivider: false,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Logout button
          const _LogoutButton(),
          const SizedBox(height: 16),

          // Version
          Center(
            child: Text(
              'PHIÊN BẢN 2.4.1 (STABLE)',
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }

        final user = authState.user;
        final profile = authState.activeProfile;
        final roleName = profile != null
            ? '${RoleUtils.getLabel(profile.roleName)} Cao cấp'
            : 'Người dùng';

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
              // Avatar with badge
              Stack(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: cs.primaryContainer,
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Icon(Icons.person, size: 32, color: cs.primary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.surface, width: 2),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName ?? user.username,
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roleName,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const AccountScreen(),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Trang cá nhân',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: cs.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: cs.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
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
      child: Column(children: children),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconBgColor, size: 22),
          ),
          title: Text(
            title,
            style: tt.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: cs.onSurfaceVariant,
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 76,
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      onPressed: () {
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
                style: FilledButton.styleFrom(
                  backgroundColor: cs.error,
                ),
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
        );
      },
      icon: Icon(Icons.logout, color: cs.error),
      label: Text(
        'Đăng xuất',
        style: TextStyle(
          color: cs.error,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: BorderSide.none,
        backgroundColor: cs.error.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
