import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/bloc/lesson_detail/lesson_detail_cubit.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/features/student/presentation/screens/lesson_detail_screen.dart';
import 'package:study/theme/app_colors.dart';

// ── Mock assignment model for richer UI ─────────────────────

enum AssignmentStatus { pending, submitted, graded }

class MockAssignment {
  const MockAssignment({
    required this.id,
    required this.title,
    required this.courseName,
    required this.courseTag,
    required this.deadline,
    required this.status,
    this.progress,
    this.score,
    this.isUrgent = false,
  });

  final String id;
  final String title;
  final String courseName;
  final String courseTag;
  final String deadline;
  final AssignmentStatus status;
  final double? progress;
  final double? score;
  final bool isUrgent;
}

List<MockAssignment> _buildMockAssignments() => const [
      MockAssignment(
        id: 'a1',
        title: 'Bai tap 1: Xay dung REST API voi Go Fiber',
        courseName: 'Lap trinh Go Fiber - Khoa K12',
        courseTag: 'Go Fiber',
        deadline: '23:59, 15/10',
        status: AssignmentStatus.pending,
        isUrgent: true,
      ),
      MockAssignment(
        id: 'a2',
        title: 'Lab 04: Quan ly State trong Next.js',
        courseName: 'Next.js Advanced',
        courseTag: 'Next.js',
        deadline: '12:00, 20/10',
        status: AssignmentStatus.pending,
        progress: 0.6,
      ),
      MockAssignment(
        id: 'a3',
        title: 'Assignment 02: Phan tich du lieu voi Pandas',
        courseName: 'Python for Data Science',
        courseTag: 'Python',
        deadline: '23:59, 25/10',
        status: AssignmentStatus.pending,
      ),
      MockAssignment(
        id: 'a4',
        title: 'Bai tap 3: Component Lifecycle & Hooks',
        courseName: 'Next.js Advanced',
        courseTag: 'Next.js',
        deadline: '23:59, 10/10',
        status: AssignmentStatus.submitted,
      ),
      MockAssignment(
        id: 'a5',
        title: 'Lab 02: CRUD voi Go Fiber & PostgreSQL',
        courseName: 'Lap trinh Go Fiber - Khoa K12',
        courseTag: 'Go Fiber',
        deadline: '23:59, 05/10',
        status: AssignmentStatus.graded,
        score: 8.5,
      ),
      MockAssignment(
        id: 'a6',
        title: 'Assignment 01: Python co ban & NumPy',
        courseName: 'Python for Data Science',
        courseTag: 'Python',
        deadline: '23:59, 01/10',
        status: AssignmentStatus.graded,
        score: 9.5,
      ),
      MockAssignment(
        id: 'a7',
        title: 'Bai tap 2: Middleware & Authentication',
        courseName: 'Next.js Advanced',
        courseTag: 'Next.js',
        deadline: '23:59, 28/09',
        status: AssignmentStatus.graded,
        score: 7.0,
      ),
    ];

// ── Main Tab ────────────────────────────────────────────────

class LearningAssignmentsTab extends StatefulWidget {
  const LearningAssignmentsTab({super.key});

  @override
  State<LearningAssignmentsTab> createState() =>
      _LearningAssignmentsTabState();
}

class _LearningAssignmentsTabState extends State<LearningAssignmentsTab> {
  final _assignments = _buildMockAssignments();
  String _courseFilter = 'all';
  int _statusTab = 0;

  List<String> get _courseNames =>
      _assignments.map((a) => a.courseTag).toSet().toList();

  List<MockAssignment> get _filtered {
    var list = _assignments;
    if (_courseFilter != 'all') {
      list = list.where((a) => a.courseTag == _courseFilter).toList();
    }
    switch (_statusTab) {
      case 0:
        return list
            .where((a) => a.status == AssignmentStatus.pending)
            .toList();
      case 1:
        return list
            .where((a) => a.status == AssignmentStatus.submitted)
            .toList();
      case 2:
        return list
            .where((a) => a.status == AssignmentStatus.graded)
            .toList();
      default:
        return list;
    }
  }

  int get _pendingCount =>
      _assignments.where((a) => a.status == AssignmentStatus.pending).length;
  int get _gradedCount =>
      _assignments.where((a) => a.status == AssignmentStatus.graded).length;

  double get _completionRate {
    if (_assignments.isEmpty) return 0;
    final done = _assignments
        .where((a) => a.status != AssignmentStatus.pending)
        .length;
    return done / _assignments.length;
  }

  double get _avgScore {
    final scored =
        _assignments.where((a) => a.score != null).toList();
    if (scored.isEmpty) return 0;
    return scored.map((a) => a.score!).reduce((a, b) => a + b) /
        scored.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CourseFilterRow(
          courses: _courseNames,
          selected: _courseFilter,
          onSelected: (f) => setState(() => _courseFilter = f),
        ),
        const SizedBox(height: AppSpacing.md),
        _StatusTabRow(
          currentIndex: _statusTab,
          onChanged: (i) => setState(() => _statusTab = i),
          pendingCount: _pendingCount,
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: _filtered.isEmpty
              ? const _EmptyAssignments()
              : _AssignmentsList(
                  assignments: _filtered,
                  completionRate: _completionRate,
                  avgScore: _avgScore,
                  gradedCount: _gradedCount,
                  showStats: _statusTab == 0,
                ),
        ),
      ],
    );
  }
}

// ── Course filter chips ─────────────────────────────────────

class _CourseFilterRow extends StatelessWidget {
  const _CourseFilterRow({
    required this.courses,
    required this.selected,
    required this.onSelected,
  });
  final List<String> courses;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final all = ['all', ...courses];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.screenMargin,
        ),
        itemCount: all.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final filter = all[index];
          final isSelected = selected == filter;
          final label = filter == 'all' ? 'Tat ca' : filter;

          return GestureDetector(
            onTap: () => onSelected(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : cs.surfaceContainerLowest,
                borderRadius: AppRadius.borderXxl,
                border: isSelected
                    ? null
                    : Border.all(color: cs.outline),
              ),
              child: Text(
                label,
                style: tt.labelMedium?.copyWith(
                  color: isSelected ? cs.onPrimary : cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Status tabs (Chưa nộp / Đã nộp / Đã chấm) ────────────

class _StatusTabRow extends StatelessWidget {
  const _StatusTabRow({
    required this.currentIndex,
    required this.onChanged,
    required this.pendingCount,
  });
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final int pendingCount;

  static const _labels = ['Chua nop', 'Da nop', 'Da cham'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.screenMargin,
      ),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final isSelected = currentIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? cs.primary : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _labels[i],
                  style: tt.labelLarge?.copyWith(
                    color: isSelected ? cs.primary : cs.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Assignments list with stats footer ──────────────────────

class _AssignmentsList extends StatelessWidget {
  const _AssignmentsList({
    required this.assignments,
    required this.completionRate,
    required this.avgScore,
    required this.gradedCount,
    required this.showStats,
  });
  final List<MockAssignment> assignments;
  final double completionRate;
  final double avgScore;
  final int gradedCount;
  final bool showStats;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        AppLayout.screenMargin,
        AppSpacing.sm,
        AppLayout.screenMargin,
        AppSpacing.massive,
      ),
      itemCount: assignments.length + (showStats ? 1 : 0),
      itemBuilder: (context, index) {
        if (showStats && index == assignments.length) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: _StatsFooter(
              completionRate: completionRate,
              avgScore: avgScore,
              gradedCount: gradedCount,
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _AssignmentCard(assignment: assignments[index]),
        );
      },
    );
  }
}

// ── Assignment card ─────────────────────────────────────────

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.assignment});
  final MockAssignment assignment;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        padding: AppLayout.cardPadding,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderXl,
          border: Border.all(
            color: assignment.isUrgent
                ? cs.error.withValues(alpha: 0.3)
                : cs.outline,
          ),
          boxShadow: cs.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusBadge(assignment: assignment),
                const Spacer(),
                Icon(Icons.more_vert_rounded,
                    size: AppIconSize.md, color: cs.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              assignment.title,
              style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(Icons.school_outlined,
                    size: AppIconSize.xs, color: cs.onSurfaceVariant),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    assignment.courseName,
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (assignment.progress != null) ...[
              _ProgressRow(progress: assignment.progress!),
              const SizedBox(height: AppSpacing.md),
            ],
            Row(
              children: [
                _DeadlineChip(
                  deadline: assignment.deadline,
                  isUrgent: assignment.isUrgent,
                ),
                const Spacer(),
                _ActionButton(assignment: assignment),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    final repository = context.read<StudentRepository>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => LessonDetailCubit(
            repository: repository,
            lessonId: 'l1',
          ),
          child: LessonDetailScreen(
            lessonId: 'l1',
            lessonTitle: assignment.title,
            initialTab: 2,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.assignment});
  final MockAssignment assignment;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final String label;
    final Color bg;
    final Color fg;

    switch (assignment.status) {
      case AssignmentStatus.pending:
        if (assignment.isUrgent) {
          label = 'SAP HET HAN';
          bg = cs.error;
          fg = cs.onError;
        } else if (assignment.progress != null) {
          label = 'DANG THUC HIEN';
          bg = cs.tertiary;
          fg = cs.onTertiary;
        } else {
          label = 'MOI GIAO';
          bg = cs.primaryContainer;
          fg = cs.onPrimaryContainer;
        }
      case AssignmentStatus.submitted:
        label = 'DA NOP';
        bg = cs.secondaryContainer;
        fg = cs.onSecondaryContainer;
      case AssignmentStatus.graded:
        label = 'DA CHAM';
        bg = cs.secondary;
        fg = cs.onSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.borderXs,
      ),
      child: Text(
        label,
        style: tt.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _DeadlineChip extends StatelessWidget {
  const _DeadlineChip({required this.deadline, this.isUrgent = false});
  final String deadline;
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = isUrgent ? cs.error : cs.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isUrgent ? Icons.warning_amber_rounded : Icons.event_outlined,
          size: AppIconSize.sm,
          color: color,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'HAN CHOT',
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          deadline,
          style: tt.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            'HAN CHOT',
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ),
        Text(
          '${(progress * 100).toInt()}%',
          style: tt.labelSmall?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 80,
          height: 6,
          child: ClipRRect(
            borderRadius: AppRadius.borderXs,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: cs.outline,
              valueColor: AlwaysStoppedAnimation(cs.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.assignment});
  final MockAssignment assignment;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    switch (assignment.status) {
      case AssignmentStatus.pending:
        if (assignment.isUrgent) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: cs.gradientPrimary,
              borderRadius: AppRadius.borderXxl,
              boxShadow: cs.shadowPrimary,
            ),
            child: Text(
              'Nop bai',
              style: tt.labelMedium?.copyWith(
                color: cs.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      case AssignmentStatus.submitted:
        return const SizedBox.shrink();
      case AssignmentStatus.graded:
        if (assignment.score != null) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: AppRadius.borderXxl,
              border: Border.all(color: cs.outline),
            ),
            child: Text(
              'Xem chi tiet',
              style: tt.labelMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
    }
  }
}

// ── Stats footer ────────────────────────────────────────────

class _StatsFooter extends StatelessWidget {
  const _StatsFooter({
    required this.completionRate,
    required this.avgScore,
    required this.gradedCount,
  });
  final double completionRate;
  final double avgScore;
  final int gradedCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: AppLayout.cardPadding,
            decoration: BoxDecoration(
              gradient: cs.gradientPrimary,
              borderRadius: AppRadius.borderXl,
              boxShadow: cs.shadowPrimary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.pie_chart_rounded,
                    color: cs.onPrimary.withValues(alpha: 0.7),
                    size: AppIconSize.lg),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${(completionRate * 100).toInt()}%',
                  style: tt.headlineMedium?.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'TI LE HOAN THANH',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onPrimary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppLayout.gutter),
        Expanded(
          child: Container(
            padding: AppLayout.cardPadding,
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: AppRadius.borderXl,
              border: Border.all(color: cs.outline),
              boxShadow: cs.shadowCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'DA CHAM',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: cs.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded,
                          size: AppIconSize.xs, color: cs.onSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$gradedCount',
                  style: tt.headlineMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'DIEM TB',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  avgScore.toStringAsFixed(1),
                  style: tt.titleLarge?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Empty state ─────────────────────────────────────────────

class _EmptyAssignments extends StatelessWidget {
  const _EmptyAssignments();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: cs.gradientSurfacePrimary,
              shape: BoxShape.circle,
              border: Border.all(color: cs.outline, width: 1.5),
            ),
            child: Icon(
              Icons.assignment_turned_in_rounded,
              size: AppIconSize.hero,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Khong co bai tap nao',
            style: tt.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Khong co bai tap trong muc nay',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
