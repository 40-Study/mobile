import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

import '../all_certificates_screen.dart';

/// Card item cho danh sách certificate
class CertificateListCard extends StatelessWidget {
  const CertificateListCard({super.key, required this.certificate, required this.onTap});

  final CertificateData certificate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isCompleted = certificate.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: certificate.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                isCompleted
                    ? Icons.workspace_premium_rounded
                    : Icons.school_rounded,
                color: certificate.color,
                size: 28,
              ),
            ),
            AppSpacing.hGap16,
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCompleted)
                    Row(
                      children: [
                        Text(AppLocalizations.of(context)!.certificate.toUpperCase(),
                            style: tt.labelSmall?.copyWith(
                                color: certificate.color,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Icon(Icons.verified_rounded,
                            size: 16, color: certificate.color),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Text(AppLocalizations.of(context)!.studying.toUpperCase(),
                            style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text('${(certificate.progress * 100).round()}%',
                            style: tt.labelMedium?.copyWith(
                                color: certificate.color,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  AppSpacing.vGap4,
                  Text(certificate.courseTitle,
                      style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  AppSpacing.vGap4,
                  Text(certificate.instructorName,
                      style:
                          tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  if (!isCompleted) ...[
                    AppSpacing.vGap8,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: certificate.progress,
                        minHeight: 4,
                        backgroundColor: cs.surfaceContainerHighest,
                        valueColor:
                            AlwaysStoppedAnimation(certificate.color),
                      ),
                    ),
                    AppSpacing.vGap4,
                    Text(
                        '${certificate.completedLessons}/${certificate.totalLessons} ${AppLocalizations.of(context)!.lessons}',
                        style: tt.labelSmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                  if (isCompleted && certificate.issueDate != null) ...[
                    AppSpacing.vGap4,
                    Text(_formatDate(certificate.issueDate!),
                        style:
                            tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ],
              ),
            ),
            AppSpacing.hGap8,
            Icon(Icons.chevron_right_rounded,
                size: 20, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
      'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
      'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    return '${d.day} ${months[d.month - 1]}, ${d.year}';
  }
}
