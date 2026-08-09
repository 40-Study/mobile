import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class AuthFormCard extends StatelessWidget {
  const AuthFormCard({super.key, required this.child, this.showLogo = false});

  final Widget child;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.xl + 4),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl - 4,
        AppSpacing.xl + 4,
        AppSpacing.xl - 4,
        AppSpacing.xl + 4,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderXl,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.06),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLogo) ...[
            Text(
              l10n.appTitle,
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
            AppSpacing.vGap32,
          ],
          child,
        ],
      ),
    );
  }
}
