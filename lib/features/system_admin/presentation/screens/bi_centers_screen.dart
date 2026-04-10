import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/theme/app_colors.dart';
import '../../bloc/centers/bi_centers_cubit.dart';
import '../../bloc/centers/bi_centers_state.dart';
import '../widgets/widgets.dart';
import 'bi_center_insight_screen.dart' as insight;

/// Màn hình Danh sách Trung tâm Đối tác
class BICentersScreen extends StatelessWidget {
  const BICentersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BICentersCubit()..loadCenters(),
      child: const _CentersView(),
    );
  }
}

class _CentersView extends StatefulWidget {
  const _CentersView();

  @override
  State<_CentersView> createState() => _CentersViewState();
}

class _CentersViewState extends State<_CentersView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<BICentersCubit, BICentersState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: BICompactHeader(
                  title: 'Trung tâm đối tác',
                  subtitle: '${state.centers.length} trung tâm',
                  actions: [
                    IconButton(
                      onPressed: () => _showSortBottomSheet(context),
                      icon: const Icon(Icons.sort_rounded),
                      tooltip: 'Sắp xếp',
                    ),
                    IconButton(
                      onPressed: () => _showFilterBottomSheet(context),
                      icon: Badge(
                        isLabelVisible:
                            state.statusFilter != CenterStatusFilter.all,
                        smallSize: 8,
                        backgroundColor: cs.primary,
                        child: const Icon(Icons.filter_list_rounded),
                      ),
                      tooltip: 'Lọc',
                    ),
                  ],
                ),
              ),

              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm trung tâm...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                context.read<BICentersCubit>().search('');
                              },
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                    ),
                    onChanged: (value) =>
                        context.read<BICentersCubit>().search(value),
                  ),
                ),
              ),

              // Filter chips
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: CenterStatusFilter.values.map((filter) {
                      final isSelected = state.statusFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(_getFilterLabel(filter)),
                          onSelected: (_) {
                            context.read<BICentersCubit>().setFilter(filter);
                          },
                          selectedColor: cs.primaryContainer,
                          checkmarkColor: cs.primary,
                          labelStyle: tt.labelMedium?.copyWith(
                            color: isSelected ? cs.primary : cs.onSurfaceVariant,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Summary stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _SummaryStats(
                    totalCenters: state.filteredCenters.length,
                    totalRevenue: state.filteredCenters
                        .fold<double>(0, (sum, c) => sum + c.revenue),
                    averageRoi: state.filteredCenters.isEmpty
                        ? 0
                        : state.filteredCenters
                                .fold<double>(0, (sum, c) => sum + c.roi) /
                            state.filteredCenters.length,
                  ),
                ),
              ),

              // Centers list
              if (state.status == BICentersStatus.loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.filteredCenters.isEmpty)
                SliverFillRemaining(
                  child: BIEmptyState(
                    icon: Icons.business_outlined,
                    title: 'Không tìm thấy trung tâm',
                    subtitle: state.searchQuery.isNotEmpty
                        ? 'Thử từ khoá khác'
                        : 'Không có trung tâm nào phù hợp với bộ lọc',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final center = state.filteredCenters[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CenterListCard(
                            center: center,
                            showRank: state.sortBy == CenterSortBy.revenue,
                            rank: index + 1,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => insight.BICenterInsightScreen(
                                    centerId: center.id,
                                    centerName: center.name,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: state.filteredCenters.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _getFilterLabel(CenterStatusFilter filter) {
    switch (filter) {
      case CenterStatusFilter.all:
        return 'Tất cả';
      case CenterStatusFilter.growing:
        return 'Đang tăng';
      case CenterStatusFilter.active:
        return 'Hoạt động';
      case CenterStatusFilter.declining:
        return 'Đang giảm';
      case CenterStatusFilter.atRisk:
        return 'Có rủi ro';
    }
  }

  void _showSortBottomSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cubit = context.read<BICentersCubit>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<BICentersCubit, BICentersState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: cs.outline,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Sắp xếp theo',
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...CenterSortBy.values.map((sort) {
                      final isSelected = state.sortBy == sort;
                      return ListTile(
                        leading: Icon(
                          _getSortIcon(sort),
                          color: isSelected ? cs.primary : cs.onSurfaceVariant,
                        ),
                        title: Text(
                          _getSortLabel(sort),
                          style: tt.bodyLarge?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? cs.primary : cs.onSurface,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_rounded, color: cs.primary)
                            : null,
                        onTap: () {
                          cubit.setSortBy(sort);
                          Navigator.pop(context);
                        },
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cubit = context.read<BICentersCubit>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<BICentersCubit, BICentersState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: cs.outline,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Lọc theo trạng thái',
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...CenterStatusFilter.values.map((filter) {
                      final isSelected = state.statusFilter == filter;
                      return ListTile(
                        leading: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getFilterColor(filter, cs),
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(
                          _getFilterLabel(filter),
                          style: tt.bodyLarge?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? cs.primary : cs.onSurface,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_rounded, color: cs.primary)
                            : null,
                        onTap: () {
                          cubit.setFilter(filter);
                          Navigator.pop(context);
                        },
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _getSortLabel(CenterSortBy sort) {
    switch (sort) {
      case CenterSortBy.revenue:
        return 'Doanh thu';
      case CenterSortBy.roi:
        return 'ROI';
      case CenterSortBy.growth:
        return 'Tăng trưởng';
      case CenterSortBy.users:
        return 'Số người dùng';
    }
  }

  IconData _getSortIcon(CenterSortBy sort) {
    switch (sort) {
      case CenterSortBy.revenue:
        return Icons.attach_money_rounded;
      case CenterSortBy.roi:
        return Icons.trending_up_rounded;
      case CenterSortBy.growth:
        return Icons.show_chart_rounded;
      case CenterSortBy.users:
        return Icons.people_rounded;
    }
  }

  Color _getFilterColor(CenterStatusFilter filter, ColorScheme cs) {
    switch (filter) {
      case CenterStatusFilter.all:
        return cs.primary;
      case CenterStatusFilter.growing:
        return cs.secondary;
      case CenterStatusFilter.active:
        return cs.primary;
      case CenterStatusFilter.declining:
        return cs.tertiary;
      case CenterStatusFilter.atRisk:
        return cs.error;
    }
  }
}

class _SummaryStats extends StatelessWidget {
  const _SummaryStats({
    required this.totalCenters,
    required this.totalRevenue,
    required this.averageRoi,
  });

  final int totalCenters;
  final double totalRevenue;
  final double averageRoi;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _StatItem(label: 'Trung tâm', value: totalCenters.toString())),
          Container(width: 1, height: 40, color: cs.outline.withValues(alpha: 0.5)),
          Expanded(child: _StatItem(label: 'Tổng doanh thu', value: _formatRevenue(totalRevenue))),
          Container(width: 1, height: 40, color: cs.outline.withValues(alpha: 0.5)),
          Expanded(child: _StatItem(label: 'ROI TB', value: '${averageRoi.toStringAsFixed(2)}x')),
        ],
      ),
    );
  }

  String _formatRevenue(double val) {
    if (val >= 1e9) return '${(val / 1e9).toStringAsFixed(1)}B';
    if (val >= 1e6) return '${(val / 1e6).toStringAsFixed(0)}M';
    return '${(val / 1e3).toStringAsFixed(0)}K';
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          value,
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
        ),
        const SizedBox(height: 2),
        Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }
}
