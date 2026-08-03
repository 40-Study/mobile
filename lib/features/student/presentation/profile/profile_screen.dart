import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/data/models/user_model.dart';
import 'package:study/features/auth/presentation/edit_profile_screen.dart';
import 'package:study/features/auth/presentation/security_screen.dart';
import 'package:study/features/student/presentation/settings/settings_screen.dart';
import 'package:study/theme/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _ProfileContent(user: state.user);
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _ProfileHeader(user: user),
          ),

          // Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _StatsRow(),
            ),
          ),

          const SliverToBoxAdapter(child: AppSpacing.vGap24),

          // Menu sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _MenuSections(user: user),
            ),
          ),

          const SliverToBoxAdapter(child: AppSpacing.vGap32),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.lg,
        bottom: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary,
            cs.primary.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? Text(
                      _getInitials(user.fullName ?? user.username ?? 'U'),
                      style: tt.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          AppSpacing.vGap12,

          // Name
          Text(
            user.fullName ?? user.username ?? 'User',
            style: tt.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.vGap4,

          // Email
          Text(
            user.email,
            style: tt.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          AppSpacing.vGap8,

          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.school, size: 14, color: Colors.white),
                AppSpacing.hGap4,
                Text(
                  'Hoc sinh',
                  style: tt.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Transform.translate(
      offset: const Offset(0, -24),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _StatItem(icon: Icons.school, value: '5', label: 'Khoa hoc'),
            _divider(cs),
            _StatItem(icon: Icons.local_fire_department, value: '12', label: 'Streak'),
            _divider(cs),
            _StatItem(icon: Icons.star, value: '2.4k', label: 'XP'),
          ],
        ),
      ),
    );
  }

  Widget _divider(ColorScheme cs) {
    return Container(
      width: 1,
      height: 40,
      color: cs.outline.withValues(alpha: 0.2),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: cs.primary, size: 24),
          AppSpacing.vGap4,
          Text(
            value,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            label,
            style: tt.bodySmall?.copyWith(color: cs.outline),
          ),
        ],
      ),
    );
  }
}

class _MenuSections extends StatelessWidget {
  const _MenuSections({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tai khoan
        _MenuSection(
          title: 'Tai khoan',
          items: [
            _MenuItem(
              icon: Icons.person_outline,
              title: 'Chinh sua thong tin',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const EditProfileScreen()),
              ),
            ),
            _MenuItem(
              icon: Icons.lock_outline,
              title: 'Bao mat',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const SecurityScreen()),
              ),
            ),
            _MenuItem(
              icon: Icons.bookmark_outline,
              title: 'Da luu',
              onTap: () {},
            ),
          ],
        ),
        AppSpacing.vGap16,

        // Cai dat
        _MenuSection(
          title: 'Cai dat',
          items: [
            _MenuItem(
              icon: Icons.settings_outlined,
              title: 'Cai dat ung dung',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              ),
            ),
            _MenuItem(
              icon: Icons.help_outline,
              title: 'Tro giup & Ho tro',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.info_outline,
              title: 'Gioi thieu',
              onTap: () {},
            ),
          ],
        ),
        AppSpacing.vGap16,

        // Dang xuat
        _MenuSection(
          items: [
            _MenuItem(
              icon: Icons.logout,
              title: 'Dang xuat',
              iconColor: cs.error,
              titleColor: cs.error,
              onTap: () => _confirmLogout(context),
            ),
          ],
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dang xuat'),
        content: const Text('Ban co chac muon dang xuat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              authBloc.add(AuthLoggedOut());
            },
            child: const Text('Dang xuat'),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({this.title, required this.items});

  final String? title;
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
            child: Text(
              title!,
              style: tt.labelLarge?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1) const Divider(height: 1, indent: 56),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      leading: Icon(icon, color: iconColor ?? cs.primary, size: 22),
      title: Text(
        title,
        style: tt.bodyMedium?.copyWith(color: titleColor),
      ),
      trailing: Icon(Icons.chevron_right, color: cs.outline, size: 20),
      onTap: onTap,
    );
  }
}
