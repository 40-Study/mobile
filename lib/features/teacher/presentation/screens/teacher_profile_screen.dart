import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/presentation/edit_profile_screen.dart';
import 'package:study/features/teacher/presentation/screens/switch_role_screen.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;
          final profile = state.activeProfile;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppLayout.screenMargin,
                AppSpacing.xxl,
                AppLayout.screenMargin,
                AppSpacing.xxxl,
              ),
              children: [
                _ProfileHeader(
                  name: profile?.displayName ?? user.fullName ?? user.username,
                  email: user.email,
                  avatarUrl: user.avatarUrl,
                  roleLabel: 'Giang vien',
                ),
                const SizedBox(height: AppSpacing.xxl),
                const _SectionTitle(title: 'Tai khoan'),
                const SizedBox(height: AppSpacing.sm),
                _MenuItem(
                  icon: Icons.person_outline,
                  title: 'Thong tin ca nhan',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ),
                ),
                _MenuItem(
                  icon: Icons.school_outlined,
                  title: 'Khoa hoc cua toi',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Thu nhap & Thanh toan',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.bar_chart_outlined,
                  title: 'Thong ke',
                  onTap: () {},
                ),
                const SizedBox(height: AppSpacing.xl),
                const _SectionTitle(title: 'Cai dat'),
                const SizedBox(height: AppSpacing.sm),
                _MenuItem(
                  icon: Icons.swap_horiz,
                  title: 'Chuyen doi vai tro',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const SwitchRoleScreen(),
                    ),
                  ),
                ),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Thong bao',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.security_outlined,
                  title: 'Bao mat tai khoan',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  title: 'Tro giup',
                  onTap: () {},
                ),
                const SizedBox(height: AppSpacing.xl),
                _MenuItem(
                  icon: Icons.logout,
                  title: 'Dang xuat',
                  textColor: cs.error,
                  iconColor: cs.error,
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dang xuat'),
        content: const Text('Ban co chac chan muon dang xuat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(AuthLoggedOut());
            },
            child: const Text('Dang xuat'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.roleLabel,
    this.avatarUrl,
  });

  final String name;
  final String email;
  final String roleLabel;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: cs.primaryContainer,
          backgroundImage:
              avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null
              ? Icon(Icons.person, size: AppIconSize.avatar, color: cs.primary)
              : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          name,
          style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          email,
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: AppRadius.borderXxl,
          ),
          child: Text(
            roleLabel,
            style: TextStyle(
              color: cs.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        leading: Container(
          width: AppIconSize.avatar,
          height: AppIconSize.avatar,
          decoration: BoxDecoration(
            color: iconColor != null
                ? iconColor!.withValues(alpha: 0.1)
                : cs.primaryContainer,
            borderRadius: AppRadius.borderMd,
          ),
          child: Icon(
            icon,
            color: iconColor ?? cs.primary,
            size: AppIconSize.md,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: cs.outlineVariant,
          size: AppIconSize.md,
        ),
        onTap: onTap,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
        ),
        tileColor: cs.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
    );
  }
}
