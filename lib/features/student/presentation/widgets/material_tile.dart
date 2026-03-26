import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/app_colors.dart';

class MaterialTile extends StatelessWidget {
  const MaterialTile({super.key, required this.material});
  final LessonMaterial material;

  IconData _icon(LessonMaterialType t) {
    switch (t) {
      case LessonMaterialType.pdf:
        return Icons.picture_as_pdf_rounded;
      case LessonMaterialType.zip:
        return Icons.folder_zip_rounded;
      case LessonMaterialType.image:
        return Icons.image_rounded;
      case LessonMaterialType.video:
        return Icons.play_circle_rounded;
      case LessonMaterialType.slide:
        return Icons.slideshow_rounded;
    }
  }

  Color _color(ColorScheme cs, LessonMaterialType t) {
    switch (t) {
      case LessonMaterialType.pdf:
        return cs.error;
      case LessonMaterialType.zip:
        return cs.secondary;
      case LessonMaterialType.image:
        return cs.tertiary;
      case LessonMaterialType.video:
        return cs.primary;
      case LessonMaterialType.slide:
        return cs.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final c = _color(cs, material.type);

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.12),
          ),
          boxShadow: cs.shadowCard,
        ),
        child: Row(
          children: [
            Container(
              width: AppIconSize.avatar + AppSpacing.xs,
              height: AppIconSize.avatar + AppSpacing.xs,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.1),
                borderRadius: AppRadius.borderSm,
              ),
              child: Icon(_icon(material.type),
                  color: c, size: AppIconSize.lg),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.title,
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    [
                      if (material.size != null) material.size,
                      if (material.description != null)
                        material.description,
                    ].join('  •  '),
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Container(
              width: AppIconSize.xxl,
              height: AppIconSize.xxl,
              decoration: BoxDecoration(
                color: cs.surfaceTintedPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.download_rounded,
                  size: AppIconSize.sm, color: cs.primary),
            ),
          ],
        ),
      ),
    );
  }
}
