import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/parent/bloc/child_detail/child_detail_cubit.dart';
import 'package:study/features/parent/bloc/child_detail/child_detail_state.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/data/repository/parent_repository.dart';
import 'package:study/features/parent/presentation/widgets/widgets.dart';
import 'package:study/theme/app_colors.dart';

class ChildDetailScreen extends StatelessWidget {
  const ChildDetailScreen({
    super.key,
    required this.child,
  });

  final ChildModel child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChildDetailCubit(
        repository: diContainer.get<ParentRepository>(),
      )..loadChildDetail(child),
      child: _ChildDetailView(child: child),
    );
  }
}

class _ChildDetailView extends StatelessWidget {
  const _ChildDetailView({required this.child});

  final ChildModel child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(child.name),
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocBuilder<ChildDetailCubit, ChildDetailState>(
        builder: (context, state) {
          return switch (state) {
            ChildDetailInitial() ||
            ChildDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            ChildDetailLoaded() => _ChildDetailContent(state: state),
            ChildDetailFailure(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: cs.error),
                    const SizedBox(height: 16),
                    Text(message),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        context.read<ChildDetailCubit>().loadChildDetail(child);
                      },
                      child: const Text('Thu lai'),
                    ),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }
}

class _ChildDetailContent extends StatefulWidget {
  const _ChildDetailContent({required this.state});

  final ChildDetailLoaded state;

  @override
  State<_ChildDetailContent> createState() => _ChildDetailContentState();
}

class _ChildDetailContentState extends State<_ChildDetailContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final child = widget.state.child;

    return RefreshIndicator(
      onRefresh: () =>
          context.read<ChildDetailCubit>().refresh(widget.state.child),
      child: CustomScrollView(
        slivers: [
          // Child info header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile section
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: cs.primaryContainer,
                        backgroundImage: child.avatarUrl != null
                            ? NetworkImage(child.avatarUrl!)
                            : null,
                        child: child.avatarUrl == null
                            ? Icon(
                                Icons.person,
                                size: 40,
                                color: cs.onPrimaryContainer,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.name,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hoc sinh ${child.displayGrade}',
                              style: textTheme.bodyMedium?.copyWith(
                                color: cs.textSecondary,
                              ),
                            ),
                            Text(
                              child.displaySchool,
                              style: textTheme.bodyMedium?.copyWith(
                                color: cs.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats cards
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.check_circle_outline,
                        value: child.attendancePercentage,
                        label: 'Chuyen can',
                        color: cs.primary,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.trending_up,
                        value: child.averageScoreDisplay,
                        label: 'Diem TB',
                        color: cs.tertiary,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.school_outlined,
                        value: '${child.classCount}',
                        label: 'Lop hoc',
                        color: cs.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tab bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: 'Lop hoc'),
                  Tab(text: 'Diem danh'),
                  Tab(text: 'Khoa hoc online'),
                  Tab(text: 'Ket qua'),
                ],
              ),
              backgroundColor: cs.surface,
            ),
          ),

          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ClassesTab(classes: widget.state.classes),
                _AttendanceTab(attendances: widget.state.attendances),
                _EnrollmentsTab(enrollments: widget.state.enrollments),
                _ResultsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: cs.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this.tabBar, {required this.backgroundColor});

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

class _ClassesTab extends StatelessWidget {
  const _ClassesTab({required this.classes});

  final List<ChildClassModel> classes;

  @override
  Widget build(BuildContext context) {
    if (classes.isEmpty) {
      return const Center(
        child: Text('Chua co lop hoc nao'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ClassCard(
            classModel: classes[index],
            onTap: () {
              // TODO: Navigate to class detail
            },
          ),
        );
      },
    );
  }
}

class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab({required this.attendances});

  final List<ChildAttendanceModel> attendances;

  @override
  Widget build(BuildContext context) {
    if (attendances.isEmpty) {
      return const Center(
        child: Text('Chua co du lieu diem danh'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: attendances.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AttendanceListItem(
            attendance: attendances[index],
          ),
        );
      },
    );
  }
}

class _EnrollmentsTab extends StatelessWidget {
  const _EnrollmentsTab({required this.enrollments});

  final List<ChildEnrollmentModel> enrollments;

  @override
  Widget build(BuildContext context) {
    if (enrollments.isEmpty) {
      return const Center(
        child: Text('Chua dang ky khoa hoc online nao'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: enrollments.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: EnrollmentCard(
            enrollment: enrollments[index],
            onTap: () {
              // TODO: Navigate to course detail
            },
          ),
        );
      },
    );
  }
}

class _ResultsTab extends StatelessWidget {
  const _ResultsTab();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: cs.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Tinh nang dang phat trien',
            style: textTheme.titleMedium?.copyWith(
              color: cs.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ket qua hoc tap se duoc hien thi o day',
            style: textTheme.bodyMedium?.copyWith(
              color: cs.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
