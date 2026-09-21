import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          AppSpacing.hGap8,
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_rounded,
              size: 64,
              color: cs.primary.withValues(alpha: 0.5),
            ),
            AppSpacing.vGap16,
            Text(
              'Trang chủ',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            AppSpacing.vGap8,
            Text(
              'Coming soon',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
