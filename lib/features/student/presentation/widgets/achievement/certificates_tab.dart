import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/mock/mock_achievement_data.dart';
import 'package:study/features/student/presentation/screens/certificate_detail_screen.dart';
import 'package:study/theme/app_colors.dart';

class CertificatesTab extends StatelessWidget {
  const CertificatesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppLayout.screenMargin,
        AppSpacing.lg,
        AppLayout.screenMargin,
        AppSpacing.massive,
      ),
      children: [
        Container(
          padding: AppLayout.cardPaddingCompact,
          decoration: BoxDecoration(
            color: cs.surfaceTintedPrimary,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: cs.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.workspace_premium_rounded,
                  size: AppIconSize.lg, color: cs.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Ban da dat ${mockCerts.length} chung chi',
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...mockCerts.map((cert) => Padding(
              padding:
                  const EdgeInsets.only(bottom: AppSpacing.md),
              child: CertificateCard(cert: cert),
            )),
      ],
    );
  }
}

class CertificateCard extends StatelessWidget {
  const CertificateCard({super.key, required this.cert});
  final CertItem cert;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.inversePrimary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.borderMd,
                ),
                child: Icon(Icons.verified_rounded,
                    size: AppIconSize.lg, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cert.title,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      cert.issuer,
                      style: tt.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: cs.outline, height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: AppIconSize.xs,
                  color: cs.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xs),
              Text(
                cert.date,
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Icon(Icons.tag_rounded,
                  size: AppIconSize.xs,
                  color: cs.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  cert.credential,
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (cert.verified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: AppIconSize.xs,
                          color: cs.secondary),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        'Verified',
                        style: tt.labelSmall?.copyWith(
                          color: cs.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            CertificateDetailScreen(
                          title: cert.title,
                          issuer: cert.issuer,
                          date: cert.date,
                          credential: cert.credential,
                          verified: cert.verified,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.surfaceTintedPrimary,
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(Icons.visibility_outlined,
                            size: AppIconSize.sm,
                            color: cs.primary),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Xem',
                          style: tt.labelMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_rounded,
                            size: AppIconSize.sm,
                            color: cs.onPrimary),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Tai ve',
                          style: tt.labelMedium?.copyWith(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
