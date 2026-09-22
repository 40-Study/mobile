import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_bloc.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_event.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/theme.dart';

class BookmarkItem extends StatelessWidget {
  const BookmarkItem({super.key, required this.bookmark});

  final BookmarkModel bookmark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final typeColor = _getTypeColor(bookmark.type, cs);

    return Dismissible(
      key: Key(bookmark.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: cs.error,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Icon(Icons.delete_outline, color: cs.onError),
      ),
      onDismissed: (_) {
        context.read<BookmarkBloc>().add(BookmarkRemoved(bookmark.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã xóa khỏi danh sách lưu'),
            action: SnackBarAction(
              label: 'Hoàn tác',
              onPressed: () {
                // TODO: Undo delete
              },
            ),
          ),
        );
      },
      child: Material(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: () {
            // TODO: Navigate to bookmark target
          },
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    _getTypeIcon(bookmark.type),
                    color: typeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookmark.title,
                        style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getTypeLabel(bookmark.type),
                              style: tt.labelSmall?.copyWith(
                                color: typeColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (bookmark.subtitle != null) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                bookmark.subtitle!,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.bookmark_rounded, color: cs.primary),
                  onPressed: () {
                    context.read<BookmarkBloc>().add(BookmarkRemoved(bookmark.id));
                  },
                  tooltip: 'Bỏ lưu',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(BookmarkType type) {
    return switch (type) {
      BookmarkType.course => Icons.school_rounded,
      BookmarkType.lesson => Icons.play_circle_rounded,
      BookmarkType.document => Icons.description_rounded,
    };
  }

  Color _getTypeColor(BookmarkType type, ColorScheme cs) {
    return switch (type) {
      BookmarkType.course => cs.primary,
      BookmarkType.lesson => cs.secondary,
      BookmarkType.document => cs.tertiary,
    };
  }

  String _getTypeLabel(BookmarkType type) {
    return switch (type) {
      BookmarkType.course => 'Khóa học',
      BookmarkType.lesson => 'Bài học',
      BookmarkType.document => 'Tài liệu',
    };
  }
}
