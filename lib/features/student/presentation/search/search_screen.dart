import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/search/search_bloc.dart';
import 'package:study/features/student/bloc/search/search_event.dart';
import 'package:study/features/student/bloc/search/search_state.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/empty_state.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchBloc(),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Tim kiem khoa hoc, bai hoc...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                context.read<SearchBloc>().add(const SearchCleared());
              },
            ),
          ),
          onChanged: (value) => context
              .read<SearchBloc>()
              .add(SearchQueryChanged(value)),
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
            );
          }

          if (state is SearchInProgress) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SearchEmpty) {
            return EmptyState(
              icon: Icons.search_off,
              title: 'Khong tim thay',
              message: 'Khong co ket qua cho "${state.query}"',
            );
          }

          if (state is SearchSuccess) {
            return Column(
              children: [
                _FilterTabs(currentFilter: state.filter),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: state.filteredResults.length,
                    separatorBuilder: (_, _) => AppSpacing.vGap12,
                    itemBuilder: (context, index) =>
                        _SearchResultItem(result: state.filteredResults[index]),
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
  });

  final List<String> searches;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tim kiem gan day',
            style: tt.labelLarge?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          AppSpacing.vGap12,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: searches.map((s) {
              return ActionChip(
                label: Text(s),
                onPressed: () => onTap(s),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.currentFilter});

  final SearchFilter currentFilter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: SearchFilter.values.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(_getFilterLabel(filter)),
              selected: currentFilter == filter,
              onSelected: (_) => context
                  .read<SearchBloc>()
                  .add(SearchFilterChanged(filter)),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getFilterLabel(SearchFilter filter) {
    switch (filter) {
      case SearchFilter.all:
        return 'Tat ca';
      case SearchFilter.course:
        return 'Khoa hoc';
      case SearchFilter.lesson:
        return 'Bai hoc';
      case SearchFilter.quiz:
        return 'Quiz';
    }
  }
}

class _SearchResultItem extends StatelessWidget {
  const _SearchResultItem({required this.result});

  final SearchResult result;

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
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTypeIcon(result.type),
              color: cs.primary,
            ),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.title,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  result.subtitle,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: cs.onSurface.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(SearchFilter type) {
    switch (type) {
      case SearchFilter.all:
        return Icons.search;
      case SearchFilter.course:
        return Icons.school_outlined;
      case SearchFilter.lesson:
        return Icons.play_circle_outline;
      case SearchFilter.quiz:
        return Icons.quiz_outlined;
    }
  }
}
