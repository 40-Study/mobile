import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/teacher/bloc/classes/teacher_classes_cubit.dart';
import 'package:study/features/teacher/data/models/models.dart';

class TeacherClassesScreen extends StatefulWidget {
  const TeacherClassesScreen({super.key});

  @override
  State<TeacherClassesScreen> createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends State<TeacherClassesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherClassesCubit>().loadClasses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<TeacherClassesCubit, TeacherClassesState>(
        builder: (context, state) {
          return switch (state) {
            TeacherClassesInitial() ||
            TeacherClassesLoading() =>
              const Center(child: CircularProgressIndicator()),
            TeacherClassesLoaded() => RefreshIndicator(
                onRefresh: context.read<TeacherClassesCubit>().refresh,
                child: _ClassesContent(state: state),
              ),
            TeacherClassesFailure(:final message) =>
              _buildErrorState(context, message),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/teacher/classes/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: cs.error),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.read<TeacherClassesCubit>().loadClasses(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

class _ClassesContent extends StatelessWidget {
  const _ClassesContent({required this.state});

  final TeacherClassesLoaded state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textColor = cs.onSurface;
    final activeClasses =
        state.classes.where((c) => c.classStatus == ClassStatus.active).toList();
    final todayClasses = activeClasses.where((c) {
      if (c.nextScheduleDate == null) return false;
      final now = DateTime.now();
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      return c.nextScheduleDate == today;
    }).toList();
    final upcomingClasses = activeClasses.where((c) {
      if (c.nextScheduleDate == null) return true;
      final now = DateTime.now();
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      return c.nextScheduleDate != today;
    }).toList();

    return SafeArea(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          // Header greeting
          _GreetingHeader(
            todayClassCount: todayClasses.length,
            textColor: textColor,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Stats cards
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
            child: _StatsRow(
              totalClasses: state.classes.length,
              totalStudents: state.totalStudents,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Active classes section
          if (todayClasses.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.screenMargin),
              child: _SectionHeader(
                title: 'Lớp học đang hoạt động',
                actionLabel: 'Xem tất cả',
                onActionTap: () {},
                textColor: textColor,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Featured active class (first one)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.screenMargin),
              child: _ActiveClassCard(
                classModel: todayClasses.first,
                isInProgress: true,
                onTap: () => _navigateToDetail(context, todayClasses.first),
                onAttendance: () =>
                    _navigateToAttendance(context, todayClasses.first),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Upcoming classes
          if (upcomingClasses.isNotEmpty || todayClasses.length > 1) ...[
            ...todayClasses.skip(1).map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(
                      left: AppLayout.screenMargin,
                      right: AppLayout.screenMargin,
                      bottom: AppSpacing.md,
                    ),
                    child: _UpcomingClassCard(
                      classModel: c,
                      onTap: () => _navigateToDetail(context, c),
                    ),
                  ),
                ),
            ...upcomingClasses.take(3).map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(
                      left: AppLayout.screenMargin,
                      right: AppLayout.screenMargin,
                      bottom: AppSpacing.md,
                    ),
                    child: _UpcomingClassCard(
                      classModel: c,
                      onTap: () => _navigateToDetail(context, c),
                    ),
                  ),
                ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Grading progress card
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
            child: _GradingProgressCard(
              title: 'Tiến độ chấm bài',
              assignmentName: 'Bài tập Chương 2',
              progress: 0.75,
              onContinue: () {},
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, ClassModel classModel) {
    Navigator.pushNamed(
      context,
      '/teacher/classes/detail',
      arguments: classModel.id,
    );
  }

  void _navigateToAttendance(BuildContext context, ClassModel classModel) {
    Navigator.pushNamed(
      context,
      '/teacher/attendance',
      arguments: classModel.id,
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({
    required this.todayClassCount,
    required this.textColor,
  });

  final int todayClassCount;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Chào buổi sáng';
    } else if (hour < 18) {
      greeting = 'Chào buổi chiều';
    } else {
      greeting = 'Chào buổi tối';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppLayout.screenMargin,
        AppSpacing.lg,
        AppLayout.screenMargin,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, Giảng viên!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            todayClassCount > 0
                ? 'Hôm nay bạn có $todayClassCount lớp học sắp diễn ra.'
                : 'Hôm nay bạn không có lớp học nào.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor.withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.totalClasses,
    required this.totalStudents,
  });

  final int totalClasses;
  final int totalStudents;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.school_outlined,
            label: 'Tổng số lớp',
            value: totalClasses.toString(),
            gradient: LinearGradient(
              colors: [cs.primary, cs.primary.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: Icons.people_outline,
            label: 'Học sinh',
            value: totalStudents.toString(),
            gradient: LinearGradient(
              colors: [
                cs.primary.withValues(alpha: 0.3),
                cs.primary.withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            isLight: true,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
    this.isLight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Gradient gradient;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textColor = isLight ? cs.primary : Colors.white;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onActionTap,
    required this.textColor,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionLabel!,
              style: TextStyle(
                color: cs.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}

class _ActiveClassCard extends StatelessWidget {
  const _ActiveClassCard({
    required this.classModel,
    required this.isInProgress,
    required this.onTap,
    required this.onAttendance,
  });

  final ClassModel classModel;
  final bool isInProgress;
  final VoidCallback onTap;
  final VoidCallback onAttendance;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status badge and icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'ĐANG HỌC',
                        style: tt.labelSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      classModel.isOnline
                          ? Icons.videocam_outlined
                          : Icons.calculate_outlined,
                      color: cs.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Class name
              Text(
                classModel.displayName,
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Students and schedule row
              Row(
                children: [
                  // Student avatars
                  Expanded(
                    child: Row(
                      children: [
                        _buildAvatarStack(context),
                        if (classModel.studentCount > 3) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '+${classModel.studentCount - 3}',
                              style: tt.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Schedule
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'LỊCH TIẾP THEO',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        classModel.nextScheduleTime ?? '—',
                        style: tt.titleMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Divider
              Container(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Location and action
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      classModel.nextScheduleRoom ?? 'Chưa xác định',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: onAttendance,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.sm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Điểm danh'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarStack(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = [
      cs.primary,
      cs.tertiary,
      cs.secondary,
    ];

    return SizedBox(
      width: 76,
      height: 32,
      child: Stack(
        children: List.generate(
          3,
          (index) => Positioned(
            left: index * 22.0,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: colors[index % colors.length],
              child: Text(
                ['A', 'B', 'C'][index],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UpcomingClassCard extends StatelessWidget {
  const _UpcomingClassCard({
    required this.classModel,
    required this.onTap,
  });

  final ClassModel classModel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    String dateLabel = 'SẮP TỚI';
    if (classModel.nextScheduleDate != null) {
      final date = DateTime.tryParse(classModel.nextScheduleDate!);
      if (date != null) {
        final weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
        final months = [
          '',
          'TH 1',
          'TH 2',
          'TH 3',
          'TH 4',
          'TH 5',
          'TH 6',
          'TH 7',
          'TH 8',
          'TH 9',
          'TH 10',
          'TH 11',
          'TH 12',
        ];
        dateLabel =
            '${weekdays[date.weekday % 7]}, ${date.day} ${months[date.month]}';
      }
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'SẮP TỚI',
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Class name
                    Text(
                      classModel.displayName,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Student count and date
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 16,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${classModel.studentCount} Học sinh',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              dateLabel.toUpperCase(),
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              classModel.nextScheduleTime ?? '—',
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  classModel.isOnline
                      ? Icons.videocam_outlined
                      : Icons.science_outlined,
                  color: cs.primary,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradingProgressCard extends StatelessWidget {
  const _GradingProgressCard({
    required this.title,
    required this.assignmentName,
    required this.progress,
    required this.onContinue,
  });

  final String title;
  final String assignmentName;
  final double progress;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A5F),
            Color(0xFF2C5282),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: tt.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                Icons.assignment_outlined,
                color: Colors.white.withValues(alpha: 0.6),
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                assignmentName,
                style: tt.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: tt.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: cs.primary,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Tiếp tục chấm bài'),
            ),
          ),
        ],
      ),
    );
  }
}
