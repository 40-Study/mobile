import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/data/models/user_model.dart';
import 'package:study/features/auth/presentation/edit_profile_screen.dart';
import 'package:study/features/auth/presentation/security_screen.dart';
import 'package:study/features/student/presentation/bookmark/bookmark_screen.dart';
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
            body: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
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
      appBar: AppBar(title: const Text('Tài khoản')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.sm,
          AppSpacing.screenPadding,
          AppSpacing.xxl,
        ),
        children: [
          _ProfileHeader(user: user),
          AppSpacing.vGap24,
          const _StatsRow(),
          AppSpacing.vGap24,
          const _MenuSections(),
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
    final name = user.fullName ?? user.username ?? 'Người dùng';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: cs.outline),
          ),
          child: CircleAvatar(
            radius: 34,
            backgroundColor: cs.primaryContainer,
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? Text(
                    _getInitials(name),
                    style: tt.titleLarge?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : null,
          ),
        ),
        AppSpacing.hGap16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.vGap4,
              Text(
                user.email,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.vGap8,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'Học sinh',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const EditProfileScreen()),
          ),
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Chỉnh sửa hồ sơ',
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.auto_stories_outlined,
              value: '5',
              label: 'Khóa học',
              color: cs.primary,
            ),
          ),
          _divider(cs),
          Expanded(
            child: _StatItem(
              icon: Icons.local_fire_department_outlined,
              value: '12',
              label: 'Chuỗi ngày',
              color: cs.tertiary,
            ),
          ),
          _divider(cs),
          Expanded(
            child: _StatItem(
              icon: Icons.bolt_outlined,
              value: '2.4k',
              label: 'Điểm XP',
              color: cs.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(ColorScheme cs) {
    return Container(width: 1, height: 44, color: cs.outlineVariant);
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
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

    return Column(
      children: [
        Icon(icon, color: color, size: 21),
        AppSpacing.vGap4,
        Text(
          value,
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _MenuSections extends StatelessWidget {
  const _MenuSections();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        _MenuSection(
          title: 'Tài khoản',
          items: [
            _MenuItem(
              icon: Icons.person_outline,
              title: 'Thông tin cá nhân',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const EditProfileScreen(),
                ),
              ),
            ),
            _MenuItem(
              icon: Icons.lock_outline,
              title: 'Bảo mật',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const SecurityScreen()),
              ),
            ),
            _MenuItem(
              icon: Icons.bookmark_outline,
              title: 'Nội dung đã lưu',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const BookmarkScreen()),
              ),
            ),
          ],
        ),
        AppSpacing.vGap16,
        _MenuSection(
          title: 'Ứng dụng',
          items: [
            _MenuItem(
              icon: Icons.tune_outlined,
              title: 'Cài đặt',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              ),
            ),
            _MenuItem(
              icon: Icons.help_outline,
              title: 'Trợ giúp và hỗ trợ',
              onTap: () => _showComingSoon(context),
            ),
            _MenuItem(
              icon: Icons.info_outline,
              title: 'Giới thiệu 40Study',
              onTap: () => _showComingSoon(context),
            ),
          ],
        ),
        AppSpacing.vGap16,
        _MenuSection(
          items: [
            _MenuItem(
              icon: Icons.logout,
              title: 'Đăng xuất',
              iconColor: cs.error,
              titleColor: cs.error,
              onTap: () => _confirmLogout(context),
            ),
          ],
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng đang được hoàn thiện')),
    );
  }

  void _confirmLogout(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi 40Study?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              authBloc.add(AuthLoggedOut());
            },
            child: const Text('Đăng xuất'),
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
            padding: const EdgeInsets.only(left: 2, bottom: AppSpacing.sm),
            child: Text(
              title!,
              style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: cs.outline),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1)
                  const Divider(indent: 56, endIndent: 16),
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
      leading: Icon(icon, color: iconColor ?? cs.onSurfaceVariant, size: 22),
      title: Text(
        title,
        style: tt.bodyMedium?.copyWith(
          color: titleColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: cs.onSurfaceVariant,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
