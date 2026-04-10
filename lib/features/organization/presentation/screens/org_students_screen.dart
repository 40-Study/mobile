import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/organization/bloc/students/org_students_cubit.dart';
import 'package:study/features/organization/data/models/models.dart';

class OrgStudentsScreen extends StatefulWidget {
  const OrgStudentsScreen({super.key});

  @override
  State<OrgStudentsScreen> createState() => _OrgStudentsScreenState();
}

class _OrgStudentsScreenState extends State<OrgStudentsScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  String? _selectedSegment;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<OrgStudentsCubit>().loadStudents();
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
        child: BlocBuilder<OrgStudentsCubit, OrgStudentsState>(
          builder: (context, state) {
            return switch (state) {
              OrgStudentsInitial() || OrgStudentsLoading() =>
                const Center(child: CircularProgressIndicator()),
              OrgStudentsLoaded(:final students) => _StudentsContent(
                  students: students,
                  tabController: _tabController,
                  searchController: _searchController,
                  selectedSegment: _selectedSegment,
                  onSegmentChanged: (s) => setState(() => _selectedSegment = s),
                ),
              OrgStudentsFailure(:final message) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: cs.error),
                      const SizedBox(height: AppSpacing.lg),
                      Text(message),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: context.read<OrgStudentsCubit>().refresh,
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

class _StudentsContent extends StatelessWidget {
  const _StudentsContent({
    required this.students,
    required this.tabController,
    required this.searchController,
    required this.selectedSegment,
    required this.onSegmentChanged,
  });

  final List<OrgStudentModel> students;
  final TabController tabController;
  final TextEditingController searchController;
  final String? selectedSegment;
  final ValueChanged<String?> onSegmentChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Calculate stats
    final activeStudents = students.where((s) => s.status == 'active').length;
    final atRiskStudents = students.where((s) => s.isAtRisk).length;
    final totalRevenue = students.fold<double>(0, (sum, s) => sum + s.totalSpent);
    final avgEngagement = students.isEmpty
        ? 0.0
        : students.fold<double>(0, (sum, s) => sum + s.engagementScore) / students.length;

    // Segment counts
    final segments = {
      'Champion': students.where((s) => s.segment == 'Champion').length,
      'Loyal': students.where((s) => s.segment == 'Loyal').length,
      'Engaged': students.where((s) => s.segment == 'Engaged').length,
      'At Risk': students.where((s) => s.segment == 'At Risk').length,
      'New': students.where((s) => s.segment == 'New').length,
    };

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
                      'Quan ly hoc vien',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                    ),
                    Text(
                      '${students.length} hoc vien',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.file_download_outlined),
                      tooltip: 'Xuat danh sach',
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.tune),
                      tooltip: 'Bo loc',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Summary Cards
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
            child: _SummarySection(
              totalStudents: students.length,
              activeStudents: activeStudents,
              atRiskStudents: atRiskStudents,
              totalRevenue: totalRevenue,
              avgEngagement: avgEngagement,
              segments: segments,
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
                Tab(text: 'Top LTV'),
                Tab(text: 'Can chu y'),
              ],
            ),
            cs.surface.withValues(alpha: 0.95),
          ),
        ),
      ],
      body: TabBarView(
        controller: tabController,
        children: [
          _AllStudentsTab(
            students: students,
            searchController: searchController,
            selectedSegment: selectedSegment,
            onSegmentChanged: onSegmentChanged,
          ),
          _TopLTVTab(students: students),
          _AtRiskTab(students: students),
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
// SUMMARY SECTION
// ============================================================================
class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.totalStudents,
    required this.activeStudents,
    required this.atRiskStudents,
    required this.totalRevenue,
    required this.avgEngagement,
    required this.segments,
  });

  final int totalStudents;
  final int activeStudents;
  final int atRiskStudents;
  final double totalRevenue;
  final double avgEngagement;
  final Map<String, int> segments;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hero Card
        _StudentHeroCard(
          totalStudents: totalStudents,
          activeStudents: activeStudents,
          totalRevenue: totalRevenue,
        ),
        const SizedBox(height: AppSpacing.md),

        // Segment Distribution
        _SegmentDistribution(segments: segments, total: totalStudents),
        const SizedBox(height: AppSpacing.md),

        // Quick Stats
        Row(
          children: [
            Expanded(
              child: _QuickStatCard(
                title: 'Engagement TB',
                value: '${avgEngagement.toStringAsFixed(0)}%',
                icon: Icons.insights,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickStatCard(
                title: 'Can chu y',
                value: atRiskStudents.toString(),
                icon: Icons.warning_amber,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StudentHeroCard extends StatelessWidget {
  const _StudentHeroCard({
    required this.totalStudents,
    required this.activeStudents,
    required this.totalRevenue,
  });

  final int totalStudents;
  final int activeStudents;
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
          colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
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
                  'Tong chi tieu',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(totalRevenue / 1000000000).toStringAsFixed(2)}B',
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
                      label: '$totalStudents HV',
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _HeroChip(
                      icon: Icons.check_circle,
                      label: '$activeStudents active',
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
              Icons.groups,
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

class _SegmentDistribution extends StatelessWidget {
  const _SegmentDistribution({
    required this.segments,
    required this.total,
  });

  final Map<String, int> segments;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final colors = {
      'Champion': Colors.purple,
      'Loyal': Colors.blue,
      'Engaged': Colors.green,
      'At Risk': Colors.orange,
      'New': Colors.teal,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phan khuc hoc vien',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Stacked Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: segments.entries.map((entry) {
                  final percent = total > 0 ? entry.value / total : 0.0;
                  if (percent == 0) return const SizedBox.shrink();
                  return Expanded(
                    flex: (percent * 100).round().clamp(1, 100),
                    child: Container(color: colors[entry.key] ?? Colors.grey),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: segments.entries.map((entry) {
              final percent = total > 0 ? (entry.value / total * 100) : 0.0;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[entry.key] ?? Colors.grey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.key}: ${entry.value} (${percent.toStringAsFixed(0)}%)',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            }).toList(),
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
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

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
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: cs.onSurface,
                  ),
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
// ALL STUDENTS TAB
// ============================================================================
class _AllStudentsTab extends StatelessWidget {
  const _AllStudentsTab({
    required this.students,
    required this.searchController,
    required this.selectedSegment,
    required this.onSegmentChanged,
  });

  final List<OrgStudentModel> students;
  final TextEditingController searchController;
  final String? selectedSegment;
  final ValueChanged<String?> onSegmentChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final filteredStudents = selectedSegment == null
        ? students
        : students.where((s) => s.segment == selectedSegment).toList();

    return RefreshIndicator(
      onRefresh: context.read<OrgStudentsCubit>().refresh,
      child: ListView(
        padding: const EdgeInsets.all(AppLayout.screenMargin),
        children: [
          // Search
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Tim kiem hoc vien...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: cs.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              context.read<OrgStudentsCubit>().search(value);
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Segment Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _SegmentChip(
                  label: 'Tat ca',
                  count: students.length,
                  isSelected: selectedSegment == null,
                  onSelected: () {
                    onSegmentChanged(null);
                    context.read<OrgStudentsCubit>().filterByStatus(null);
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                _SegmentChip(
                  label: 'Champion',
                  count: students.where((s) => s.segment == 'Champion').length,
                  isSelected: selectedSegment == 'Champion',
                  color: Colors.purple,
                  onSelected: () => onSegmentChanged('Champion'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _SegmentChip(
                  label: 'Loyal',
                  count: students.where((s) => s.segment == 'Loyal').length,
                  isSelected: selectedSegment == 'Loyal',
                  color: Colors.blue,
                  onSelected: () => onSegmentChanged('Loyal'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _SegmentChip(
                  label: 'At Risk',
                  count: students.where((s) => s.segment == 'At Risk').length,
                  isSelected: selectedSegment == 'At Risk',
                  color: Colors.orange,
                  onSelected: () => onSegmentChanged('At Risk'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // List
          if (filteredStudents.isEmpty)
            _EmptyState()
          else
            ...filteredStudents.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _StudentCard(student: s),
                )),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({
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

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student});

  final OrgStudentModel student;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isActive = student.status == 'active';
    final segment = student.segment;
    final segmentColor = _getSegmentColor(segment);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: student.isAtRisk
              ? Colors.orange.withValues(alpha: 0.5)
              : cs.outlineVariant.withValues(alpha: 0.3),
          width: student.isAtRisk ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: cs.secondaryContainer,
                    backgroundImage: student.avatarUrl != null
                        ? NetworkImage(student.avatarUrl!)
                        : null,
                    child: student.avatarUrl == null
                        ? Text(
                            student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
                            style: TextStyle(
                              color: cs.secondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          )
                        : null,
                  ),
                  if (student.hasSubscription)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.surface, width: 2),
                        ),
                        child: const Icon(Icons.star, size: 10, color: Colors.white),
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
                            student.name,
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
                            color: segmentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: segmentColor.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            segment,
                            style: TextStyle(
                              color: segmentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      student.email ?? '',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 14,
                          color: student.currentStreakDays > 0 ? Colors.orange : Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${student.currentStreakDays} ngay streak',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        if (student.isAtRisk)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning, size: 12, color: Colors.orange),
                                const SizedBox(width: 2),
                                Text(
                                  'Co nguy co roi bo',
                                  style: TextStyle(
                                    color: Colors.orange,
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

          // Health Score
          _HealthScoreBar(score: student.healthScore),

          const SizedBox(height: AppSpacing.lg),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tien do hoc tap',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${student.averageProgress.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      if (student.weeklyProgressChange != 0) ...[
                        const SizedBox(width: 4),
                        Icon(
                          student.weeklyProgressChange > 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 12,
                          color: student.weeklyProgressChange > 0 ? Colors.green : Colors.red,
                        ),
                        Text(
                          '${student.weeklyProgressChange.abs().toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: student.weeklyProgressChange > 0 ? Colors.green : Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: student.averageProgress / 100,
                  backgroundColor: cs.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(cs.primary),
                  minHeight: 8,
                ),
              ),
            ],
          ),

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
                    label: 'Dang hoc',
                    value: '${student.inProgressCourses}/${student.enrolledCourses}',
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _StatItem(
                    icon: Icons.access_time,
                    label: 'Gio hoc',
                    value: '${student.totalLearningHours.toStringAsFixed(0)}h',
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _StatItem(
                    icon: Icons.payments_outlined,
                    label: 'Chi tieu',
                    value: _formatCompactCurrency(student.totalSpent),
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
                  label: const Text('Chi tiet'),
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
                  icon: const Icon(Icons.message_outlined, size: 18),
                  label: const Text('Lien he'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getSegmentColor(String segment) {
    switch (segment) {
      case 'Champion':
        return Colors.purple;
      case 'Loyal':
        return Colors.blue;
      case 'Engaged':
        return Colors.green;
      case 'At Risk':
        return Colors.orange;
      case 'New':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatCompactCurrency(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }
}

class _HealthScoreBar extends StatelessWidget {
  const _HealthScoreBar({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = score >= 70
        ? Colors.green
        : score >= 50
            ? Colors.blue
            : score >= 30
                ? Colors.orange
                : Colors.red;

    return Row(
      children: [
        Text(
          'Health Score',
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${score.toInt()}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
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
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: cs.onSurface,
          ),
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
// TOP LTV TAB
// ============================================================================
class _TopLTVTab extends StatelessWidget {
  const _TopLTVTab({required this.students});

  final List<OrgStudentModel> students;

  @override
  Widget build(BuildContext context) {
    final sorted = List<OrgStudentModel>.from(students)
      ..sort((a, b) => b.lifetimeValue.compareTo(a.lifetimeValue));

    return ListView(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      children: [
        ...sorted.take(20).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final student = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _RankingCard(
              rank: index + 1,
              student: student,
              metric: _formatCurrency(student.lifetimeValue),
              metricLabel: 'Lifetime Value',
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
// AT RISK TAB
// ============================================================================
class _AtRiskTab extends StatelessWidget {
  const _AtRiskTab({required this.students});

  final List<OrgStudentModel> students;

  @override
  Widget build(BuildContext context) {
    final atRiskStudents = students.where((s) => s.isAtRisk || s.segment == 'At Risk').toList()
      ..sort((a, b) => b.daysSinceLastActivity.compareTo(a.daysSinceLastActivity));

    if (atRiskStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration,
              size: 64,
              color: Colors.green.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Khong co hoc vien nao can chu y!',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      children: [
        // Warning Banner
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${atRiskStudents.length} hoc vien can chu y',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      'Nhung hoc vien nay co the roi bo neu khong hanh dong',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        ...atRiskStudents.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _AtRiskCard(student: s),
            )),

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

class _AtRiskCard extends StatelessWidget {
  const _AtRiskCard({required this.student});

  final OrgStudentModel student;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: cs.secondaryContainer,
                backgroundImage:
                    student.avatarUrl != null ? NetworkImage(student.avatarUrl!) : null,
                child: student.avatarUrl == null
                    ? Text(
                        student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
                        style: TextStyle(color: cs.secondary, fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      'Khong hoat dong ${student.daysSinceLastActivity} ngay',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'LTV: ${_formatCurrency(student.lifetimeValue)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    '${student.enrolledCourses} khoa hoc',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.email_outlined, size: 18),
                  label: const Text('Gui email'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.card_giftcard, size: 18),
                  label: const Text('Gui uu dai'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }
}

class _RankingCard extends StatelessWidget {
  const _RankingCard({
    required this.rank,
    required this.student,
    required this.metric,
    required this.metricLabel,
    required this.color,
  });

  final int rank;
  final OrgStudentModel student;
  final String metric;
  final String metricLabel;
  final Color color;

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
            backgroundColor: cs.secondaryContainer,
            backgroundImage:
                student.avatarUrl != null ? NetworkImage(student.avatarUrl!) : null,
            child: student.avatarUrl == null
                ? Text(
                    student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
                    style: TextStyle(color: cs.secondary, fontWeight: FontWeight.w700),
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
                  student.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  '${student.enrolledCourses} khoa hoc • ${student.totalLearningHours.toStringAsFixed(0)}h hoc',
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
            Icons.people_outline,
            size: 64,
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Chua co hoc vien nao',
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
