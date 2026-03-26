import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/app_colors.dart';

class CourseDocumentsTab extends StatelessWidget {
  const CourseDocumentsTab({super.key, required this.detail});
  final CourseDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
            Icon(Icons.folder_copy_rounded,
                size: AppIconSize.md, color: cs.onSurface),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Kho tai lieu hoc tap',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: cs.surfaceTintedPrimary,
                borderRadius: AppRadius.borderXxl,
              ),
              child: Text(
                '${detail.documents.length} Tai lieu',
                style: tt.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xl),

        ...detail.documents.map(
          (doc) => DocumentTile(document: doc),
        ),

        SizedBox(height: AppSpacing.xl),
        Text(
          'Tat ca tai lieu duoc cung cap doc quyen cho hoc vien '
          'cua khoa hoc.\nVui long khong chia se ra ben ngoai '
          'khi chua co su dong y.',
          style: tt.bodySmall?.copyWith(
            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class DocumentTile extends StatelessWidget {
  const DocumentTile({super.key, required this.document});
  final DocumentModel document;

  IconData _iconForType(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return Icons.picture_as_pdf_rounded;
      case DocumentType.pptx:
        return Icons.slideshow_rounded;
      case DocumentType.video:
        return Icons.play_circle_rounded;
      case DocumentType.zip:
        return Icons.folder_zip_rounded;
      case DocumentType.epub:
        return Icons.menu_book_rounded;
    }
  }

  Color _colorForType(ColorScheme cs, DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return cs.error;
      case DocumentType.pptx:
        return cs.secondary;
      case DocumentType.video:
        return cs.primary;
      case DocumentType.zip:
        return cs.tertiary;
      case DocumentType.epub:
        return cs.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final iconColor = _colorForType(cs, document.type);

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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: AppRadius.borderSm,
              ),
              child: Icon(
                _iconForType(document.type),
                color: iconColor,
                size: AppIconSize.lg,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          document.title,
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (document.isGift) ...[
                        SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs + 2,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: AppRadius.borderXs,
                          ),
                          child: Text(
                            'Moi',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    [
                      document.type.name.toUpperCase(),
                      if (document.size != null) document.size,
                      if (document.updatedAt != null)
                        'Cap nhat: ${document.updatedAt}',
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.surfaceTintedPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.download_rounded,
                size: AppIconSize.md,
                color: cs.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
