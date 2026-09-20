import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/data/bookmark_storage.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_bloc.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_event.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/theme.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookmarkBloc(diContainer<BookmarkStorage>())
        ..add(const BookmarkStarted()),
      child: const _BookmarkView(),
    );
  }
}

class _BookmarkView extends StatelessWidget {
  const _BookmarkView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Đã lưu'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const _FilterChips(),
          Expanded(
            child: BlocBuilder<BookmarkBloc, BookmarkState>(
              builder: (context, state) {
                if (state is BookmarkInProgress) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  );
                }

                if (state is BookmarkFailure) {
                  return _ErrorView(
                    message: state.message,
                    onRetry: () => context
                        .read<BookmarkBloc>()
                        .add(const BookmarkStarted()),
                  );
                }

                if (state is BookmarkSuccess) {
                  final items = state.filteredBookmarks;
                  if (items.isEmpty) {
                    return _EmptyView(hasFilter: state.filter != null);
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<BookmarkBloc>().add(const BookmarkStarted());
                      await Future<void>.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        AppSpacing.sm,
                        AppSpacing.screenPadding,
                        32,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _BookmarkItem(bookmark: items[index]),
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({this.hasFilter = false});

  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_outline_rounded,
                size: 40,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasFilter ? 'Không có mục nào' : 'Chưa có mục đã lưu',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Không có mục nào trong bộ lọc này'
                  : 'Lưu khóa học, bài học để xem lại sau',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cs.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sync_problem, color: cs.onErrorContainer),
            ),
            const SizedBox(height: 16),
            Text(
              'Không thể tải dữ liệu',
              style: tt.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<BookmarkBloc, BookmarkState>(
      builder: (context, state) {
        final currentFilter = state is BookmarkSuccess ? state.filter : null;

        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                _buildChip(
                  context,
                  label: 'Tất cả',
                  icon: Icons.folder_outlined,
                  selected: currentFilter == null,
                  onTap: () => context
                      .read<BookmarkBloc>()
                      .add(const BookmarkFilterChanged(null)),
                ),
                const SizedBox(width: 8),
                _buildChip(
                  context,
                  label: 'Khóa học',
                  icon: Icons.school_outlined,
                  selected: currentFilter == BookmarkType.course,
                  onTap: () => context
                      .read<BookmarkBloc>()
                      .add(const BookmarkFilterChanged(BookmarkType.course)),
                ),
                const SizedBox(width: 8),
                _buildChip(
                  context,
                  label: 'Bài học',
                  icon: Icons.play_circle_outline,
                  selected: currentFilter == BookmarkType.lesson,
                  onTap: () => context
                      .read<BookmarkBloc>()
                      .add(const BookmarkFilterChanged(BookmarkType.lesson)),
                ),
                const SizedBox(width: 8),
                _buildChip(
                  context,
                  label: 'Tài liệu',
                  icon: Icons.description_outlined,
                  selected: currentFilter == BookmarkType.document,
                  onTap: () => context
                      .read<BookmarkBloc>()
                      .add(const BookmarkFilterChanged(BookmarkType.document)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? cs.onPrimary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: tt.labelMedium?.copyWith(
                color: selected ? cs.onPrimary : cs.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkItem extends StatelessWidget {
  const _BookmarkItem({required this.bookmark});

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
