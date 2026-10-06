import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class ChildrenEmptyState extends StatelessWidget {
  const ChildrenEmptyState({super.key, required this.onAddChild});

  final VoidCallback onAddChild;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.family_restroom_rounded,
                color: cs.primary,
                size: 40,
              ),
            ),
            AppSpacing.vGap24,
            Text(
              'Chưa có hồ sơ con nào',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            AppSpacing.vGap8,
            Text(
              'Liên kết hồ sơ con để theo dõi tiến độ học tập',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap24,
            FilledButton.icon(
              onPressed: onAddChild,
              icon: const Icon(Icons.link_rounded, size: 18),
              label: const Text('Liên kết hồ sơ con'),
            ),
          ],
        ),
      ),
    );
  }
}
