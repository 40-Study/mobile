import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_bloc.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_event.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/theme.dart';

class BookmarkFilterChips extends StatelessWidget {
  const BookmarkFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                _FilterChip(
                  label: 'Tất cả',
                  icon: Icons.folder_outlined,
                  selected: currentFilter == null,
                  onTap: () => context
                      .read<BookmarkBloc>()
                      .add(const BookmarkFilterChanged(null)),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Khóa học',
                  icon: Icons.school_outlined,
                  selected: currentFilter == BookmarkType.course,
                  onTap: () => context
                      .read<BookmarkBloc>()
                      .add(const BookmarkFilterChanged(BookmarkType.course)),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Bài học',
                  icon: Icons.play_circle_outline,
                  selected: currentFilter == BookmarkType.lesson,
                  onTap: () => context
                      .read<BookmarkBloc>()
                      .add(const BookmarkFilterChanged(BookmarkType.lesson)),
                ),
                const SizedBox(width: 8),
                _FilterChip(
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
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
