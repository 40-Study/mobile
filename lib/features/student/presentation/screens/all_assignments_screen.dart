import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/bloc/lesson_detail/lesson_detail_cubit.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/features/student/presentation/screens/lesson_detail_screen.dart';
import 'package:study/theme/app_colors.dart';

class AllAssignmentsScreen extends StatelessWidget {
  const AllAssignmentsScreen({super.key, required this.enrollments});

  final List<EnrollmentModel> enrollments;

  List<EnrollmentModel> get _pending =>
      enrollments.where((e) => e.isActive && e.progress < 100).toList();

  List<EnrollmentModel> get _done =>
      enrollments.where((e) => e.isCompleted || e.progress >= 100).toList();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bai tap can hoan thien',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: enrollments.isEmpty
          ? _EmptyAssignments(cs: cs, tt: tt)
          : ListView(
              padding: EdgeInsets.fromLTRB(
                AppLayout.screenMargin,
                AppSpacing.lg,
                AppLayout.screenMargin,
                AppSpacing.massive,
              ),
              children: [
                _SummaryHeader(
                  pending: _pending.length,
                  done: _done.length,
                ),
                SizedBox(height: AppSpacing.xxl),
                if (_pending.isNotEmpty) ...[
                  _SectionLabel(
                    label: 'CAN NOP',
                    count: _pending.length,
                    color: cs.error,
                  ),
                  SizedBox(height: AppSpacing.md),
                  ..._pending.asMap().entries.map((e) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: _AssignmentDetailCard(
                          enrollment: e.value,
                          index: e.key,
                          onTap: () => _openHomework(context, e.value),
                        ),
                      )),
                  SizedBox(height: AppSpacing.xl),
                ],
                if (_done.isNotEmpty) ...[
                  _SectionLabel(
                    label: 'DA HOAN THANH',
                    count: _done.length,
                    color: cs.tertiary,
                  ),
                  SizedBox(height: AppSpacing.md),
                  ..._done.asMap().entries.map((e) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: _AssignmentDetailCard(
                          enrollment: e.value,
                          index: e.key,
                          isCompleted: true,
                          onTap: () => _openHomework(context, e.value),
                        ),
                      )),
                ],
              ],
            ),
    );
  }

  void _openHomework(BuildContext context, EnrollmentModel enrollment) {
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
            lessonTitle: enrollment.nextLesson ?? enrollment.courseName ?? '',
            initialTab: 2,
          ),
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.pending, required this.done});

  final int pending;
  final int done;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.secondary,
            cs.secondary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.borderXl,
        boxShadow: [
          BoxShadow(
            color: cs.secondary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_rounded,
                  color: cs.onSecondary, size: AppIconSize.md),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Tong quan bai tap',
                style: tt.titleSmall?.copyWith(
                  color: cs.onSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _StatItem(
                value: '$pending',
                label: 'Can nop',
                color: cs.onSecondary,
              ),
              SizedBox(width: AppSpacing.xxxl),
              _StatItem(
                value: '$done',
                label: 'Da xong',
                color: cs.onSecondary,
              ),
              SizedBox(width: AppSpacing.xxxl),
              _StatItem(
                value: '${pending + done}',
                label: 'Tong',
                color: cs.onSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.75),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 4,
          height: AppSpacing.lg,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: tt.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: color,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: AppRadius.borderXs,
          ),
          child: Text(
            '$count',
            style: tt.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _AssignmentDetailCard extends StatelessWidget {
  const _AssignmentDetailCard({
    required this.enrollment,
    required this.index,
    this.isCompleted = false,
    this.onTap,
  });

  final EnrollmentModel enrollment;
  final int index;
  final bool isCompleted;
  final VoidCallback? onTap;

  int get _daysLeft {
    if (isCompleted) return 0;
    return [2, 1, 5, 3, 7][index % 5];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final urgencyColor =
        _daysLeft <= 1 ? cs.error : _daysLeft <= 3 ? cs.secondary : cs.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppLayout.cardPadding,
        decoration: BoxDecoration(
          color: isCompleted
              ? cs.surfaceContainerHigh
              : cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: isCompleted
                ? cs.outlineVariant.withValues(alpha: 0.1)
                : urgencyColor.withValues(alpha: 0.15),
          ),
          boxShadow: isCompleted ? null : cs.shadowCard,
        ),
        child: Opacity(
          opacity: isCompleted ? 0.55 : 1.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppIconSize.avatar,
                height: AppIconSize.avatar,
                decoration: BoxDecoration(
                  gradient: isCompleted
                      ? null
                      : LinearGradient(
                          colors: [
                            urgencyColor.withValues(alpha: 0.15),
                            urgencyColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: isCompleted
                      ? cs.surfaceContainerHighest
                      : null,
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.assignment_outlined,
                  color: isCompleted ? cs.tertiary : urgencyColor,
                  size: AppIconSize.lg,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enrollment.courseName ?? 'Khoa hoc',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      enrollment.nextLesson?.isNotEmpty == true
                          ? enrollment.nextLesson!
                          : enrollment.courseName ?? '',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    if (isCompleted)
                      Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: AppIconSize.xs, color: cs.tertiary),
                          SizedBox(width: AppSpacing.xxs),
                          Text(
                            'Da nop',
                            style: tt.labelSmall?.copyWith(
                              color: cs.tertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: urgencyColor.withValues(alpha: 0.1),
                              borderRadius: AppRadius.borderXs,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.schedule_rounded,
                                    size: AppIconSize.xs,
                                    color: urgencyColor),
                                SizedBox(width: AppSpacing.xxs),
                                Text(
                                  'Con $_daysLeft ngay',
                                  style: tt.labelSmall?.copyWith(
                                    color: urgencyColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${enrollment.completedLessons}/${enrollment.totalLessons} bai',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (!isCompleted)
                Padding(
                  padding: EdgeInsets.only(left: AppSpacing.sm),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: AppIconSize.sm,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyAssignments extends StatelessWidget {
  const _EmptyAssignments({required this.cs, required this.tt});

  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: cs.surfaceTintedPrimary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_turned_in_rounded,
              size: AppIconSize.hero,
              color: cs.tertiary.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Text(
            'Khong co bai tap nao',
            style: tt.titleMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Ban da hoan thanh tat ca bai tap!',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
