import 'package:flutter/material.dart';
import 'package:study/features/student/presentation/learning/widgets/lesson_detail/document_widgets.dart';
import 'package:study/theme/theme.dart';

/// Documents tab hiển thị tài liệu bài học
class LessonDocumentsSection extends StatelessWidget {
  const LessonDocumentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Download all button
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(Icons.folder_zip_outlined, color: cs.primary, size: 24),
                ),
                AppSpacing.hGap16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tai tat ca tai lieu',
                          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      Text('4 tep • 12.5 MB',
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Tai ve'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGap24,

          const DocumentSection(
            icon: Icons.slideshow_outlined,
            title: 'Slide bai giang',
            children: [
              DocumentCard(
                icon: Icons.picture_as_pdf_rounded,
                iconColor: Colors.red,
                title: 'Slide - Gioi thieu Python',
                subtitle: 'PDF • 2.3 MB • 15 trang',
                isDownloaded: true,
              ),
              DocumentCard(
                icon: Icons.picture_as_pdf_rounded,
                iconColor: Colors.red,
                title: 'Slide - Cai dat moi truong',
                subtitle: 'PDF • 1.8 MB • 12 trang',
              ),
            ],
          ),
          AppSpacing.vGap24,

          DocumentSection(
            icon: Icons.code_rounded,
            title: 'Ma nguon mau',
            children: [
              DocumentCard(
                icon: Icons.folder_zip_outlined,
                iconColor: Colors.amber.shade700,
                title: 'source_code_lesson1.zip',
                subtitle: 'ZIP • 156 KB • 5 files',
              ),
            ],
          ),
          AppSpacing.vGap24,

          DocumentSection(
            icon: Icons.library_books_outlined,
            title: 'Tai lieu tham khao',
            children: [
              const DocumentCard(
                icon: Icons.description_outlined,
                iconColor: Colors.blue,
                title: 'Python Cheat Sheet',
                subtitle: 'PDF • 890 KB • 4 trang',
              ),
              DocumentCard(
                icon: Icons.link_rounded,
                iconColor: cs.primary,
                title: 'Python Official Documentation',
                subtitle: 'Link • python.org',
                isLink: true,
              ),
            ],
          ),
          AppSpacing.vGap32,
        ],
      ),
    );
  }
}
