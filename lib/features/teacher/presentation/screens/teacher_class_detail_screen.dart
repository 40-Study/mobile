import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/teacher/bloc/classes/teacher_class_detail_cubit.dart';
import 'package:study/features/teacher/data/models/models.dart';
import 'package:study/features/teacher/presentation/widgets/widgets.dart';

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
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    Tab(text: 'Hoc vien'),
    Tab(text: 'Giang vien'),
    Tab(text: 'Lich hoc'),
    Tab(text: 'Diem danh'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    context.read<TeacherClassDetailCubit>().loadClassDetail(widget.classId);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      context.read<TeacherClassDetailCubit>().changeTab(_tabController.index);

      // Load attendance data when switching to attendance tab
      if (_tabController.index == 3) {
        context.read<TeacherClassDetailCubit>().loadAttendances(widget.classId);
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: BlocBuilder<TeacherClassDetailCubit, TeacherClassDetailState>(
        builder: (context, state) {
          return switch (state) {
            TeacherClassDetailInitial() ||
            TeacherClassDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            TeacherClassDetailLoaded(:final classModel) => NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    _buildSliverAppBar(context, classModel, innerBoxIsScrolled),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _StudentsTab(classId: widget.classId),
                    _TeachersTab(classId: widget.classId),
                    _SchedulesTab(classId: widget.classId),
                    _AttendanceTab(classId: widget.classId),
                  ],
                ),
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

  SliverAppBar _buildSliverAppBar(
    BuildContext context,
    ClassModel classModel,
    bool innerBoxIsScrolled,
  ) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      floating: false,
      forceElevated: innerBoxIsScrolled,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, cs.primary.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classModel.displayName,
                    style: tt.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (classModel.courseName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      classModel.courseName!,
                      style: tt.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      _InfoBadge(
                        icon: Icons.people,
                        label:
                            '${classModel.studentCount}/${classModel.maxStudents} hoc vien',
                      ),
                      const SizedBox(width: 16),
                      _InfoBadge(
                        icon: Icons.calendar_today,
                        label: classModel.dateRange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/teacher/classes/edit',
              arguments: classModel,
            );
          },
          icon: const Icon(Icons.edit, color: Colors.white),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'attendance':
                Navigator.pushNamed(
                  context,
                  '/teacher/classes/attendance',
                  arguments: classModel.id,
                );
              case 'delete':
                _showDeleteDialog(context, classModel);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'attendance',
              child: ListTile(
                leading: Icon(Icons.fact_check_outlined),
                title: Text('Diem danh'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: cs.error),
                title: Text('Xoa lop', style: TextStyle(color: cs.error)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: _tabs,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
        indicatorColor: Colors.white,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ClassModel classModel) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xac nhan xoa'),
        content: Text(
          'Ban co chac chan muon xoa lop "${classModel.displayName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
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
        _StudentsData>(
      selector: (state) {
        if (state is TeacherClassDetailLoaded) {
          return _StudentsData(
            students: state.students,
            isLoading: state.isLoadingStudents,
          );
        }
        return const _StudentsData(students: [], isLoading: true);
      },
      builder: (context, data) {
        if (data.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (data.students.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.people_outline,
            title: 'Chua co hoc vien',
            subtitle: 'Them hoc vien vao lop hoc nay',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.students.length,
          itemBuilder: (context, index) {
            final student = data.students[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: StudentCard(
                student: student,
                onTap: () {
                  // Navigate to student detail
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _StudentsData {
  const _StudentsData({
    required this.students,
    required this.isLoading,
  });

  final List<StudentModel> students;
  final bool isLoading;
}

// =============================================================================
// Teachers Tab
// =============================================================================

class _TeachersTab extends StatelessWidget {
  const _TeachersTab({required this.classId});

  final String classId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocSelector<TeacherClassDetailCubit, TeacherClassDetailState,
        _TeachersData>(
      selector: (state) {
        if (state is TeacherClassDetailLoaded) {
          return _TeachersData(
            teachers: state.teachers,
            isLoading: state.isLoadingTeachers,
          );
        }
        return const _TeachersData(teachers: [], isLoading: true);
      },
      builder: (context, data) {
        if (data.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (data.teachers.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.person_outline,
            title: 'Chua co giang vien',
            subtitle: 'Them giang vien vao lop hoc nay',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.teachers.length,
          itemBuilder: (context, index) {
            final teacher = data.teachers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.primaryContainer,
                  backgroundImage: teacher.avatarUrl != null
                      ? NetworkImage(teacher.avatarUrl!)
                      : null,
                  child: teacher.avatarUrl == null
                      ? Text(
                          teacher.displayName.substring(0, 1).toUpperCase(),
                          style: TextStyle(color: cs.primary),
                        )
                      : null,
                ),
                title: Text(teacher.displayName),
                subtitle: Text(teacher.roleDisplayName),
                trailing: teacher.isOwner
                    ? Chip(
                        label: const Text('Chinh'),
                        backgroundColor: cs.primaryContainer,
                        labelStyle: TextStyle(color: cs.primary, fontSize: 12),
                      )
                    : IconButton(
                        icon: Icon(Icons.remove_circle_outline,
                            color: cs.error),
                        onPressed: () {
                          context
                              .read<TeacherClassDetailCubit>()
                              .removeTeacher(classId, teacher.id);
                        },
                      ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TeachersData {
  const _TeachersData({
    required this.teachers,
    required this.isLoading,
  });

  final List<ClassTeacherModel> teachers;
  final bool isLoading;
}

// =============================================================================
// Schedules Tab
// =============================================================================

class _SchedulesTab extends StatelessWidget {
  const _SchedulesTab({required this.classId});

  final String classId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocSelector<TeacherClassDetailCubit, TeacherClassDetailState,
        _SchedulesData>(
      selector: (state) {
        if (state is TeacherClassDetailLoaded) {
          return _SchedulesData(
            schedules: state.schedules,
            isLoading: state.isLoadingSchedules,
          );
        }
        return const _SchedulesData(schedules: [], isLoading: true);
      },
      builder: (context, data) {
        if (data.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (data.schedules.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.calendar_today_outlined,
            title: 'Chua co lich hoc',
            subtitle: 'Them lich hoc cho lop',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.schedules.length,
          itemBuilder: (context, index) {
            final schedule = data.schedules[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'T${schedule.dayOfWeek}',
                      style: tt.titleMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(schedule.dayName),
                subtitle: Text(schedule.timeRange),
                trailing: schedule.room != null
                    ? Chip(
                        avatar: const Icon(Icons.room, size: 16),
                        label: Text(schedule.room!),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}

class _SchedulesData {
  const _SchedulesData({
    required this.schedules,
    required this.isLoading,
  });

  final List<ClassScheduleModel> schedules;
  final bool isLoading;
}

// =============================================================================
// Attendance Tab
// =============================================================================

class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab({required this.classId});

  final String classId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocSelector<TeacherClassDetailCubit, TeacherClassDetailState,
        _AttendanceData>(
      selector: (state) {
        if (state is TeacherClassDetailLoaded) {
          return _AttendanceData(
            attendances: state.attendances,
            isLoading: state.isLoadingAttendances,
          );
        }
        return const _AttendanceData(attendances: [], isLoading: true);
      },
      builder: (context, data) {
        if (data.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (data.attendances.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.fact_check_outlined,
            title: 'Chua co du lieu diem danh',
            subtitle: 'Diem danh hoc vien tai day',
            actionLabel: 'Diem danh',
            onAction: () {
              Navigator.pushNamed(
                context,
                '/teacher/classes/attendance',
                arguments: classId,
              );
            },
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Diem danh hom nay',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/teacher/classes/attendance',
                        arguments: classId,
                      );
                    },
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: const Text('Cap nhat'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: data.attendances.length,
                itemBuilder: (context, index) {
                  final attendance = data.attendances[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: cs.surfaceContainerHighest,
                        backgroundImage: attendance.avatarUrl != null
                            ? NetworkImage(attendance.avatarUrl!)
                            : null,
                        child: attendance.avatarUrl == null
                            ? Text(
                                attendance.displayName
                                    .substring(0, 1)
                                    .toUpperCase(),
                              )
                            : null,
                      ),
                      title: Text(attendance.displayName),
                      subtitle: Text(attendance.displayCode),
                      trailing: _AttendanceStatusChip(
                        status: attendance.attendanceStatus,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AttendanceData {
  const _AttendanceData({
    required this.attendances,
    required this.isLoading,
  });

  final List<AttendanceModel> attendances;
  final bool isLoading;
}

class _AttendanceStatusChip extends StatelessWidget {
  const _AttendanceStatusChip({required this.status});

  final AttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;

    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case AttendanceStatus.present:
        backgroundColor = cs.tertiary.withValues(alpha: 0.1);
        textColor = cs.tertiary;
        label = 'Co mat';
      case AttendanceStatus.absent:
        backgroundColor = cs.error.withValues(alpha: 0.1);
        textColor = cs.error;
        label = 'Vang';
      case AttendanceStatus.late:
        backgroundColor = cs.secondary.withValues(alpha: 0.1);
        textColor = cs.secondary;
        label = 'Tre';
      case AttendanceStatus.excused:
        backgroundColor = cs.primary.withValues(alpha: 0.1);
        textColor = cs.primary;
        label = 'Co phep';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

// =============================================================================
// Shared
// =============================================================================

Widget _buildEmptyState(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final cs = Theme.of(context).colorScheme;
  final tt = Theme.of(context).textTheme;

  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 64, color: cs.onSurfaceVariant),
        const SizedBox(height: 16),
        Text(
          title,
          style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ],
      ],
    ),
  );
}
