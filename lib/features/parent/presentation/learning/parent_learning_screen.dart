import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class ParentLearningScreen extends StatelessWidget {
  const ParentLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Học tập'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_rounded,
              size: 64,
              color: cs.primary.withValues(alpha: 0.5),
            ),
            AppSpacing.vGap16,
            Text(
              'Học tập',
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
