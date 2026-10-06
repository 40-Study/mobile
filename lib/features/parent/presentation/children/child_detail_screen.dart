import 'package:flutter/material.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/parent/presentation/children/widgets/widgets.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/cached_avatar.dart';

class ChildDetailScreen extends StatelessWidget {
  const ChildDetailScreen({super.key, required this.child});

  final UserModel child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(child.fullName ?? 'Chi tiết'),
        actions: [
          TextButton.icon(
            onPressed: () => _navigateToEdit(context),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Sửa'),
          ),
          AppSpacing.hGap8,
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Avatar + Name card
          _ProfileCard(child: child),
          AppSpacing.vGap24,
          // Info section
          InfoSection(
            title: 'Thông tin cơ bản',
            items: [
              InfoItem(
                icon: Icons.person_outline,
                label: 'Họ và tên',
                value: child.fullName ?? 'Chưa cập nhật',
              ),
              InfoItem(
                icon: Icons.email_outlined,
                label: 'Email',
                value: child.email.isNotEmpty ? child.email : 'Chưa cập nhật',
              ),
              InfoItem(
                icon: Icons.phone_outlined,
                label: 'Số điện thoại',
                value: child.phone ?? 'Chưa cập nhật',
              ),
              InfoItem(
                icon: Icons.cake_outlined,
                label: 'Ngày sinh',
                value: child.dateOfBirth ?? 'Chưa cập nhật',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sửa thông tin - Coming soon')),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.child});

  final UserModel child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: cs.primary.withValues(alpha: 0.2),
                width: 3,
              ),
            ),
            child: CachedAvatar(
              url: child.avatarUrl,
              radius: 45,
              backgroundColor: cs.primaryContainer,
              name: child.fullName ?? 'Con',
            ),
          ),
          AppSpacing.vGap16,
          Text(
            child.fullName ?? 'Chưa có tên',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (child.email.isNotEmpty) ...[
            AppSpacing.vGap4,
            Text(
              child.email,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
