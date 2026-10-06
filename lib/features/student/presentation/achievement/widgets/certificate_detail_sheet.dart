import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

import '../all_certificates_screen.dart';

/// Bottom sheet cho certificate detail (in-progress)
class CertificateDetailSheet extends StatelessWidget {
  const CertificateDetailSheet({super.key, required this.certificate});

  final CertificateData certificate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isCompleted = certificate.isCompleted;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          AppSpacing.vGap24,
          // Preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: certificate.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: certificate.color.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  isCompleted
                      ? Icons.workspace_premium_rounded
                      : Icons.school_rounded,
                  size: 48,
                  color: certificate.color,
                ),
                AppSpacing.vGap12,
                if (isCompleted)
                  Text(l10n.certificate.toUpperCase(),
                      style: tt.labelMedium?.copyWith(
                          color: certificate.color,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700))
                else
                  Text(l10n.studying.toUpperCase(),
                      style: tt.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600)),
                AppSpacing.vGap8,
                Text(certificate.courseTitle,
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center),
                AppSpacing.vGap4,
                Text(certificate.instructorName,
                    style: tt.bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          AppSpacing.vGap16,
          // Details
          _DetailRow(label: l10n.duration, value: certificate.duration ?? '-'),
          if (isCompleted && certificate.certificateNumber != null)
            _DetailRow(label: l10n.certificate, value: certificate.certificateNumber!),
          if (isCompleted && certificate.issueDate != null)
            _DetailRow(
                label: l10n.completionDate,
                value:
                    '${certificate.issueDate!.day}/${certificate.issueDate!.month}/${certificate.issueDate!.year}'),
          if (!isCompleted) ...[
            _DetailRow(
                label: l10n.inProgress,
                value: '${(certificate.progress * 100).round()}%'),
            _DetailRow(
                label: l10n.lessons,
                value:
                    '${certificate.completedLessons}/${certificate.totalLessons}'),
          ],
          AppSpacing.vGap24,
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isCompleted ? l10n.viewCertificate : l10n.continueLearning),
            ),
          ),
          AppSpacing.vGap8,
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ),
          AppSpacing.vGap8,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          Text(value, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
