import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_bloc.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_event.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_state.dart';
import 'package:study/theme/theme.dart';

import 'bookmark_empty_view.dart';
import 'bookmark_error_view.dart';
import 'bookmark_filter_chips.dart';
import 'bookmark_item.dart';

class BookmarkView extends StatelessWidget {
  const BookmarkView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Đã lưu'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const BookmarkFilterChips(),
          Expanded(
            child: BlocBuilder<BookmarkBloc, BookmarkState>(
              builder: (context, state) {
                if (state is BookmarkInProgress) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  );
                }

                if (state is BookmarkFailure) {
                  return BookmarkErrorView(
                    message: state.message,
                    onRetry: () => context
                        .read<BookmarkBloc>()
                        .add(const BookmarkStarted()),
                  );
                }

                if (state is BookmarkSuccess) {
                  final items = state.filteredBookmarks;
                  if (items.isEmpty) {
                    return BookmarkEmptyView(hasFilter: state.filter != null);
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
                        child: BookmarkItem(bookmark: items[index]),
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
