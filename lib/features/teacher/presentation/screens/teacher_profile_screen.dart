import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Cá nhân'),
        backgroundColor: cs.surface,
        elevation: 0,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;
          final profile = state.activeProfile;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: cs.primaryContainer,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? Icon(
                              Icons.person,
                              size: 48,
                              color: cs.primary,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile?.displayName ?? user.username,
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Giảng viên',
                        style: TextStyle(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Menu items
              _ProfileMenuItem(
                icon: Icons.person_outline,
                title: 'Thông tin cá nhân',
                onTap: () {},
              ),
              _ProfileMenuItem(
                icon: Icons.school_outlined,
                title: 'Khóa học của tôi',
                onTap: () {},
              ),
              _ProfileMenuItem(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Thu nhập & Thanh toán',
                onTap: () {},
              ),
              _ProfileMenuItem(
                icon: Icons.bar_chart_outlined,
                title: 'Thống kê',
                onTap: () {},
              ),
              _ProfileMenuItem(
                icon: Icons.settings_outlined,
                title: 'Cài đặt',
                onTap: () {},
              ),
              _ProfileMenuItem(
                icon: Icons.help_outline,
                title: 'Trợ giúp',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _ProfileMenuItem(
                icon: Icons.logout,
                title: 'Đăng xuất',
                textColor: cs.error,
                iconColor: cs.error,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Đăng xuất'),
                      content: const Text(
                        'Bạn có chắc chắn muốn đăng xuất?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Hủy'),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.read<AuthBloc>().add(AuthLoggedOut());
                          },
                          child: const Text('Đăng xuất'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? cs.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: tt.bodyLarge?.copyWith(
          color: textColor ?? cs.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: cs.onSurfaceVariant,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
