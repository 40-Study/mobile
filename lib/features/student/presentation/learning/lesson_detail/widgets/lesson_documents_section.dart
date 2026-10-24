import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Documents tab hiển thị tài liệu bài học với giao diện hiện đại, tinh tế
class LessonDocumentsSection extends StatefulWidget {
  const LessonDocumentsSection({super.key});

  @override
  State<LessonDocumentsSection> createState() => _LessonDocumentsSectionState();
}

class _LessonDocumentsSectionState extends State<LessonDocumentsSection> {
  int _selectedFilterIndex = 0; // 0: Tất cả, 1: Slide, 2: Code, 3: Tham khảo
  final Set<String> _downloadedFileIds = {'doc_1'};
  bool _isDownloadingAll = false;

  final List<Map<String, dynamic>> _documents = [
    {
      'id': 'doc_1',
      'category': 'slide',
      'format': 'PDF',
      'title': 'Slide - Giới thiệu Kiến trúc & Công nghệ',
      'size': '2.3 MB',
      'meta': '18 trang',
      'icon': Icons.picture_as_pdf_rounded,
      'color': Color(0xFFEF4444),
      'isLink': false,
    },
    {
      'id': 'doc_2',
      'category': 'slide',
      'format': 'PDF',
      'title': 'Slide - Thiết lập môi trường & Dự án thực hành',
      'size': '1.8 MB',
      'meta': '14 trang',
      'icon': Icons.picture_as_pdf_rounded,
      'color': Color(0xFFEF4444),
      'isLink': false,
    },
    {
      'id': 'doc_3',
      'category': 'code',
      'format': 'ZIP',
      'title': 'starter_template_project.zip',
      'size': '256 KB',
      'meta': '12 tệp mã nguồn',
      'icon': Icons.folder_zip_rounded,
      'color': Color(0xFFF59E0B),
      'isLink': false,
    },
    {
      'id': 'doc_4',
      'category': 'ref',
      'format': 'WEB',
      'title': 'Official Cheat Sheet & Best Practices',
      'size': 'Tài liệu ngoài',
      'meta': 'python.org',
      'icon': Icons.language_rounded,
      'color': Color(0xFF3D5FC4),
      'isLink': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final filteredDocs = _documents.where((doc) {
      if (_selectedFilterIndex == 1) return doc['category'] == 'slide';
      if (_selectedFilterIndex == 2) return doc['category'] == 'code';
      if (_selectedFilterIndex == 3) return doc['category'] == 'ref';
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Download all compact banner card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: const Color(0xFFBFDBFE),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3D5FC4).withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.folder_zip_rounded, color: Color(0xFF3D5FC4), size: 22),
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tải tất cả tài liệu',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_documents.length} tệp • 14.8 MB tổng dung lượng',
                        style: const TextStyle(color: Color(0xFF475569), fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: _isDownloadingAll
                      ? null
                      : () {
                          setState(() => _isDownloadingAll = true);
                          Future.delayed(const Duration(milliseconds: 800), () {
                            if (mounted) {
                              setState(() {
                                _isDownloadingAll = false;
                                for (final d in _documents) {
                                  _downloadedFileIds.add(d['id'] as String);
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã tải xuống toàn bộ tài liệu bài học'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          });
                        },
                  icon: _isDownloadingAll
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3D5FC4)),
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 14),
                  label: Text(
                    _isDownloadingAll ? 'Đang tải...' : 'Tải về',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF3D5FC4).withValues(alpha: 0.12),
                    foregroundColor: const Color(0xFF3D5FC4),
                    disabledBackgroundColor: const Color(0xFF3D5FC4).withValues(alpha: 0.08),
                    disabledForegroundColor: const Color(0xFF3D5FC4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Filter Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tất cả (${_documents.length})', 0),
                const SizedBox(width: 8),
                _buildFilterChip('Slide bài giảng (2)', 1),
                const SizedBox(width: 8),
                _buildFilterChip('Mã nguồn (1)', 2),
                const SizedBox(width: 8),
                _buildFilterChip('Tham khảo (1)', 3),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Document Files List Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh sách tài liệu (${filteredDocs.length})',
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.slate900,
                  fontSize: 14,
                ),
              ),
              Text(
                'Chạm để xem hoặc tải',
                style: TextStyle(color: cs.slate500, fontSize: 11.5),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 4. Refined Document Cards
          ...filteredDocs.map((doc) => _buildDocumentCard(context, doc)),

          // Bottom padding to avoid LessonBottomBar overlay
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, Map<String, dynamic> doc) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final id = doc['id'] as String;
    final isDownloaded = _downloadedFileIds.contains(id);
    final isLink = doc['isLink'] as bool;
    final color = doc['color'] as Color;
    final format = doc['format'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đang mở ${doc['title']}...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                // Modern Document Icon Box with Format Tag
                Container(
                  width: 44,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withValues(alpha: 0.2), width: 0.8),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(doc['icon'] as IconData, color: color, size: 22),
                      Positioned(
                        bottom: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.5),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            format,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGap12,

                // Title and Meta Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc['title'] as String,
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.slate900,
                          fontSize: 13.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              doc['size'] as String,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '• ${doc['meta']}',
                            style: TextStyle(
                              fontSize: 11,
                              color: cs.slate500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGap8,

                // Right Action
                if (isDownloaded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF059669)),
                        SizedBox(width: 3),
                        Text(
                          'Đã tải',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isLink)
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đang mở ${doc['title']}...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 13),
                    label: const Text('Mở'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3D5FC4),
                      side: const BorderSide(color: Color(0xFF3D5FC4), width: 0.8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: const Size(0, 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                  )
                else
                  IconButton(
                    onPressed: () {
                      setState(() => _downloadedFileIds.add(id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã tải xong ${doc['title']}'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 17),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF3D5FC4).withValues(alpha: 0.08),
                      foregroundColor: const Color(0xFF3D5FC4),
                      minimumSize: const Size(34, 34),
                      padding: EdgeInsets.zero,
                    ),
                    tooltip: 'Tải tài liệu này',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedFilterIndex = index);
      },
      selectedColor: const Color(0xFF3D5FC4).withValues(alpha: 0.12),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF3D5FC4) : const Color(0xFF64748B),
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF3D5FC4) : const Color(0xFFCBD5E1),
        width: 0.8,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
      backgroundColor: Colors.transparent,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
