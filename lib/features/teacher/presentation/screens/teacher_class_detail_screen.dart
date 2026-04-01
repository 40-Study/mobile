import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/teacher/bloc/classes/teacher_class_detail_cubit.dart';
import 'package:study/features/teacher/data/models/models.dart';
import 'package:study/features/teacher/presentation/widgets/widgets.dart';
import 'package:study/features/weather/presentation/widgets/weather_background_wrapper.dart';

class TeacherClassDetailScreen extends StatefulWidget {
  const TeacherClassDetailScreen({
    super.key,
    required this.classId,
  });

  final String classId;

  @override
  State<TeacherClassDetailScreen> createState() =>
      _TeacherClassDetailScreenState();
}

class _TeacherClassDetailScreenState extends State<TeacherClassDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherClassDetailCubit>().loadClassDetail(widget.classId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return WeatherBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<TeacherClassDetailCubit, TeacherClassDetailState>(
          builder: (context, state) {
            return switch (state) {
              TeacherClassDetailInitial() ||
              TeacherClassDetailLoading() =>
                const Center(child: CircularProgressIndicator()),
              TeacherClassDetailLoaded(:final classModel) => _ClassDetailBody(
                  classModel: classModel,
                  tabController: _tabController,
                  classId: widget.classId,
                ),
              TeacherClassDetailFailure(:final message) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: cs.error),
                      const SizedBox(height: 16),
                      Text(message),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => context
                            .read<TeacherClassDetailCubit>()
                            .loadClassDetail(widget.classId),
                        child: const Text('Thử lại'),
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

class _ClassDetailBody extends StatelessWidget {
  const _ClassDetailBody({
    required this.classModel,
    required this.tabController,
    required this.classId,
  });

  final ClassModel classModel;
  final TabController tabController;
  final String classId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Header
        _ClassHeader(classModel: classModel),
        // TabBar
        Container(
          color: cs.surface,
          child: TabBar(
            controller: tabController,
            labelColor: cs.primary,
            unselectedLabelColor: cs.onSurfaceVariant,
            indicatorColor: cs.primary,
            indicatorWeight: 3,
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            tabs: const [
              Tab(text: 'Học viên'),
              Tab(text: 'Bài tập'),
              Tab(text: 'Bảng điểm'),
              Tab(text: 'Tài liệu'),
            ],
          ),
        ),
        // TabBarView
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _StudentsTab(classId: classId),
              _AssignmentsTab(classId: classId, classModel: classModel),
              _GradebookTab(classId: classId, classModel: classModel),
              _DocumentsTab(classId: classId),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Header
// =============================================================================

class _ClassHeader extends StatelessWidget {
  const _ClassHeader({required this.classModel});

  final ClassModel classModel;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppLayout.screenMargin,
                0,
                AppLayout.screenMargin,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges row
                  Row(
                    children: [
                      _HeaderBadge(
                        label: classModel.status == 'active'
                            ? 'ĐANG HỌC'
                            : classModel.status.toUpperCase(),
                        color: Colors.white,
                        bgColor: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      if (classModel.nextScheduleTime != null)
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              '${classModel.nextScheduleDate ?? ""} (${classModel.nextScheduleTime})',
                              style: tt.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Title
                  Text(
                    classModel.displayName,
                    style: tt.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mã lớp: ${classModel.id} • ${classModel.studentCount} Học viên',
                    style: tt.bodySmall?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tiến độ khóa học',
                            style: tt.bodySmall?.copyWith(color: Colors.white70),
                          ),
                          Text(
                            'Buổi 15/20',
                            style: tt.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 15 / 20,
                          backgroundColor: Colors.white24,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Quản lý lớp'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6366F1),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon:
                              const Icon(Icons.more_vert, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({
    required this.label,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

// =============================================================================
// Students Tab
// =============================================================================

class _StudentsTab extends StatelessWidget {
  const _StudentsTab({required this.classId});

  final String classId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TeacherClassDetailCubit, TeacherClassDetailState,
        ({List<StudentModel> students, bool isLoading})>(
      selector: (state) {
        if (state is TeacherClassDetailLoaded) {
          return (students: state.students, isLoading: state.isLoadingStudents);
        }
        return (students: <StudentModel>[], isLoading: true);
      },
      builder: (context, data) {
        if (data.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (data.students.isEmpty) {
          return _EmptyState(
            icon: Icons.people_outline,
            title: 'Chưa có học viên',
            subtitle: 'Thêm học viên vào lớp học này',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppLayout.screenMargin),
          itemCount: data.students.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final student = data.students[index];
            return _SimpleStudentCard(
              student: student,
              onTap: () {
                StudentDetailBottomSheet.show(
                  context,
                  classId: classId,
                  studentId: student.id,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SimpleStudentCard extends StatelessWidget {
  const _SimpleStudentCard({required this.student, this.onTap});

  final StudentModel student;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderMd,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: cs.primaryContainer,
                  backgroundImage: student.avatarUrl != null
                      ? NetworkImage(student.avatarUrl!)
                      : null,
                  child: student.avatarUrl == null
                      ? Text(
                          student.displayName.isNotEmpty
                              ? student.displayName[0].toUpperCase()
                              : 'S',
                          style: tt.titleMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.displayName,
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        student.displayCode,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Assignments Tab
// =============================================================================

class _AssignmentsTab extends StatelessWidget {
  const _AssignmentsTab({required this.classId, required this.classModel});

  final String classId;
  final ClassModel classModel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocSelector<TeacherClassDetailCubit, TeacherClassDetailState,
        ({List<ClassAssignmentModel> assignments, bool isLoading})>(
      selector: (state) {
        if (state is TeacherClassDetailLoaded) {
          return (
            assignments: state.assignments,
            isLoading: state.isLoadingAssignments
          );
        }
        return (assignments: <ClassAssignmentModel>[], isLoading: true);
      },
      builder: (context, data) {
        if (data.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeCount = data.assignments
            .where((a) => a.status == ClassAssignmentStatus.active)
            .length;

        return ListView(
          padding: const EdgeInsets.all(AppLayout.screenMargin),
          children: [
            // Hero card
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, cs.primary.withValues(alpha: 0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.borderLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quản lý bài tập',
                    style: tt.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      _HeroStat(
                        label: 'TỔNG SỐ\nSINH VIÊN',
                        value: '${classModel.studentCount}',
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      _HeroStat(
                        label: 'BÀI TẬP\nĐANG MỞ',
                        value: '$activeCount'.padLeft(2, '0'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Header
            Row(
              children: [
                Icon(Icons.assignment_outlined, size: 20, color: cs.onSurface),
                const SizedBox(width: 8),
                Text(
                  'Danh sách bài tập',
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tạo bài mới'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Assignment list
            if (data.assignments.isEmpty)
              _EmptyState(
                icon: Icons.assignment_outlined,
                title: 'Chưa có bài tập',
                subtitle: 'Tạo bài tập cho học viên',
              )
            else
              ...data.assignments.map(
                (assignment) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _AssignmentCard(assignment: assignment),
                ),
              ),
            const SizedBox(height: AppSpacing.massive),
          ],
        );
      },
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: Colors.white70,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: tt.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.assignment});

  final ClassAssignmentModel assignment;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isOverdue = assignment.isOverdue;
    final isDraft = assignment.status == ClassAssignmentStatus.draft;

    Color iconBgColor;
    Color iconColor;
    if (isDraft) {
      iconBgColor = Colors.grey.withValues(alpha: 0.1);
      iconColor = Colors.grey;
    } else if (isOverdue) {
      iconBgColor = Colors.red.withValues(alpha: 0.1);
      iconColor = Colors.red;
    } else {
      iconBgColor = cs.primary.withValues(alpha: 0.1);
      iconColor = cs.primary;
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: isOverdue
              ? cs.error.withValues(alpha: 0.3)
              : cs.outlineVariant.withValues(alpha: 0.2),
          width: isOverdue ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: AppRadius.borderLg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.code, size: 22, color: iconColor),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignment.title,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: cs.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Hạn nộp: 23:59 - ${assignment.dueDate}',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Status badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOverdue ? Icons.warning : Icons.schedule,
                            size: 12,
                            color: isOverdue ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOverdue ? 'Đã hết hạn' : 'Đang diễn ra',
                            style: tt.labelSmall?.copyWith(
                              color: isOverdue ? Colors.red : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // Submission count and action
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${assignment.submittedCount}/${assignment.totalStudents}',
                          style: tt.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ĐÃ NỘP',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.grading, size: 18),
                      label: const Text('Chấm bài'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Gradebook Tab
// =============================================================================

class _GradebookTab extends StatelessWidget {
  const _GradebookTab({required this.classId, required this.classModel});

  final String classId;
  final ClassModel classModel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocSelector<TeacherClassDetailCubit, TeacherClassDetailState,
        ({List<StudentModel> students, bool isLoading})>(
      selector: (state) {
        if (state is TeacherClassDetailLoaded) {
          return (students: state.students, isLoading: state.isLoadingStudents);
        }
        return (students: <StudentModel>[], isLoading: true);
      },
      builder: (context, data) {
        if (data.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(AppLayout.screenMargin),
          children: [
            // Grade table
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: AppRadius.borderLg,
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(flex: 3, child: Text('HỌC VIÊN')),
                        Expanded(
                          child: Text(
                            'BÀI TẬP\n1',
                            style: tt.labelSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'BÀI TẬP\n2',
                            style: tt.labelSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Rows
                  ...data.students.map((student) {
                    final score1 = (student.progress / 10).toStringAsFixed(1);
                    final score2 = ((student.progress + 10) / 10)
                        .clamp(0, 10)
                        .toStringAsFixed(1);
                    return _GradeRow(
                      name: student.displayName,
                      code: student.displayCode,
                      scores: [score1, score2],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.massive),
          ],
        );
      },
    );
  }
}

class _GradeRow extends StatelessWidget {
  const _GradeRow({
    required this.name,
    required this.code,
    required this.scores,
  });

  final String name;
  final String code;
  final List<String> scores;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: cs.primaryContainer,
            child: Text(
              name.substring(0, 2).toUpperCase(),
              style: tt.labelMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  code,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          ...scores.map((score) {
            final numScore = double.tryParse(score) ?? 0;
            final color = numScore < 5 ? Colors.red : cs.onSurface;
            return Expanded(
              child: Text(
                score,
                style: tt.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }),
        ],
      ),
    );
  }
}

// =============================================================================
// Documents Tab
// =============================================================================

class _DocumentsTab extends StatelessWidget {
  const _DocumentsTab({required this.classId});

  final String classId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TeacherClassDetailCubit, TeacherClassDetailState,
        ({List<ClassDocumentModel> documents, bool isLoading})>(
      selector: (state) {
        if (state is TeacherClassDetailLoaded) {
          return (
            documents: state.documents,
            isLoading: state.isLoadingDocuments
          );
        }
        return (documents: <ClassDocumentModel>[], isLoading: true);
      },
      builder: (context, data) {
        if (data.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;

        return ListView(
          padding: const EdgeInsets.all(AppLayout.screenMargin),
          children: [
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _DocFilterChip(label: 'Tất cả', selected: true),
                  const SizedBox(width: 8),
                  _DocFilterChip(label: 'Bài giảng'),
                  const SizedBox(width: 8),
                  _DocFilterChip(label: 'Tham khảo'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Document list
            if (data.documents.isEmpty)
              _EmptyState(
                icon: Icons.folder_outlined,
                title: 'Chưa có tài liệu',
                subtitle: 'Tải lên tài liệu cho học viên',
              )
            else
              ...data.documents.map(
                (doc) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _DocumentCard(document: doc),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            // Upload zone
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.05),
                borderRadius: AppRadius.borderLg,
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      size: 32,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Kéo và thả tệp tin vào đây',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hoặc nhấn để chọn từ máy tính của bạn (Tối đa 50MB)',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.massive),
          ],
        );
      },
    );
  }
}

class _DocFilterChip extends StatelessWidget {
  const _DocFilterChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? cs.primary : cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: selected ? null : Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        label,
        style: tt.labelMedium?.copyWith(
          color: selected ? Colors.white : cs.onSurfaceVariant,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document});

  final ClassDocumentModel document;

  IconData _getIcon() {
    return switch (document.type) {
      DocumentType.pdf => Icons.picture_as_pdf,
      DocumentType.doc => Icons.description,
      DocumentType.ppt => Icons.slideshow,
      DocumentType.xls => Icons.table_chart,
      DocumentType.image => Icons.image,
      DocumentType.video => Icons.video_library,
      DocumentType.link => Icons.link,
      DocumentType.other => Icons.insert_drive_file,
    };
  }

  Color _getColor() {
    return switch (document.type) {
      DocumentType.pdf => Colors.red,
      DocumentType.doc => Colors.blue,
      DocumentType.ppt => Colors.orange,
      DocumentType.xls => Colors.green,
      DocumentType.image => Colors.purple,
      DocumentType.video => Colors.pink,
      DocumentType.link => Colors.teal,
      DocumentType.other => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = _getColor();

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: AppRadius.borderMd,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_getIcon(), size: 24, color: color),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.title,
                        style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${document.type.label} • ${document.fileSize ?? "N/A"} • Tải lên: ${document.uploadedAt ?? "N/A"}',
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.visibility_outlined,
                      size: 20, color: cs.onSurfaceVariant),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.download_outlined,
                      size: 20, color: cs.onSurfaceVariant),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_vert,
                      size: 20, color: cs.onSurfaceVariant),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Empty State
// =============================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            title,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
