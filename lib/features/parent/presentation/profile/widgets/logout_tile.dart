import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class LogoutTile extends StatelessWidget {
  const LogoutTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final errorColor = TogetherSemanticColors.error;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderLg,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: errorColor.withValues(alpha: 0.05),
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: errorColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.1),
                borderRadius: AppRadius.borderSm,
              ),
              child: Icon(Icons.logout_rounded, size: 20, color: errorColor),
            ),
            AppSpacing.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.logout,
                    style: tt.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: errorColor,
                    ),
                  ),
                  Text(
                    l10n.signOutHint,
                    style: tt.bodySmall?.copyWith(
                      color: errorColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: errorColor),
          ],
        ),
      ),
    );
  }
}

void showLogoutConfirmation(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  final tt = Theme.of(context).textTheme;
  final l10n = AppLocalizations.of(context)!;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          AppSpacing.vGap24,
          const Icon(
            Icons.logout_rounded,
            size: 48,
            color: TogetherSemanticColors.error,
          ),
          AppSpacing.vGap16,
          Text(
            l10n.logout,
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          AppSpacing.vGap8,
          Text(
            l10n.logoutConfirm,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vGap24,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.cancel),
                ),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.read<AuthBloc>().add(AuthLoggedOut());
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: TogetherSemanticColors.error,
                  ),
                  child: Text(l10n.logout),
                ),
              ),
            ],
          ),
          AppSpacing.vGap16,
        ],
      ),
    ),
  );
}
