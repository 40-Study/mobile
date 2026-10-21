import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/classes/teacher_class_editor.dart';
import 'package:study/features/teacher/presentation/classes/tools/teacher_assignment_screen.dart';
import 'package:study/features/teacher/presentation/classes/tools/teacher_class_tools_screen.dart';
import 'package:study/features/teacher/presentation/classes/tools/teacher_gradebook_screen.dart';
import 'package:study/features/teacher/presentation/classes/widgets/teacher_class_header.dart';
import 'package:study/features/teacher/presentation/classes/widgets/teacher_class_overview.dart';
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
  });
  final TeacherApi api;
  final String classId;
  final String workplaceLabel;
  @override
  State<TeacherClassScreen> createState() => _TeacherClassScreenState();
}

class _TeacherClassScreenState extends State<TeacherClassScreen> {
  int _revision = 0;
  void _reload() => setState(() => _revision++);
  Future<void> _edit(Widget screen) async {
    await teacherPush<Object?>(context, screen);
    if (mounted) _reload();
  }

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
      key: ValueKey(_revision),
      load: () async {
        final detail = TeacherClassData(
          teacherPayload(await widget.api.get('/classes/${widget.classId}')),
        );
        detail.json['_assignment_write'] =
            detail.canManage &&
            await teacherAssignmentWriteAccess(widget.api, detail.json);
        return detail;
      },
      builder: (context, detail) => DefaultTabController(
        length: 5,
        child: Column(
          children: [
            TeacherClassHeader(
              detail: detail,
              workplaceLabel: widget.workplaceLabel,
              onEdit: () =>
                  _edit(TeacherClassEditor(api: widget.api, classData: detail)),
              onTeachers: () => _edit(
                TeacherClassPeopleScreen(
                  api: widget.api,
                  classId: detail.id,
                  teachers: true,
                  canWrite: detail.canAssignTeachers,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: TabBar(
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
                children: [
                  TeacherClassOverview(
                    detail: detail,
                    loadTeachers: () => teacherAllPages(
                      widget.api,
                      '/classes/${detail.id}/teachers',
                      'teachers',
                    ),
                    loadSchedules: () async => teacherList(
                      await widget.api.get('/classes/${detail.id}/schedules'),
                    ),
                    onAddSchedule: () => _edit(
                      TeacherScheduleEditor(
                        api: widget.api,
                        classId: detail.id,
                        recurring: true,
                      ),
                    ),
                    onEditSchedule: (row) => _edit(
                      TeacherScheduleEditor(
                        api: widget.api,
                        classId: detail.id,
                        scheduleId: '${row['id']}',
                        recurring: true,
                        initial: row,
                      ),
                    ),
                    onDeleteSchedule: (id) => _deleteSchedule(detail.id, id),
                    onGenerate: () => _edit(
                      TeacherScheduleEditor(
                        api: widget.api,
                        classId: detail.id,
                        generate: true,
                      ),
                    ),
                  ),
                  TeacherClassSessionsPanel(
                    detail: detail,
                    load: () => teacherAllPages(
                      widget.api,
                      '/classes/${detail.id}/sessions',
                      'data',
                    ),
                    onCreate: () => _edit(
                      TeacherScheduleEditor(
                        api: widget.api,
                        classId: detail.id,
                      ),
                    ),
                    onOpen: (session) => _edit(
                      TeacherSessionScreen(
                        api: widget.api,
                        classId: detail.id,
                        sessionId: session['id'].toString(),
                        workplaceLabel: widget.workplaceLabel,
                      ),
                    ),
                  ),
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
                                canWrite: true,
                              ),
                            ),
                            icon: const Icon(Icons.person_add_outlined),
                            label: const Text('Quản lý học viên'),
                          ),
                        ),
                      Expanded(
                        child: TeacherClassStudentsPanel(
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
                  TeacherAssignmentScreen(
                    api: widget.api,
                    classId: detail.id,
                    canWrite: detail.json['_assignment_write'] == true,
                    embedded: true,
                  ),
                  TeacherGradebookScreen(
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
    ),
  );

  Future<void> _deleteSchedule(String classId, String scheduleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch lặp?'),
        content: const Text(
          'Các buổi đã tạo được quản lý riêng. Kiểm tra và hủy từng buổi nếu cần.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Quay lại'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa lịch'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.api.delete('/classes/$classId/schedules/$scheduleId');
      if (mounted) _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(teacherErrorMessage(error))));
      }
    }
  }

  void _openStudent(TeacherClassData detail, Map<String, dynamic> student) {
    final name =
        '${student['full_name'] ?? student['user_name'] ?? 'Học viên'}';
    teacherPush<Object?>(
      context,
      Scaffold(
        appBar: AppBar(title: const Text('Học viên trong lớp')),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            Text(name, style: Theme.of(context).textTheme.headlineSmall),
            Text('${detail.name} · ${widget.workplaceLabel}'),
            Text('Trạng thái ghi danh: ${student['status'] ?? ''}'),
            Text('Ngày ghi danh: ${student['enrolled_at'] ?? ''}'),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => teacherPush<Object?>(
                context,
                TeacherClassToolsScreen(
                  classId: detail.id,
                  api: widget.api,
                  canManage: detail.canManage,
                  archived: detail.archived,
                ),
              ),
              child: const Text('Xem bảng điểm của lớp'),
            ),
          ],
        ),
      ),
    );
  }
}
