import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/data/teacher_preview_api.dart';
import 'package:study/features/teacher/presentation/classes/teacher_class_editor.dart';
import 'package:study/features/teacher/presentation/classes/tools/teacher_assignment_screen.dart';
import 'package:study/features/teacher/presentation/classes/tools/teacher_class_tools_screen.dart';
import 'package:study/features/teacher/presentation/classes/tools/teacher_gradebook_screen.dart';
import 'package:study/features/teacher/presentation/classes/widgets/teacher_class_elements.dart';
import 'package:study/features/teacher/presentation/classes/widgets/teacher_class_header.dart';
import 'package:study/features/teacher/presentation/classes/widgets/teacher_class_overview.dart';
import 'package:study/features/teacher/presentation/classes/widgets/teacher_class_schedules_panel.dart';
import 'package:study/features/teacher/presentation/classes/widgets/teacher_class_sessions_panel.dart';
import 'package:study/features/teacher/presentation/classes/widgets/teacher_class_students_panel.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_schedule_editor.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherClassScreen extends StatefulWidget {
  const TeacherClassScreen({
    super.key,
    required this.api,
    required this.classId,
    required this.workplaceLabel,
    this.onChanged,
  });
  final TeacherApi api;
  final String classId;
  final String workplaceLabel;
  final VoidCallback? onChanged;
  @override
  State<TeacherClassScreen> createState() => _TeacherClassScreenState();
}

class _TeacherClassScreenState extends State<TeacherClassScreen>
    with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 5, vsync: this);
  int _detailsRevision = 0;
  int _teachersRevision = 0;
  int _studentsRevision = 0;
  int _gradesRevision = 0;
  int _schedulesRevision = 0;
  int _sessionsRevision = 0;
  bool _deletingSchedule = false;
  bool _showRecurring = false;
  bool get _preview => widget.api is TeacherPreviewApi;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _reload() => setState(() {
    _detailsRevision++;
    _teachersRevision++;
    _studentsRevision++;
    _gradesRevision++;
    _schedulesRevision++;
    _sessionsRevision++;
  });

  Future<void> _edit(Widget screen, VoidCallback onChanged) async {
    final result = await teacherPush<Object?>(context, screen);
    if (!mounted || (result != true && result is! String)) return;
    setState(onChanged);
    widget.onChanged?.call();
  }

  void _editClass(TeacherClassData detail) => _edit(
    TeacherClassEditor(api: widget.api, classData: detail),
    () => _detailsRevision++,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
    appBar: AppBar(
      title: const Text('Chi tiết lớp'),
      actions: [
        IconButton(
          onPressed: _reload,
          tooltip: 'Tải lại',
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: TeacherAsyncView<TeacherClassData>(
      refreshToken: _detailsRevision,
      load: () async {
        final json = teacherPayload(
          await widget.api.get('/classes/${widget.classId}'),
        );
        return TeacherClassData(
          _preview
              ? {...json, 'can_manage': false, 'can_assign_teachers': false}
              : json,
        );
      },
      builder: (context, detail) => Column(
        children: [
          TeacherClassHeader(
            detail: detail,
            workplaceLabel: widget.workplaceLabel,
            preview: _preview,
            onEdit: () => _editClass(detail),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.xs,
              ),
              indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: AppRadius.borderMd,
              ),
              labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant,
              labelStyle: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: 'Tổng quan'),
                Tab(text: 'Buổi học'),
                Tab(text: 'Học viên'),
                Tab(text: 'Bài tập'),
                Tab(text: 'Bảng điểm'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                TeacherClassOverview(
                  detail: detail,
                  onEditClass: () => _editClass(detail),
                  teachersRevision: _teachersRevision,
                  loadTeachers: () => teacherAllPages(
                    widget.api,
                    '/classes/${detail.id}/teachers',
                    'teachers',
                  ),
                  onManageTeachers: () => _edit(
                    TeacherClassPeopleScreen(
                      api: widget.api,
                      classId: detail.id,
                      teachers: true,
                      personalClass: detail.organizationId == null,
                      className: detail.name,
                      canWrite: detail.canAssignTeachers,
                    ),
                    () {
                      _detailsRevision++;
                      _teachersRevision++;
                    },
                  ),
                  onOpenSchedules: () {
                    setState(() => _showRecurring = true);
                    _tabs.animateTo(1);
                  },
                ),
                _scheduleTab(detail),
                Column(
                  children: [
                    if (detail.canManage)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _edit(
                            TeacherClassPeopleScreen(
                              api: widget.api,
                              classId: detail.id,
                              teachers: false,
                              className: detail.name,
                              canWrite: true,
                            ),
                            () {
                              _detailsRevision++;
                              _studentsRevision++;
                            },
                          ),
                          icon: const Icon(Icons.person_add_outlined),
                          label: const Text('Quản lý học viên'),
                        ),
                      ),
                    Expanded(
                      child: TeacherClassStudentsPanel(
                        refreshToken: _studentsRevision,
                        load: () => teacherAllPages(
                          widget.api,
                          '/classes/${detail.id}/students',
                          'students',
                        ),
                        onOpen: (student) => _openStudent(detail, student),
                      ),
                    ),
                  ],
                ),
                TeacherAsyncView<bool>(
                  refreshToken: (detail.canManage, _teachersRevision),
                  load: () => detail.canManage
                      ? teacherAssignmentWriteAccess(widget.api, detail.json)
                      : Future.value(false),
                  builder: (context, canWrite) => TeacherAssignmentScreen(
                    api: widget.api,
                    classId: detail.id,
                    canWrite: detail.canManage && canWrite,
                    embedded: true,
                  ),
                ),
                TeacherGradebookScreen(
                  refreshToken: (_studentsRevision, _gradesRevision),
                  api: widget.api,
                  classId: detail.id,
                  canWrite: detail.canManage,
                  embedded: true,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _scheduleTab(TeacherClassData detail) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          0,
        ),
        child: Wrap(
          spacing: AppSpacing.sm,
          children: [
            ChoiceChip(
              label: const Text('Buổi cụ thể'),
              selected: !_showRecurring,
              onSelected: (_) => setState(() => _showRecurring = false),
            ),
            ChoiceChip(
              label: const Text('Lịch định kỳ'),
              selected: _showRecurring,
              onSelected: (_) => setState(() => _showRecurring = true),
            ),
          ],
        ),
      ),
      Expanded(
        child: _showRecurring
            ? ListView(
                key: PageStorageKey('recurring-${detail.id}'),
                padding: AppSpacing.paddingLg,
                children: [
                  TeacherClassSchedulesPanel(
                    detail: detail,
                    load: () async => teacherList(
                      await widget.api.get('/classes/${detail.id}/schedules'),
                    ),
                    refreshToken: _schedulesRevision,
                    onAdd: () => _edit(
                      TeacherScheduleEditor(
                        api: widget.api,
                        classId: detail.id,
                        recurring: true,
                      ),
                      () => _schedulesRevision++,
                    ),
                    onEdit: (row) => _edit(
                      TeacherScheduleEditor(
                        api: widget.api,
                        classId: detail.id,
                        scheduleId: '${row['id']}',
                        recurring: true,
                        initial: row,
                      ),
                      () => _schedulesRevision++,
                    ),
                    onDelete: (row) => _deleteSchedule(detail.id, row),
                    onGenerate: () => _edit(
                      TeacherScheduleEditor(
                        api: widget.api,
                        classId: detail.id,
                        generate: true,
                      ),
                      () {
                        _sessionsRevision++;
                        _showRecurring = false;
                      },
                    ),
                  ),
                ],
              )
            : TeacherClassSessionsPanel(
                detail: detail,
                refreshToken: _sessionsRevision,
                load: () => teacherAllPages(
                  widget.api,
                  '/classes/${detail.id}/sessions',
                  'data',
                ),
                onCreate: () => _edit(
                  TeacherScheduleEditor(api: widget.api, classId: detail.id),
                  () => _sessionsRevision++,
                ),
                onOpen: (session) => _edit(
                  TeacherSessionScreen(
                    api: widget.api,
                    classId: detail.id,
                    sessionId: session['id'].toString(),
                    workplaceLabel: widget.workplaceLabel,
                  ),
                  () => _sessionsRevision++,
                ),
              ),
      ),
    ],
  );

  Future<void> _deleteSchedule(
    String classId,
    Map<String, dynamic> schedule,
  ) async {
    final scheduleId = schedule['id'];
    if (_preview || _deletingSchedule || scheduleId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch định kỳ?'),
        content: Text(
          '${teacherClassScheduleSlot(schedule)}\n\n'
          'Các buổi đã tạo vẫn nằm trong Buổi cụ thể.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Xóa lịch'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || _deletingSchedule) return;
    _deletingSchedule = true;
    try {
      await widget.api.delete('/classes/$classId/schedules/$scheduleId');
      if (mounted) {
        setState(() => _schedulesRevision++);
        widget.onChanged?.call();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(teacherErrorMessage(error))));
      }
    } finally {
      _deletingSchedule = false;
    }
  }

  void _openStudent(TeacherClassData detail, Map<String, dynamic> student) {
    final name =
        '${student['full_name'] ?? student['user_name'] ?? 'Học viên'}';
    teacherPush<Object?>(
      context,
      Scaffold(
        appBar: AppBar(title: const Text('Học viên trong lớp')),
        body: Builder(
          builder: (detailContext) => ListView(
            padding: AppSpacing.paddingLg,
            children: [
              TeacherClassPanel(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TeacherClassAvatar(name),
                        AppSpacing.hGap12,
                        Expanded(
                          child: Text(
                            name,
                            style: Theme.of(detailContext).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGap12,
                    Text('${detail.name} · ${widget.workplaceLabel}'),
                    AppSpacing.vGap8,
                    TeacherClassStatus(
                      teacherClassStudentStatus(student['status']),
                      muted: student['status'] != 'active',
                    ),
                    if (student['enrolled_at'] != null) ...[
                      AppSpacing.vGap8,
                      Text(
                        'Ngày ghi danh: ${teacherClassDate(student['enrolled_at'])}',
                      ),
                    ],
                  ],
                ),
              ),
              AppSpacing.vGap16,
              OutlinedButton.icon(
                onPressed: () => teacherPush<Object?>(
                  detailContext,
                  TeacherGradebookScreen(
                    classId: detail.id,
                    api: widget.api,
                    canWrite: detail.canManage,
                    onGradesChanged: () {
                      if (mounted) setState(() => _gradesRevision++);
                    },
                  ),
                ),
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Xem bảng điểm của lớp'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
