import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/organization/bloc/teachers/org_teachers_cubit.dart';
import 'package:study/features/organization/data/models/models.dart';

class OrgTeachersScreen extends StatefulWidget {
  const OrgTeachersScreen({super.key});

  @override
  State<OrgTeachersScreen> createState() => _OrgTeachersScreenState();
}

class _OrgTeachersScreenState extends State<OrgTeachersScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<OrgTeachersCubit>().loadTeachers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: BlocBuilder<OrgTeachersCubit, OrgTeachersState>(
          builder: (context, state) {
            return switch (state) {
              OrgTeachersInitial() || OrgTeachersLoading() =>
                const Center(child: CircularProgressIndicator()),
              OrgTeachersLoaded(:final teachers) => _TeachersContent(
                  teachers: teachers,
                  tabController: _tabController,
                  searchController: _searchController,
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (f) => setState(() => _selectedFilter = f),
                ),
              OrgTeachersFailure(:final message) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: cs.error),
                      const SizedBox(height: AppSpacing.lg),
                      Text(message),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: context.read<OrgTeachersCubit>().refresh,
                        child: const Text('Thu lai'),
                      ),
                    ],
                  ),
                ),
            };
          },
        ),
      ),
    );
  }
}

class _TeachersContent extends StatelessWidget {
  const _TeachersContent({
    required this.teachers,
    required this.tabController,
    required this.searchController,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final List<OrgTeacherModel> teachers;
  final TabController tabController;
  final TextEditingController searchController;
  final String? selectedFilter;
  final ValueChanged<String?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Calculate summary stats from teachers
    final activeTeachers = teachers.where((t) => t.status == 'active').length;
    final totalRevenue = teachers.fold<double>(0, (sum, t) => sum + t.monthlyRevenue);
    final totalPending = teachers.fold<double>(0, (sum, t) => sum + t.pendingPayout);
    final avgRating = teachers.isEmpty
        ? 0.0
        : teachers.fold<double>(0, (sum, t) => sum + t.rating) / teachers.length;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppLayout.screenMargin),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quan ly giao vien',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                    ),
                    Text(
                      '${teachers.length} giao vien',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: () => _showInviteDialog(context),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Moi'),
                ),
              ],
            ),
          ),
        ),

        // Summary Cards
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
            child: _SummaryCards(
              totalTeachers: teachers.length,
              activeTeachers: activeTeachers,
              totalRevenue: totalRevenue,
              totalPending: totalPending,
              avgRating: avgRating,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

        // Tab Bar
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            TabBar(
              controller: tabController,
              labelColor: cs.primary,
              unselectedLabelColor: cs.onSurfaceVariant,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Tat ca'),
                Tab(text: 'Top doanh thu'),
                Tab(text: 'Top rating'),
              ],
            ),
            cs.surface.withValues(alpha: 0.95),
          ),
        ),
      ],
      body: TabBarView(
        controller: tabController,
        children: [
          _AllTeachersTab(
            teachers: teachers,
            searchController: searchController,
            selectedFilter: selectedFilter,
            onFilterChanged: onFilterChanged,
          ),
          _TopRevenueTab(teachers: teachers),
          _TopRatingTab(teachers: teachers),
        ],
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Moi giao vien'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nhap email giao vien de gui loi moi tham gia to chuc.'),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Email giao vien',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Huy'),
          ),
          FilledButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                context.read<OrgTeachersCubit>().inviteTeacher(emailController.text);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Da gui loi moi!')),
                );
              }
            },
            child: const Text('Gui loi moi'),
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar, this.backgroundColor);

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

// ============================================================================
// SUMMARY CARDS
// ============================================================================
class _SummaryCards extends StatelessWidget {
  const _SummaryCards({
    required this.totalTeachers,
    required this.activeTeachers,
    required this.totalRevenue,
    required this.totalPending,
    required this.avgRating,
  });

  final int totalTeachers;
  final int activeTeachers;
  final double totalRevenue;
  final double totalPending;
  final double avgRating;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hero Card
        _TeacherHeroCard(
          totalTeachers: totalTeachers,
          activeTeachers: activeTeachers,
          totalRevenue: totalRevenue,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _QuickStatCard(
                title: 'Cho thanh toan',
                value: _formatShortCurrency(totalPending),
                icon: Icons.payments_outlined,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickStatCard(
                title: 'Rating TB',
                value: avgRating.toStringAsFixed(1),
                icon: Icons.star,
                color: Colors.amber,
                suffix: '/5',
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatShortCurrency(double amount) {
    if (amount >= 1000000000) return '${(amount / 1000000000).toStringAsFixed(1)}B';
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(0)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }
}

class _TeacherHeroCard extends StatelessWidget {
  const _TeacherHeroCard({
    required this.totalTeachers,
    required this.activeTeachers,
    required this.totalRevenue,
  });

  final int totalTeachers;
  final int activeTeachers;
  final double totalRevenue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doanh thu thang',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(totalRevenue / 1000000).toStringAsFixed(0)}M',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _HeroChip(
                      icon: Icons.people,
                      label: '$totalTeachers GV',
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _HeroChip(
                      icon: Icons.check_circle,
                      label: '$activeTeachers hoat dong',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.school,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.suffix,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: cs.onSurface,
                      ),
                    ),
                    if (suffix != null)
                      Text(
                        suffix!,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ALL TEACHERS TAB
// ============================================================================
class _AllTeachersTab extends StatelessWidget {
  const _AllTeachersTab({
    required this.teachers,
    required this.searchController,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final List<OrgTeacherModel> teachers;
  final TextEditingController searchController;
  final String? selectedFilter;
  final ValueChanged<String?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final filteredTeachers = selectedFilter == null
        ? teachers
        : teachers.where((t) => t.status == selectedFilter).toList();

    return RefreshIndicator(
      onRefresh: context.read<OrgTeachersCubit>().refresh,
      child: ListView(
        padding: const EdgeInsets.all(AppLayout.screenMargin),
        children: [
          // Search
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Tim kiem giao vien...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: cs.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              context.read<OrgTeachersCubit>().search(value);
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tat ca',
                  count: teachers.length,
                  isSelected: selectedFilter == null,
                  onSelected: () {
                    onFilterChanged(null);
                    context.read<OrgTeachersCubit>().filterByStatus(null);
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: 'Hoat dong',
                  count: teachers.where((t) => t.status == 'active').length,
                  isSelected: selectedFilter == 'active',
                  color: Colors.green,
                  onSelected: () {
                    onFilterChanged('active');
                    context.read<OrgTeachersCubit>().filterByStatus('active');
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: 'Tam ngung',
                  count: teachers.where((t) => t.status == 'inactive').length,
                  isSelected: selectedFilter == 'inactive',
                  color: Colors.grey,
                  onSelected: () {
                    onFilterChanged('inactive');
                    context.read<OrgTeachersCubit>().filterByStatus('inactive');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // List
          if (filteredTeachers.isEmpty)
            _EmptyState()
          else
            ...filteredTeachers.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _TeacherCard(teacher: t),
                )),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onSelected,
    this.color,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onSelected;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? cs.primary).withValues(alpha: 0.1)
              : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? (color ?? cs.primary) : cs.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? (color ?? cs.primary) : cs.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? (color ?? cs.primary).withValues(alpha: 0.2)
                    : cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? (color ?? cs.primary) : cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherCard extends StatelessWidget {
  const _TeacherCard({required this.teacher});

  final OrgTeacherModel teacher;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isActive = teacher.status == 'active';
    final tier = teacher.tier;
    final tierColor = _getTierColor(tier);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: cs.primaryContainer,
                    backgroundImage: teacher.avatarUrl != null
                        ? NetworkImage(teacher.avatarUrl!)
                        : null,
                    child: teacher.avatarUrl == null
                        ? Text(
                            teacher.name.isNotEmpty ? teacher.name[0].toUpperCase() : 'T',
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.surface, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            teacher.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [tierColor, tierColor.withValues(alpha: 0.7)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tier,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      teacher.email ?? '',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          teacher.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          ' (${teacher.totalReviews})',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        if (teacher.verificationStatus == 'verified')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, size: 12, color: Colors.blue),
                                const SizedBox(width: 2),
                                Text(
                                  'Xac minh',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Performance Gauge
          _PerformanceGauge(score: teacher.performanceScore),

          const SizedBox(height: AppSpacing.lg),

          // Stats Grid
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.play_circle_outline,
                    label: 'Khoa hoc',
                    value: '${teacher.activeCourses}/${teacher.totalCourses}',
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _StatItem(
                    icon: Icons.people_outline,
                    label: 'Hoc vien',
                    value: teacher.totalStudents.toString(),
                    subValue: '+${teacher.newStudentsThisMonth}',
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _StatItem(
                    icon: Icons.trending_up,
                    label: 'Doanh thu',
                    value: _formatCompactCurrency(teacher.monthlyRevenue),
                    change: teacher.revenueChange,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.analytics_outlined, size: 18),
                  label: const Text('Phan tich'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.primary,
                    side: BorderSide(color: cs.primary),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.payments_outlined, size: 18),
                  label: const Text('Thanh toan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'Diamond':
        return const Color(0xFF00BCD4);
      case 'Platinum':
        return const Color(0xFF9E9E9E);
      case 'Gold':
        return const Color(0xFFFFB300);
      case 'Silver':
        return const Color(0xFF78909C);
      default:
        return const Color(0xFFCD7F32);
    }
  }

  String _formatCompactCurrency(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }
}

class _PerformanceGauge extends StatelessWidget {
  const _PerformanceGauge({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = score >= 80
        ? Colors.green
        : score >= 60
            ? Colors.blue
            : score >= 40
                ? Colors.orange
                : Colors.red;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hieu suat',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            Text(
              '${score.toInt()}/100',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: cs.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.subValue,
    this.change,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subValue;
  final double? change;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: cs.onSurface,
              ),
            ),
            if (subValue != null) ...[
              const SizedBox(width: 4),
              Text(
                subValue!,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (change != null) ...[
              const SizedBox(width: 4),
              Icon(
                change! >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                size: 10,
                color: change! >= 0 ? Colors.green : Colors.red,
              ),
              Text(
                '${change!.abs().toStringAsFixed(0)}%',
                style: TextStyle(
                  color: change! >= 0 ? Colors.green : Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        Text(
          label,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}

// ============================================================================
// TOP REVENUE TAB
// ============================================================================
class _TopRevenueTab extends StatelessWidget {
  const _TopRevenueTab({required this.teachers});

  final List<OrgTeacherModel> teachers;

  @override
  Widget build(BuildContext context) {
    final sorted = List<OrgTeacherModel>.from(teachers)
      ..sort((a, b) => b.monthlyRevenue.compareTo(a.monthlyRevenue));

    return ListView(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      children: [
        ...sorted.asMap().entries.map((entry) {
          final index = entry.key;
          final teacher = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _RankingCard(
              rank: index + 1,
              teacher: teacher,
              metric: _formatCurrency(teacher.monthlyRevenue),
              metricLabel: 'Doanh thu thang',
              color: _getRankColor(index),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700);
      case 1:
        return const Color(0xFFC0C0C0);
      case 2:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey;
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }
}

// ============================================================================
// TOP RATING TAB
// ============================================================================
class _TopRatingTab extends StatelessWidget {
  const _TopRatingTab({required this.teachers});

  final List<OrgTeacherModel> teachers;

  @override
  Widget build(BuildContext context) {
    final sorted = List<OrgTeacherModel>.from(teachers)
      ..sort((a, b) => b.rating.compareTo(a.rating));

    return ListView(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      children: [
        ...sorted.asMap().entries.map((entry) {
          final index = entry.key;
          final teacher = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _RankingCard(
              rank: index + 1,
              teacher: teacher,
              metric: teacher.rating.toStringAsFixed(1),
              metricLabel: 'Rating (${teacher.totalReviews} reviews)',
              color: _getRankColor(index),
              showStars: true,
            ),
          );
        }),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700);
      case 1:
        return const Color(0xFFC0C0C0);
      case 2:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey;
    }
  }
}

class _RankingCard extends StatelessWidget {
  const _RankingCard({
    required this.rank,
    required this.teacher,
    required this.metric,
    required this.metricLabel,
    required this.color,
    this.showStars = false,
  });

  final int rank;
  final OrgTeacherModel teacher;
  final String metric;
  final String metricLabel;
  final Color color;
  final bool showStars;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rank <= 3 ? color.withValues(alpha: 0.5) : cs.outlineVariant.withValues(alpha: 0.3),
          width: rank <= 3 ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: rank <= 3 ? color : cs.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(
                      rank == 1
                          ? Icons.emoji_events
                          : rank == 2
                              ? Icons.workspace_premium
                              : Icons.military_tech,
                      color: Colors.white,
                      size: 20,
                    )
                  : Text(
                      '#$rank',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: cs.primaryContainer,
            backgroundImage:
                teacher.avatarUrl != null ? NetworkImage(teacher.avatarUrl!) : null,
            child: teacher.avatarUrl == null
                ? Text(
                    teacher.name.isNotEmpty ? teacher.name[0].toUpperCase() : 'T',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  '${teacher.totalCourses} khoa hoc • ${teacher.totalStudents} hoc vien',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Metric
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (showStars)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 2),
                    Text(
                      metric,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  metric,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: cs.onSurface,
                  ),
                ),
              Text(
                metricLabel,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Chua co giao vien nao',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
