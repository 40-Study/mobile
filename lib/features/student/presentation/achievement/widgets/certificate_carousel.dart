import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/certificate_model.dart';
import 'package:study/features/student/presentation/achievement/all_certificates_screen.dart';
import 'package:study/features/student/presentation/achievement/certificate_detail_screen.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class CertificateCarousel extends StatefulWidget {
  const CertificateCarousel({super.key, required this.certificates});

  final List<CertificateModel> certificates;

  @override
  State<CertificateCarousel> createState() => _CertificateCarouselState();
}

class _CertificateCarouselState extends State<CertificateCarousel> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Row(
          children: [
            Text(l10n.yourCertificates,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        AllCertificatesScreen(certificates: widget.certificates)),
              ),
              child: Text(l10n.viewAll,
                  style: tt.labelLarge
                      ?.copyWith(color: cs.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        AppSpacing.vGap16,
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: widget.certificates.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CertificateCard(
                certificate: widget.certificates[i],
                colorIndex: i,
              ),
            ),
          ),
        ),
        AppSpacing.vGap12,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.certificates.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: i == _currentPage ? 8 : 6,
              height: i == _currentPage ? 8 : 6,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == _currentPage ? cs.primary : cs.outlineVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CertificateCard extends StatelessWidget {
  const CertificateCard({
    super.key,
    required this.certificate,
    required this.colorIndex,
  });

  final CertificateModel certificate;
  final int colorIndex;

  static const _accentColors = [
    AchievementColors.purple,
    AchievementColors.teal,
    AchievementColors.blue,
    AchievementColors.deepOrange,
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accent = _accentColors[colorIndex % _accentColors.length];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CertificateDetailScreen(certificate: certificate),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CERTIFICATE',
                        style: tt.labelMedium?.copyWith(
                            color: accent,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700)),
                    Text('OF COMPLETION',
                        style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant, letterSpacing: 0.5)),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.workspace_premium_rounded,
                      color: Colors.white, size: 22),
                ),
              ],
            ),
            AppSpacing.vGap12,
            Text(certificate.courseTitle ?? '',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const Spacer(),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Completed on',
                        style: tt.labelSmall?.copyWith(color: cs.outline)),
                    Text(_formatDate(certificate.issueDate),
                        style:
                            tt.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const Spacer(),
                Text(certificate.instructorName ?? '',
                    style: tt.labelMedium?.copyWith(
                        fontStyle: FontStyle.italic, color: cs.onSurfaceVariant)),
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
}
