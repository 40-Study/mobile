import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/student/bloc/search/search_bloc.dart';
import 'package:study/features/student/bloc/search/search_event.dart';
import 'package:study/features/student/bloc/search/search_state.dart';
import 'package:study/features/student/repository/student_repository.dart';
import 'package:study/theme/theme.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchBloc(diContainer<StudentRepository>()),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            style: tt.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm khóa học, bài học...',
              hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant, size: 20),
              suffixIcon: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (_controller.text.isNotEmpty) {
                    return IconButton(
                      icon: Icon(Icons.close, color: cs.onSurfaceVariant, size: 20),
                      onPressed: () {
                        _controller.clear();
                        context.read<SearchBloc>().add(const SearchCleared());
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) =>
                context.read<SearchBloc>().add(SearchQueryChanged(value)),
          ),
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchInitial) {
            return _RecentSearches(
              searches: state.recentSearches,
              onTap: (query) {
                _controller.text = query;
                context.read<SearchBloc>().add(SearchQueryChanged(query));
              },
              onClear: () {
                // TODO: Clear recent searches
              },
            );
          }

          if (state is SearchInProgress) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            );
          }

          if (state is SearchEmpty) {
            return _EmptyResult(query: state.query);
          }

          if (state is SearchSuccess) {
            return Column(
              children: [
                _FilterTabs(currentFilter: state.filter),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${state.filteredResults.length} kết quả',
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.sm,
                      AppSpacing.screenPadding,
                      32,
                    ),
                    itemCount: state.filteredResults.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _SearchResultItem(result: state.filteredResults[index]),
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({
    required this.searches,
    required this.onTap,
    required this.onClear,
  });

  final List<String> searches;
  final void Function(String) onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (searches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_rounded,
                size: 64,
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Tìm kiếm khóa học, bài học',
                style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tìm kiếm gần đây',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: onClear,
                child: Text(
                  'Xóa tất cả',
                  style: tt.labelMedium?.copyWith(color: cs.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: searches.map((s) {
              return InkWell(
                onTap: () => onTap(s),
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history, size: 16, color: cs.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(s, style: tt.bodyMedium),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({required this.query});

  final String query;

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
                color: cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 40,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Không tìm thấy kết quả',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Không có kết quả cho "$query"\nThử từ khóa khác nhé!',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.currentFilter});

  final SearchFilter currentFilter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
          children: SearchFilter.values.map((filter) {
            final isSelected = currentFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => context
                    .read<SearchBloc>()
                    .add(SearchFilterChanged(filter)),
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? cs.primary : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    _getFilterLabel(filter),
                    style: tt.labelMedium?.copyWith(
                      color: isSelected ? cs.onPrimary : cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getFilterLabel(SearchFilter filter) {
    return switch (filter) {
      SearchFilter.all => 'Tất cả',
      SearchFilter.course => 'Khóa học',
      SearchFilter.lesson => 'Bài học',
      SearchFilter.quiz => 'Quiz',
    };
  }
}

class _SearchResultItem extends StatelessWidget {
  const _SearchResultItem({required this.result});

  final SearchResult result;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final typeColor = _getTypeColor(result.type, cs);

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to result
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  _getTypeIcon(result.type),
                  color: typeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
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
                            _getTypeLabel(result.type),
                            style: tt.labelSmall?.copyWith(
                              color: typeColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result.subtitle,
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(SearchFilter type) {
    return switch (type) {
      SearchFilter.all => Icons.search,
      SearchFilter.course => Icons.school_rounded,
      SearchFilter.lesson => Icons.play_circle_rounded,
      SearchFilter.quiz => Icons.quiz_rounded,
    };
  }

  Color _getTypeColor(SearchFilter type, ColorScheme cs) {
    return switch (type) {
      SearchFilter.all => cs.primary,
      SearchFilter.course => cs.primary,
      SearchFilter.lesson => cs.secondary,
      SearchFilter.quiz => cs.tertiary,
    };
  }

  String _getTypeLabel(SearchFilter type) {
    return switch (type) {
      SearchFilter.all => '',
      SearchFilter.course => 'Khóa học',
      SearchFilter.lesson => 'Bài học',
      SearchFilter.quiz => 'Quiz',
    };
  }
}
