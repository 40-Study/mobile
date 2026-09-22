import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/certificate_model.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

import 'certificate_header.dart';

class CertificatePreview extends StatelessWidget {
  const CertificatePreview({super.key, required this.certificate});

  final CertificateModel certificate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => _showFullScreen(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: cs.primary.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _CertificatePatternPainter(color: cs.primary),
              ),
            ),
            // Content
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48),
                    Flexible(
                      child: Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('C E R T I F I C A T E',
                                style: tt.titleMedium?.copyWith(
                                    color: cs.primary,
                                    letterSpacing: 4,
                                    fontWeight: FontWeight.w600)),
                          ),
                          AppSpacing.vGap4,
                          Text('OF COMPLETION',
                              style: tt.labelSmall?.copyWith(
                                  color: cs.primary.withValues(alpha: 0.7),
                                  letterSpacing: 2)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      height: 56,
                      child: CustomPaint(
                        painter: HexagonBadgePainter(color: cs.primary),
                        child: const Center(
                          child: Icon(Icons.star_rounded,
                              size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGap24,
                Text('This is to certify that',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                AppSpacing.vGap8,
                Text(certificate.userName ?? 'Student',
                    style:
                        tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                AppSpacing.vGap8,
                Text('has successfully completed the course',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                AppSpacing.vGap12,
                Text(certificate.courseTitle ?? '',
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center),
                AppSpacing.vGap24,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Completed on',
                            style: tt.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                        Text(_formatDate(certificate.issueDate),
                            style:
                                tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(certificate.instructorName ?? '',
                              style: tt.titleSmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis),
                          Text('Course Instructor',
                              style: tt.labelSmall
                                  ?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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

  void _showFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenCertificate(certificate: certificate),
      ),
    );
  }
}

class _CertificatePatternPainter extends CustomPainter {
  _CertificatePatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.03)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    canvas.drawRect(rect, paint);

    final innerRect = Rect.fromLTWH(16, 16, size.width - 32, size.height - 32);
    canvas.drawRect(innerRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FullScreenCertificate extends StatelessWidget {
  const FullScreenCertificate({super.key, required this.certificate});

  final CertificateModel certificate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(AppLocalizations.of(context)!.certificate),
      ),
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 3.0,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: CertificatePreview(certificate: certificate),
          ),
        ),
      ),
    );
  }
}
