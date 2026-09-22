import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/certificate_model.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class CertificateHeader extends StatelessWidget {
  const CertificateHeader({super.key, required this.certificate});

  final CertificateModel certificate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.workspace_premium_rounded,
                      size: 18, color: cs.primary),
                  AppSpacing.hGap4,
                  Text(AppLocalizations.of(context)!.certificate,
                      style: tt.labelLarge?.copyWith(
                          color: cs.primary, fontWeight: FontWeight.w600)),
                ],
              ),
              AppSpacing.vGap8,
              Text(certificate.courseTitle ?? '',
                  style:
                      tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
              AppSpacing.vGap12,
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 16, color: cs.primary),
                    AppSpacing.hGap4,
                    Text(AppLocalizations.of(context)!.completed,
                        style: tt.labelMedium?.copyWith(
                            color: cs.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              AppSpacing.vGap12,
              Text(
                AppLocalizations.of(context)!.certificateConfirm,
                style: tt.bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
              ),
            ],
          ),
        ),
        AppSpacing.hGap16,
        const CertificateAchievementBadge(),
      ],
    );
  }
}

class CertificateAchievementBadge extends StatelessWidget {
  const CertificateAchievementBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: 100,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sparkles
          Positioned(
            top: 0,
            right: 0,
            child: Icon(Icons.auto_awesome,
                size: 14, color: cs.primary.withValues(alpha: 0.6)),
          ),
          Positioned(
            top: 20,
            left: 5,
            child: Icon(Icons.auto_awesome,
                size: 10, color: cs.primary.withValues(alpha: 0.4)),
          ),
          Positioned(
            bottom: 20,
            right: 5,
            child: Icon(Icons.add,
                size: 12, color: cs.primary.withValues(alpha: 0.5)),
          ),
          // Badge
          CustomPaint(
            size: const Size(72, 84),
            painter: HexagonBadgePainter(color: cs.primary),
            child: const SizedBox(
              width: 72,
              height: 84,
              child:
                  Center(child: Icon(Icons.star_rounded, size: 32, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class HexagonBadgePainter extends CustomPainter {
  HexagonBadgePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createHexagonPath(size);

    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(path, glowPaint);

    // Fill
    final fillPaint = Paint()..color = color;
    canvas.drawPath(path, fillPaint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);
  }

  Path _createHexagonPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.25)
      ..lineTo(w, h * 0.75)
      ..lineTo(w * 0.5, h)
      ..lineTo(0, h * 0.75)
      ..lineTo(0, h * 0.25)
      ..close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
