import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class CertificateTopBar extends StatelessWidget {
  const CertificateTopBar({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          CertificateIconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
          const Spacer(),
          CertificateIconButton(icon: Icons.ios_share_rounded, onTap: () {}),
          AppSpacing.hGap8,
          CertificateIconButton(
            icon: Icons.more_horiz_rounded,
            onTap: () => _showMoreOptions(context),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Padding(
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
            CertificateMoreOption(
              icon: Icons.download_rounded,
              label: AppLocalizations.of(context)!.downloadPdf,
              onTap: () => Navigator.pop(context),
            ),
            CertificateMoreOption(
              icon: Icons.link_rounded,
              label: AppLocalizations.of(context)!.copyLink,
              onTap: () => Navigator.pop(context),
            ),
            CertificateMoreOption(
              icon: Icons.qr_code_rounded,
              label: AppLocalizations.of(context)!.showQrCode,
              onTap: () => Navigator.pop(context),
            ),
            CertificateMoreOption(
              icon: Icons.report_outlined,
              label: AppLocalizations.of(context)!.reportIssue,
              onTap: () => Navigator.pop(context),
            ),
            AppSpacing.vGap16,
          ],
        ),
      ),
    );
  }
}

class CertificateIconButton extends StatelessWidget {
  const CertificateIconButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, size: 20, color: cs.onSurface),
      ),
    );
  }
}

class CertificateMoreOption extends StatelessWidget {
  const CertificateMoreOption({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: cs.onSurface),
      title: Text(label, style: tt.bodyLarge),
      onTap: onTap,
    );
  }
}
