import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study/theme/theme.dart';

class _NoteItem {
  final String id;
  final String timestamp;
  final String content;
  final DateTime createdAt;

  _NoteItem({
    required this.id,
    required this.timestamp,
    required this.content,
    required this.createdAt,
  });
}

/// Notes tab hiển thị khung soạn thảo nhanh tinh gọn và timeline ghi chú theo timestamp
class LessonNotesSection extends StatefulWidget {
  const LessonNotesSection({super.key});

  @override
  State<LessonNotesSection> createState() => _LessonNotesSectionState();
}

class _LessonNotesSectionState extends State<LessonNotesSection> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final String _currentTimestamp = '02:45';
  bool _attachTimestamp = true;

  final List<_NoteItem> _notes = [
    _NoteItem(
      id: 'note_1',
      timestamp: '01:15',
      content: 'Cần chú ý về cách khởi tạo State trong StatefulWidget và vòng đời initState().',
      createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
    ),
    _NoteItem(
      id: 'note_2',
      timestamp: '03:50',
      content: 'Nhớ dùng dispose() để giải phóng StreamController và AnimationController.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addNote() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _notes.insert(
        0,
        _NoteItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: _attachTimestamp ? _currentTimestamp : '--:--',
          content: text,
          createdAt: DateTime.now(),
        ),
      );
      _textController.clear();
      _focusNode.unfocus();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu ghi chú thành công!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteNote(String id) {
    setState(() {
      _notes.removeWhere((n) => n.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa ghi chú'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Sleek Integrated Note Composer (Compact & Refined)
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.6),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    minLines: 3,
                    maxLines: 6,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: 'Thêm ghi chú bài học tại thời điểm này...',
                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(color: cs.slate900, fontSize: 13.5, height: 1.45),
                  ),
                ),
                const Divider(height: 12, thickness: 0.6, color: Color(0xFFF1F5F9)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
                  child: Row(
                    children: [
                      // Video Timestamp Tag
                      InkWell(
                        onTap: () => setState(() => _attachTimestamp = !_attachTimestamp),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: _attachTimestamp
                                ? const Color(0xFF3D5FC4).withValues(alpha: 0.1)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                              color: _attachTimestamp
                                  ? const Color(0xFF3D5FC4).withValues(alpha: 0.3)
                                  : const Color(0xFFE2E8F0),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 13,
                                color: _attachTimestamp ? const Color(0xFF3D5FC4) : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _attachTimestamp ? 'Tại $_currentTimestamp' : 'Không gắn giờ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _attachTimestamp ? const Color(0xFF3D5FC4) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Compact Save Pill Button
                      FilledButton.icon(
                        onPressed: _addNote,
                        icon: const Icon(Icons.bookmark_add_rounded, size: 14),
                        label: const Text('Lưu ghi chú'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF3D5FC4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 2. Saved Notes Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ghi chú của bạn (${_notes.length})',
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.slate900,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_done_rounded, size: 12, color: Color(0xFF059669)),
                    SizedBox(width: 4),
                    Text(
                      'Đồng bộ đám mây',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 3. Notes list or empty state
          if (_notes.isEmpty)
            _buildEmptyState(context)
          else
            ..._notes.map((note) => _buildNoteCard(context, note)),

          // Bottom padding to avoid LessonBottomBar overlay
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, _NoteItem note) {
    final cs = Theme.of(context).colorScheme;

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
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: clickable time pill + relative time + actions
            Row(
              children: [
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đang tua video đến mốc ${note.timestamp}...'),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D5FC4).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow_rounded, size: 14, color: Color(0xFF3D5FC4)),
                        const SizedBox(width: 2),
                        Text(
                          note.timestamp,
                          style: const TextStyle(
                            color: Color(0xFF3D5FC4),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatRelativeTime(note.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
                const Spacer(),

                // Copy note button
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: note.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã sao chép ghi chú vào bộ nhớ tạm'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 15),
                  color: const Color(0xFF94A3B8),
                  tooltip: 'Sao chép ghi chú',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
                const SizedBox(width: 4),

                // Delete button
                IconButton(
                  onPressed: () => _deleteNote(note.id),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  color: const Color(0xFF94A3B8),
                  tooltip: 'Xóa ghi chú',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Note Content
            Text(
              note.content,
              style: TextStyle(
                color: cs.slate900,
                fontSize: 13.5,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, size: 44, color: cs.slate400),
          AppSpacing.vGap12,
          Text(
            'Chưa có ghi chú nào',
            style: tt.titleSmall?.copyWith(
              color: cs.slate800,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hãy ghi lại những kiến thức quan trọng khi đang xem video nhé!',
            style: TextStyle(color: cs.slate500, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
