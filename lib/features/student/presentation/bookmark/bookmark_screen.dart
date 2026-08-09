import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_bloc.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_event.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/empty_state.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookmarkBloc()..add(const BookmarkStarted()),
      child: const _BookmarkView(),
    );
  }
}

class _BookmarkView extends StatelessWidget {
  const _BookmarkView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Da luu')),
      body: Column(
        children: [
          const _FilterChips(),
          Expanded(
            child: BlocBuilder<BookmarkBloc, BookmarkState>(
              builder: (context, state) {
                if (state is BookmarkInProgress) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is BookmarkFailure) {
                  return Center(child: Text(state.message));
                }

                if (state is BookmarkSuccess) {
                  final items = state.filteredBookmarks;
                  if (items.isEmpty) {
                    return const EmptyState(
                      icon: Icons.bookmark_outline,
                      title: 'Chua co muc nao',
                      message: 'Luu khoa hoc, bai hoc de xem lai sau',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => AppSpacing.vGap12,
                    itemBuilder: (context, index) =>
                        _BookmarkItem(bookmark: items[index]),
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

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<BookmarkBloc, BookmarkState>(
      builder: (context, state) {
        final currentFilter =
            state is BookmarkSuccess ? state.filter : null;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              _FilterChip(
                label: 'Tat ca',
                selected: currentFilter == null,
                onTap: () => context
                    .read<BookmarkBloc>()
                    .add(const BookmarkFilterChanged(null)),
              ),
              AppSpacing.hGap8,
              _FilterChip(
                label: 'Khoa hoc',
                selected: currentFilter == BookmarkType.course,
                onTap: () => context
                    .read<BookmarkBloc>()
                    .add(const BookmarkFilterChanged(BookmarkType.course)),
              ),
              AppSpacing.hGap8,
              _FilterChip(
                label: 'Bai hoc',
                selected: currentFilter == BookmarkType.lesson,
                onTap: () => context
                    .read<BookmarkBloc>()
                    .add(const BookmarkFilterChanged(BookmarkType.lesson)),
              ),
              AppSpacing.hGap8,
              _FilterChip(
                label: 'Tai lieu',
                selected: currentFilter == BookmarkType.document,
                onTap: () => context
                    .read<BookmarkBloc>()
                    .add(const BookmarkFilterChanged(BookmarkType.document)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: tt.labelMedium?.copyWith(
            color: selected ? cs.onPrimary : cs.onSurface,
            fontWeight: FontWeight.w500,
          ),
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

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getTypeColor(bookmark.type, cs).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTypeIcon(bookmark.type),
              color: _getTypeColor(bookmark.type, cs),
            ),
          ),
          AppSpacing.hGap12,
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
                if (bookmark.subtitle != null)
                  Text(
                    bookmark.subtitle!,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.bookmark, color: cs.primary),
            onPressed: () => context
                .read<BookmarkBloc>()
                .add(BookmarkRemoved(bookmark.id)),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(BookmarkType type) {
    switch (type) {
      case BookmarkType.course:
        return Icons.school_outlined;
      case BookmarkType.lesson:
        return Icons.play_circle_outline;
      case BookmarkType.document:
        return Icons.description_outlined;
    }
  }

  Color _getTypeColor(BookmarkType type, ColorScheme cs) {
    switch (type) {
      case BookmarkType.course:
        return cs.primary;
      case BookmarkType.lesson:
        return cs.secondary;
      case BookmarkType.document:
        return cs.tertiary;
    }
  }
}
