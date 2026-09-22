import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/certificate_model.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class CourseInformation extends StatelessWidget {
  const CourseInformation({super.key, required this.certificate});

  final CertificateModel certificate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Builder(builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.courseInfo,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            AppSpacing.vGap16,
            _InfoRow(
              icon: Icons.menu_book_rounded,
              label: l10n.course,
              value: certificate.courseTitle ?? '',
            ),
            const _InfoDivider(),
            _InfoRow(
              icon: Icons.calendar_today_rounded,
              label: l10n.completionDate,
              value: _formatDate(certificate.issueDate),
            ),
            const _InfoDivider(),
            _InfoRow(
              icon: Icons.access_time_rounded,
              label: l10n.duration,
              value: '42h 30m',
            ),
            const _InfoDivider(),
            _InfoRow(
              icon: Icons.person_rounded,
              label: l10n.instructor,
              value: certificate.instructorName ?? '',
            ),
            const _InfoDivider(),
            _InfoRow(
              icon: Icons.bar_chart_rounded,
              label: l10n.level,
              value: l10n.basic,
              isHighlighted: true,
            ),
          ],
        );
      }),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          AppSpacing.hGap12,
          Text(label,
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          AppSpacing.hGap12,
          if (isHighlighted)
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(value,
                      style: tt.labelMedium?.copyWith(
                          color: cs.primary, fontWeight: FontWeight.w600)),
                ),
              ),
            )
          else
            Expanded(
              child: Text(value,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
    );
  }
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Divider(
        height: 1, thickness: 1, color: cs.outlineVariant.withValues(alpha: 0.3));
  }
}
