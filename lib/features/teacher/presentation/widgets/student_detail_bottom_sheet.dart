import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/teacher/bloc/classes/teacher_class_detail_cubit.dart';
import 'package:study/features/teacher/data/models/student_detail_model.dart';

class StudentDetailBottomSheet extends StatelessWidget {
  const StudentDetailBottomSheet({
    super.key,
    required this.classId,
    required this.studentId,
  });

  final String classId;
  final String studentId;

  static Future<void> show(
    BuildContext context, {
    required String classId,
    required String studentId,
  }) {
    context.read<TeacherClassDetailCubit>().loadStudentDetail(classId, studentId);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<TeacherClassDetailCubit>(),
        child: StudentDetailBottomSheet(
          classId: classId,
          studentId: studentId,
        ),
      ),
    ).then((_) {
      context.read<TeacherClassDetailCubit>().clearStudentDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: BlocSelector<TeacherClassDetailCubit, TeacherClassDetailState,
          _StudentDetailData>(
        selector: (state) {
          if (state is TeacherClassDetailLoaded) {
            return _StudentDetailData(
              detail: state.selectedStudentDetail,
              isLoading: state.isLoadingStudentDetail,
            );
          }
          return const _StudentDetailData(detail: null, isLoading: true);
        },
        builder: (context, data) {
          if (data.isLoading) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (data.detail == null) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: cs.error),
                    const SizedBox(height: 16),
                    const Text('Không tìm thấy thông tin học viên'),
                  ],
                ),
              ),
            );
          }

          return _StudentDetailContent(detail: data.detail!);
        },
      ),
    );
  }
}

class _StudentDetailData {
  const _StudentDetailData({
    required this.detail,
    required this.isLoading,
  });

  final StudentDetailModel? detail;
  final bool isLoading;
}

class _StudentDetailContent extends StatelessWidget {
  const _StudentDetailContent({required this.detail});

  final StudentDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: cs.onSurfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.all(AppLayout.screenMargin),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: cs.primaryContainer,
                backgroundImage: detail.avatarUrl != null
                    ? NetworkImage(detail.avatarUrl!)
                    : null,
                child: detail.avatarUrl == null
                    ? Text(
                        detail.fullName.isNotEmpty
                            ? detail.fullName.substring(0, 1).toUpperCase()
                            : 'S',
                        style: tt.headlineSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.fullName,
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      detail.studentCode,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Expanded(
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  labelColor: cs.primary,
                  unselectedLabelColor: cs.onSurfaceVariant,
                  indicatorColor: cs.primary,
                  labelStyle: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: tt.labelLarge,
                  tabs: const [
                    Tab(text: 'Thông tin'),
                    Tab(text: 'Phụ huynh'),
                    Tab(text: 'Bài tập'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _StudentInfoTab(detail: detail),
                      _ParentInfoTab(parent: detail.parent),
                      _AssignmentsTab(
                        assignments: detail.assignments,
                        attendance: detail.attendanceSummary,
                      ),
                    ],
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

// =============================================================================
// Student Info Tab
// =============================================================================

class _StudentInfoTab extends StatelessWidget {
  const _StudentInfoTab({required this.detail});

  final StudentDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      children: [
        // Progress card
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.3),
            borderRadius: AppRadius.borderLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tiến độ học tập',
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${detail.progress.toInt()}%',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                value: detail.progress / 100,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Info list
        _InfoItem(
          icon: Icons.email_outlined,
          label: 'Email',
          value: detail.email ?? 'Chưa cập nhật',
        ),
        _InfoItem(
          icon: Icons.phone_outlined,
          label: 'Số điện thoại',
          value: detail.phone ?? 'Chưa cập nhật',
        ),
        _InfoItem(
          icon: Icons.cake_outlined,
          label: 'Ngày sinh',
          value: detail.dateOfBirth ?? 'Chưa cập nhật',
        ),
        _InfoItem(
          icon: Icons.location_on_outlined,
          label: 'Địa chỉ',
          value: detail.address ?? 'Chưa cập nhật',
        ),
        _InfoItem(
          icon: Icons.calendar_today_outlined,
          label: 'Ngày đăng ký',
          value: detail.enrolledAt ?? 'Chưa cập nhật',
        ),
        // Attendance summary
        if (detail.attendanceSummary != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Điểm danh',
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _AttendanceChip(
                label: 'Có mặt',
                count: detail.attendanceSummary!.presentCount,
                color: Colors.green,
              ),
              const SizedBox(width: AppSpacing.sm),
              _AttendanceChip(
                label: 'Vắng',
                count: detail.attendanceSummary!.absentCount,
                color: cs.error,
              ),
              const SizedBox(width: AppSpacing.sm),
              _AttendanceChip(
                label: 'Trễ',
                count: detail.attendanceSummary!.lateCount,
                color: cs.tertiary,
              ),
              const SizedBox(width: AppSpacing.sm),
              _AttendanceChip(
                label: 'Có phép',
                count: detail.attendanceSummary!.excusedCount,
                color: cs.primary,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
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
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: tt.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceChip extends StatelessWidget {
  const _AttendanceChip({
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

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: tt.labelSmall?.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Parent Info Tab
// =============================================================================

class _ParentInfoTab extends StatelessWidget {
  const _ParentInfoTab({this.parent});

  final ParentModel? parent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (parent == null) {
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
              'Chưa có thông tin phụ huynh',
              style: tt.titleMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      children: [
        // Parent card
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: cs.secondaryContainer,
                child: Icon(
                  Icons.person,
                  color: cs.secondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parent!.fullName,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (parent!.relationship != null)
                      Text(
                        parent!.relationship!,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Contact info
        _InfoItem(
          icon: Icons.phone_outlined,
          label: 'Số điện thoại',
          value: parent!.phone ?? 'Chưa cập nhật',
        ),
        _InfoItem(
          icon: Icons.email_outlined,
          label: 'Email',
          value: parent!.email ?? 'Chưa cập nhật',
        ),
        if (parent!.address != null)
          _InfoItem(
            icon: Icons.location_on_outlined,
            label: 'Địa chỉ',
            value: parent!.address!,
          ),
        const SizedBox(height: AppSpacing.xl),
        // Quick actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Call parent
                },
                icon: const Icon(Icons.phone, size: 18),
                label: const Text('Gọi điện'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  // TODO: Send message
                },
                icon: const Icon(Icons.message, size: 18),
                label: const Text('Nhắn tin'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// Assignments Tab
// =============================================================================

class _AssignmentsTab extends StatelessWidget {
  const _AssignmentsTab({
    required this.assignments,
    this.attendance,
  });

  final List<StudentAssignmentModel> assignments;
  final AttendanceSummaryModel? attendance;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final completed =
        assignments.where((a) => a.status == AssignmentStatus.completed).toList();
    final incomplete =
        assignments.where((a) => a.status == AssignmentStatus.incomplete).toList();
    final late =
        assignments.where((a) => a.status == AssignmentStatus.late).toList();

    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Chưa có bài tập nào',
              style: tt.titleMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      children: [
        // Summary
        Row(
          children: [
            _AssignmentSummaryChip(
              label: 'Hoàn thành',
              count: completed.length,
              color: Colors.green,
            ),
            const SizedBox(width: AppSpacing.sm),
            _AssignmentSummaryChip(
              label: 'Chưa nộp',
              count: incomplete.length,
              color: cs.error,
            ),
            const SizedBox(width: AppSpacing.sm),
            _AssignmentSummaryChip(
              label: 'Nộp trễ',
              count: late.length,
              color: cs.tertiary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        // Assignment list
        if (incomplete.isNotEmpty) ...[
          _SectionHeader(title: 'Chưa hoàn thành', count: incomplete.length),
          ...incomplete.map((a) => _AssignmentCard(assignment: a)),
          const SizedBox(height: AppSpacing.md),
        ],
        if (late.isNotEmpty) ...[
          _SectionHeader(title: 'Nộp trễ', count: late.length),
          ...late.map((a) => _AssignmentCard(assignment: a)),
          const SizedBox(height: AppSpacing.md),
        ],
        if (completed.isNotEmpty) ...[
          _SectionHeader(title: 'Đã hoàn thành', count: completed.length),
          ...completed.map((a) => _AssignmentCard(assignment: a)),
        ],
        const SizedBox(height: AppSpacing.massive),
      ],
    );
  }
}

class _AssignmentSummaryChip extends StatelessWidget {
  const _AssignmentSummaryChip({
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

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: tt.labelSmall?.copyWith(
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Text(
            title,
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: tt.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.assignment});

  final StudentAssignmentModel assignment;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (statusIcon, statusColor, statusLabel) = switch (assignment.status) {
      AssignmentStatus.completed => (
          Icons.check_circle,
          Colors.green,
          'Hoàn thành',
        ),
      AssignmentStatus.incomplete => (
          Icons.pending,
          cs.error,
          'Chưa nộp',
        ),
      AssignmentStatus.late => (
          Icons.warning_amber,
          cs.tertiary,
          'Nộp trễ',
        ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, size: 18, color: statusColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  assignment.title,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (assignment.score != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: assignment.isPassed
                        ? Colors.green.withValues(alpha: 0.1)
                        : cs.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    assignment.scoreDisplay,
                    style: tt.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: assignment.isPassed ? Colors.green : cs.error,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(Icons.schedule, size: 12, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                'Hạn: ${assignment.dueDate ?? "Không có"}',
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              if (assignment.submittedAt != null) ...[
                const SizedBox(width: AppSpacing.md),
                Icon(Icons.upload, size: 12, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'Nộp: ${assignment.submittedAt}',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          if (assignment.feedback != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.comment_outlined, size: 14, color: cs.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      assignment.feedback!,
                      style: tt.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
