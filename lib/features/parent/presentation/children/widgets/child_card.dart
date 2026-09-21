import 'package:flutter/material.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/cached_avatar.dart';

class ChildCard extends StatelessWidget {
  const ChildCard({super.key, required this.child, required this.onTap});

  final UserModel child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderLg,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
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
            CachedAvatar(
              url: child.avatarUrl,
              radius: 28,
              backgroundColor: cs.primaryContainer,
              name: child.fullName ?? 'Con',
            ),
            AppSpacing.hGap16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.fullName ?? 'Chưa có tên',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (child.email.isNotEmpty) ...[
                    AppSpacing.vGap4,
                    Text(
                      child.email,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class AddChildButton extends StatelessWidget {
  const AddChildButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderLg,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.05),
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: cs.primary, size: 20),
            AppSpacing.hGap8,
            Text(
              'Liên kết thêm hồ sơ con',
              style: tt.labelLarge?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
