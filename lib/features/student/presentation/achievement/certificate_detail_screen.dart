import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/certificate_model.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class CertificateDetailScreen extends StatelessWidget {
  const CertificateDetailScreen({super.key, required this.certificate});

  final CertificateModel certificate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // Content
          SafeArea(
            child: Column(
              children: [
                _TopBar(onBack: () => Navigator.pop(context)),
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CertificateHeader(certificate: certificate),
                        AppSpacing.vGap24,
                        _CertificatePreview(certificate: certificate),
                        AppSpacing.vGap24,
                        const _CertificateActions(),
                        AppSpacing.vGap24,
                        _CourseInformation(certificate: certificate),
                        AppSpacing.vGap24,
                        const _SkillsSection(skills: [
                          'User Research',
                          'Wireframing',
                          'UI Design',
                          'Prototyping',
                          'Design System',
                        ]),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TOP BAR
// ============================================================
class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          _IconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
          const Spacer(),
          _IconButton(icon: Icons.ios_share_rounded, onTap: () {}),
          AppSpacing.hGap8,
          _IconButton(
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
            _MoreOption(
              icon: Icons.download_rounded,
              label: AppLocalizations.of(context)!.downloadPdf,
              onTap: () => Navigator.pop(context),
            ),
            _MoreOption(
              icon: Icons.link_rounded,
              label: AppLocalizations.of(context)!.copyLink,
              onTap: () => Navigator.pop(context),
            ),
            _MoreOption(
              icon: Icons.qr_code_rounded,
              label: AppLocalizations.of(context)!.showQrCode,
              onTap: () => Navigator.pop(context),
            ),
            _MoreOption(
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

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});

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

class _MoreOption extends StatelessWidget {
  const _MoreOption({
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

// ============================================================
// CERTIFICATE HEADER
// ============================================================
class _CertificateHeader extends StatelessWidget {
  const _CertificateHeader({required this.certificate});

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
        const _AchievementBadge(),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge();

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
            painter: _HexagonBadgePainter(color: cs.primary),
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

class _HexagonBadgePainter extends CustomPainter {
  _HexagonBadgePainter({required this.color});

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

// ============================================================
// CERTIFICATE PREVIEW
// ============================================================
class _CertificatePreview extends StatelessWidget {
  const _CertificatePreview({required this.certificate});

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
                    Column(
                      children: [
                        Text('C E R T I F I C A T E',
                            style: tt.titleMedium?.copyWith(
                                color: cs.primary,
                                letterSpacing: 4,
                                fontWeight: FontWeight.w600)),
                        AppSpacing.vGap4,
                        Text('OF COMPLETION',
                            style: tt.labelSmall?.copyWith(
                                color: cs.primary.withValues(alpha: 0.7),
                                letterSpacing: 2)),
                      ],
                    ),
                    SizedBox(
                      width: 48,
                      height: 56,
                      child: CustomPaint(
                        painter: _HexagonBadgePainter(color: cs.primary),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(certificate.instructorName ?? '',
                            style: tt.titleSmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500)),
                        Text('Course Instructor',
                            style: tt.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                      ],
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
        builder: (_) => _FullScreenCertificate(certificate: certificate),
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

// ============================================================
// FULL SCREEN CERTIFICATE
// ============================================================
class _FullScreenCertificate extends StatelessWidget {
  const _FullScreenCertificate({required this.certificate});

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
            child: _CertificatePreview(certificate: certificate),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CERTIFICATE ACTIONS
// ============================================================
class _CertificateActions extends StatelessWidget {
  const _CertificateActions();

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
                textAlign: TextAlign.center),
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

// ============================================================
// COURSE INFORMATION
// ============================================================
class _CourseInformation extends StatelessWidget {
  const _CourseInformation({required this.certificate});

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
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
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
          const Spacer(),
          if (isHighlighted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(value,
                  style: tt.labelMedium?.copyWith(
                      color: cs.primary, fontWeight: FontWeight.w600)),
            )
          else
            Flexible(
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

// ============================================================
// SKILLS SECTION
// ============================================================
class _SkillsSection extends StatelessWidget {
  const _SkillsSection({required this.skills});

  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (skills.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.skillsEarned,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          AppSpacing.vGap16,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((skill) => _SkillChip(skill: skill)).toList(),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.skill});

  final String skill;

  IconData _getIconForSkill(String skill) {
    final lower = skill.toLowerCase();
    if (lower.contains('research')) return Icons.search_rounded;
    if (lower.contains('wire')) return Icons.grid_on_rounded;
    if (lower.contains('ui') || lower.contains('design')) {
      return Icons.palette_rounded;
    }
    if (lower.contains('proto')) return Icons.play_circle_rounded;
    if (lower.contains('system')) return Icons.auto_awesome_mosaic_rounded;
    return Icons.check_circle_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: cs.primary.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIconForSkill(skill), size: 14, color: cs.primary),
          AppSpacing.hGap8,
          Text(skill,
              style: tt.labelMedium
                  ?.copyWith(color: cs.primary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
