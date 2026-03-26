import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/mock/mock_certificate_data.dart';
import 'package:study/theme/app_colors.dart';

class CertificateDetailScreen extends StatelessWidget {
  const CertificateDetailScreen({
    super.key,
    required this.title,
    required this.issuer,
    required this.date,
    required this.credential,
    this.verified = true,
  });

  final String title;
  final String issuer;
  final String date;
  final String credential;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chi tiet chung chi',
          style: tt.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined,
                color: cs.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppLayout.screenMargin,
          AppSpacing.lg,
          AppLayout.screenMargin,
          AppSpacing.massive,
        ),
        children: [
          _CertificateVisual(
            title: title,
            issuer: issuer,
            date: date,
            cs: cs,
            tt: tt,
          ),
          const SizedBox(height: AppSpacing.xxl),
          _VerificationStatus(
            verified: verified,
            issuer: issuer,
            cs: cs,
            tt: tt,
          ),
          const SizedBox(height: AppSpacing.xxl),
          _DetailSection(
            title: 'Thong tin chung chi',
            children: [
              _DetailRow(
                icon: Icons.school_rounded,
                label: 'Khoa hoc',
                value: title,
              ),
              _DetailRow(
                icon: Icons.business_rounded,
                label: 'Don vi cap',
                value: issuer,
              ),
              _DetailRow(
                icon: Icons.calendar_today_rounded,
                label: 'Ngay cap',
                value: date,
              ),
              _DetailRow(
                icon: Icons.tag_rounded,
                label: 'Ma chung chi',
                value: credential,
                mono: true,
              ),
              _DetailRow(
                icon: Icons.timer_rounded,
                label: 'Thoi gian hoc',
                value: '24 gio',
              ),
              _DetailRow(
                icon:
                    Icons.assignment_turned_in_rounded,
                label: 'Diem so',
                value: '92/100 (Xuat sac)',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _SkillsSection(cs: cs, tt: tt),
          const SizedBox(height: AppSpacing.xxxl),
          _ActionButtons(cs: cs, tt: tt),
        ],
      ),
    );
  }
}

class _CertificateVisual extends StatelessWidget {
  const _CertificateVisual({
    required this.title,
    required this.issuer,
    required this.date,
    required this.cs,
    required this.tt,
  });
  final String title;
  final String issuer;
  final String date;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: cs.gradientPrimary,
        borderRadius: AppRadius.borderXl,
        boxShadow: cs.shadowPrimary,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                Colors.white.withValues(alpha: 0.25),
            width: 2,
          ),
          borderRadius: AppRadius.borderLg,
        ),
        child: Column(
          children: [
            Icon(Icons.workspace_premium_rounded,
                size: 56,
                color: Colors.white
                    .withValues(alpha: 0.9)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'CERTIFICATE OF COMPLETION',
              style: tt.labelSmall?.copyWith(
                color: Colors.white
                    .withValues(alpha: 0.7),
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: tt.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: 60,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white
                    .withValues(alpha: 0.3),
                borderRadius: AppRadius.borderXs,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Trao cho',
              style: tt.labelSmall?.copyWith(
                color: Colors.white
                    .withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tran Minh Quan',
              style: tt.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(issuer,
                    style: tt.labelSmall?.copyWith(
                      color: Colors.white
                          .withValues(alpha: 0.6),
                    )),
                const SizedBox(width: AppSpacing.sm),
                Text('•',
                    style: tt.labelSmall?.copyWith(
                      color: Colors.white
                          .withValues(alpha: 0.4),
                    )),
                const SizedBox(width: AppSpacing.sm),
                Text(date,
                    style: tt.labelSmall?.copyWith(
                      color: Colors.white
                          .withValues(alpha: 0.6),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationStatus extends StatelessWidget {
  const _VerificationStatus({
    required this.verified,
    required this.issuer,
    required this.cs,
    required this.tt,
  });
  final bool verified;
  final String issuer;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppLayout.cardPadding,
      decoration: BoxDecoration(
        color: verified
            ? cs.secondaryContainer
            : cs.surfaceContainerLow,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: verified
              ? cs.secondary.withValues(alpha: 0.3)
              : cs.outline,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: verified
                  ? cs.secondary
                      .withValues(alpha: 0.15)
                  : cs.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              verified
                  ? Icons.verified_rounded
                  : Icons.help_outline_rounded,
              size: AppIconSize.lg,
              color: verified
                  ? cs.secondary
                  : cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  verified
                      ? 'Chung chi da xac minh'
                      : 'Chua xac minh',
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: verified
                        ? cs.secondary
                        : cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(
                    height: AppSpacing.xxs),
                Text(
                  verified
                      ? 'Chung chi nay da duoc '
                          '$issuer xac nhan '
                          'la hop le.'
                      : 'Chung chi nay dang cho '
                          'xac minh tu $issuer.',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
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

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.children,
  });
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: AppLayout.cardPadding,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: cs.outline),
        boxShadow: cs.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: AppRadius.borderXs,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(title,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  )),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.mono = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding:
          const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: AppIconSize.sm,
              color: cs.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 80,
            child: Text(label,
                style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(value,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                  fontFamily:
                      mono ? 'monospace' : null,
                )),
          ),
        ],
      ),
    );
  }
}

class _SkillsSection extends StatelessWidget {
  const _SkillsSection({
    required this.cs,
    required this.tt,
  });
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      title: 'Ky nang dat duoc',
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children:
              mockCertificateSkills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: cs.surfaceTintedPrimary,
                borderRadius: AppRadius.borderXxl,
                border: Border.all(
                  color: cs.primary
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: AppIconSize.xs,
                      color: cs.primary),
                  const SizedBox(
                      width: AppSpacing.xs),
                  Text(skill,
                      style: tt.labelMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.cs,
    required this.tt,
  });
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: AppRadius.borderLg,
                    border:
                        Border.all(color: cs.outline),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(Icons.link_rounded,
                          size: AppIconSize.md,
                          color: cs.primary),
                      const SizedBox(
                          width: AppSpacing.sm),
                      Text('Sao chep link',
                          style:
                              tt.labelLarge?.copyWith(
                            color: cs.primary,
                            fontWeight:
                                FontWeight.w700,
                          )),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: cs.gradientPrimary,
                    borderRadius: AppRadius.borderLg,
                    boxShadow: cs.shadowPrimary,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_rounded,
                          size: AppIconSize.md,
                          color: cs.onPrimary),
                      const SizedBox(
                          width: AppSpacing.sm),
                      Text('Tai ve PDF',
                          style:
                              tt.labelLarge?.copyWith(
                            color: cs.onPrimary,
                            fontWeight:
                                FontWeight.w700,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xff0a66c2),
              borderRadius: AppRadius.borderLg,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff0a66c2)
                      .withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_link_rounded,
                    size: 20, color: Colors.white),
                const SizedBox(width: AppSpacing.sm),
                Text('Them vao LinkedIn',
                    style: tt.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
