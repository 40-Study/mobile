import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/student/bloc/search/search_bloc.dart';
import 'package:study/features/student/bloc/search/search_event.dart';
import 'package:study/features/student/bloc/search/search_state.dart';
import 'package:study/features/student/repository/student_repository.dart';
import 'package:study/theme/theme.dart';

import 'widgets/widgets.dart';

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
              hintText: 'Tim kiem khoa hoc, bai hoc...',
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
            return RecentSearches(
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
            return EmptyResult(query: state.query);
          }

          if (state is SearchSuccess) {
            return Column(
              children: [
                FilterTabs(currentFilter: state.filter),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${state.filteredResults.length} ket qua',
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
                      child: SearchResultItem(result: state.filteredResults[index]),
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
