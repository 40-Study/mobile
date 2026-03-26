import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/presentation/widgets/empty_state_card.dart';
import 'package:study/features/student/presentation/widgets/material_tile.dart';
import 'package:study/theme/app_colors.dart';

class LessonMaterialsTab extends StatelessWidget {
  const LessonMaterialsTab({super.key, required this.detail});
  final LessonDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (detail.materials.isEmpty) {
      return EmptyStateCard(
        icon: Icons.description_outlined,
        message: 'Chua co tai lieu cho bai hoc nay',
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppLayout.screenMargin,
        AppSpacing.xxl,
        AppLayout.screenMargin,
        AppSpacing.massive,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Tai lieu bai hoc',
                style:
                    tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: AppRadius.borderXs,
              ),
              child: Text(
                '${detail.materials.length} Files',
                style: tt.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),

        ...detail.materials.map(
          (mat) => MaterialTile(material: mat),
        ),

        SizedBox(height: AppSpacing.xl),

        Container(
          padding: AppLayout.cardPadding,
          decoration: BoxDecoration(
            color: cs.surfaceTintedPrimary,
            borderRadius: AppRadius.borderMd,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded,
                  size: AppIconSize.md, color: cs.primary),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Luu y:',
                      style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Vui long giai nen Source Code bang WinRAR hoac '
                      '7-Zip phien ban moi nhat de tranh loi font chu.',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
