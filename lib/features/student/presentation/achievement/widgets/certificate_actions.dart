import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class CertificateActions extends StatelessWidget {
  const CertificateActions({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Builder(builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Row(
          children: [
            Expanded(
                child: _ActionItem(icon: Icons.download_rounded, label: l10n.download)),
            const _VerticalDivider(),
            Expanded(
                child: _ActionItem(icon: Icons.share_rounded, label: l10n.share)),
            const _VerticalDivider(),
            Expanded(
                child: _ActionItem(
                    icon: Icons.link_rounded, label: l10n.addToLinkedIn)),
            const _VerticalDivider(),
            Expanded(
                child: _ActionItem(icon: Icons.print_rounded, label: l10n.printCertificate)),
          ],
        );
      }),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: cs.onSurface),
            AppSpacing.vGap8,
            Text(label,
                style: tt.labelSmall?.copyWith(color: cs.onSurface),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
        width: 1, height: 48, color: cs.outlineVariant.withValues(alpha: 0.5));
  }
}
