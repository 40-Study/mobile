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
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.6),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(Icons.folder_zip_outlined, color: cs.blue600, size: 24),
                ),
                AppSpacing.hGap16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tải tất cả tài liệu',
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.slate900,
                        ),
                      ),
                      Text(
                        '4 tệp • 12.5 MB',
                        style: tt.bodySmall?.copyWith(color: cs.slate500),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Tải về'),
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.blue600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGap24,

          const DocumentSection(
            icon: Icons.slideshow_outlined,
            title: 'Slide bài giảng',
            children: [
              DocumentCard(
                icon: Icons.picture_as_pdf_rounded,
                iconColor: Colors.red,
                title: 'Slide - Giới thiệu Python',
                subtitle: 'PDF • 2.3 MB • 15 trang',
                isDownloaded: true,
              ),
              DocumentCard(
                icon: Icons.picture_as_pdf_rounded,
                iconColor: Colors.red,
                title: 'Slide - Cài đặt môi trường',
                subtitle: 'PDF • 1.8 MB • 12 trang',
              ),
            ],
          ),
          AppSpacing.vGap24,

          DocumentSection(
            icon: Icons.code_rounded,
            title: 'Mã nguồn mẫu',
            children: [
              DocumentCard(
                icon: Icons.folder_zip_outlined,
                iconColor: Colors.amber.shade700,
                title: 'source_code_lesson1.zip',
                subtitle: 'ZIP • 156 KB • 5 tệp',
              ),
            ],
          ),
          AppSpacing.vGap24,

          DocumentSection(
            icon: Icons.library_books_outlined,
            title: 'Tài liệu tham khảo',
            children: [
              const DocumentCard(
                icon: Icons.description_outlined,
                iconColor: Colors.blue,
                title: 'Python Cheat Sheet',
                subtitle: 'PDF • 890 KB • 4 trang',
              ),
              DocumentCard(
                icon: Icons.link_rounded,
                iconColor: cs.blue600,
                title: 'Python Official Documentation',
                subtitle: 'Liên kết • python.org',
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
