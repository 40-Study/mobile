import 'package:flutter/material.dart';
import '../../../data/teacher_api.dart';
import '../../widgets/teacher_widgets.dart';
import 'teacher_assignment_screen.dart';
import 'teacher_gradebook_screen.dart';
import 'tool_form.dart';

class TeacherClassToolsScreen extends StatelessWidget {
  const TeacherClassToolsScreen({
    super.key,
    required this.classId,
    required this.canManage,
    this.archived = false,
    this.api,
  });
  final String classId;
  final bool canManage, archived;
  final TeacherApi? api;
  @override
  Widget build(BuildContext context) {
    final service = api ?? TeacherApi();
    return Scaffold(
      appBar: AppBar(title: const Text('Công cụ lớp học')),
      body: TeacherAsyncView<Map<String, dynamic>>(
        load: () async {
          final detail = toolPayload(await service.get('/classes/$classId'));
          detail['_assignment_write'] = false;
          if (!archived &&
              detail['status'] != 'archived' &&
              canManage &&
              detail['can_manage'] == true) {
            detail['_assignment_write'] = await teacherAssignmentWriteAccess(
              service,
              detail,
            );
          }
          return detail;
        },
        builder: (context, detail) {
          final writable = !archived && detail['status'] != 'archived';
          final manage = writable && canManage && detail['can_manage'] == true;
          return ListView(
            children: [
              if (!writable)
                const ListTile(title: Text('Lớp đã lưu trữ · Chỉ xem')),
              ListTile(
                title: Text('${detail['name'] ?? 'Lớp học'}'),
                subtitle: const Text('Quyền thao tác theo phân công của bạn.'),
              ),
              for (final teachers in [false, true])
                ListTile(
                  title: Text(teachers ? 'Giáo viên' : 'Học viên'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => teacherPush<void>(
                    context,
                    TeacherClassPeopleScreen(
                      api: service,
                      classId: classId,
                      teachers: teachers,
                      canWrite: teachers
                          ? writable && detail['can_assign_teachers'] == true
                          : manage,
                    ),
                  ),
                ),
              ListTile(
                title: const Text('Bài tập lập trình'),
                subtitle: const Text('Bài giao, testcase và bài nộp'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => teacherPush<void>(
                  context,
                  TeacherAssignmentScreen(
                    api: service,
                    classId: classId,
                    canWrite: manage && detail['_assignment_write'] == true,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Bảng điểm và tổng kết'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => teacherPush<void>(
                  context,
                  TeacherGradebookScreen(
                    api: service,
                    classId: classId,
                    canWrite: manage,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TeacherClassPeopleScreen extends StatefulWidget {
  const TeacherClassPeopleScreen({
    required this.api,
    required this.classId,
    required this.teachers,
    required this.canWrite,
  });
  final TeacherApi api;
  final String classId;
  final bool teachers, canWrite;
  @override
  State<TeacherClassPeopleScreen> createState() =>
      _TeacherClassPeopleScreenState();
}

class _TeacherClassPeopleScreenState extends State<TeacherClassPeopleScreen> {
  int revision = 0;
  bool busy = false;
  String get kind => widget.teachers ? 'teachers' : 'students';
  Future<void> add() async {
    final saved = await teacherToolForm(
      context,
      title: widget.teachers
          ? 'Tìm giáo viên theo tên'
          : 'Tìm học viên theo tên',
      choices: const {
        'Vai trò': {'primary': 'Giáo viên chính', 'assistant': 'Trợ giảng'},
      },
      fields: {'Từ khóa': '', if (widget.teachers) 'Vai trò': 'assistant'},
      validate: (v) => v['Từ khóa']!.isEmpty
          ? 'Nhập tên cần tìm.'
          : widget.teachers && !['primary', 'assistant'].contains(v['Vai trò'])
          ? 'Vai trò phải là primary hoặc assistant.'
          : null,
      save: (v) async {
        final rows = await toolPages(
          widget.api,
          '/classes/${widget.classId}/${widget.teachers ? 'assignable-teachers' : 'enrollable-students'}',
          keys: [kind],
          query: {'keyword': v['Từ khóa']},
        );
        if (!mounted) return;
        final selected = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text('Chọn người phù hợp'),
            children: rows.isEmpty
                ? [
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Không tìm thấy người có thể thêm.'),
                    ),
                  ]
                : rows
                      .map(
                        (r) => SimpleDialogOption(
                          onPressed: () => Navigator.pop(context, r),
                          child: Text(
                            '${r['full_name'] ?? r['user_name'] ?? r['id']}',
                          ),
                        ),
                      )
                      .toList(),
          ),
        );
        if (selected == null) throw StateError('Chưa chọn người.');
        await widget.api.post(
          '/classes/${widget.classId}/$kind',
          data: {
            widget.teachers ? 'teacher_id' : 'student_id': selected['id'],
            if (widget.teachers) 'role': v['Vai trò'],
          },
        );
      },
    );
    if (saved && mounted) setState(() => revision++);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.teachers ? 'Giáo viên trong lớp' : 'Học viên trong lớp',
      ),
      actions: [
        if (widget.canWrite)
          IconButton(
            onPressed: busy ? null : add,
            tooltip: 'Thêm thành viên',
            icon: const Icon(Icons.person_add),
          ),
      ],
    ),
    body: TeacherAsyncView<List<Map<String, dynamic>>>(
      key: ValueKey(revision),
      load: () => toolPages(
        widget.api,
        '/classes/${widget.classId}/$kind',
        keys: [kind],
      ),
      builder: (context, rows) => rows.isEmpty
          ? const Center(child: Text('Chưa có thành viên.'))
          : ListView.separated(
              itemCount: rows.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final r = rows[i];
                final person = widget.teachers ? teacherMap(r['teacher']) : r;
                return ListTile(
                  title: Text(
                    '${person['full_name'] ?? person['user_name'] ?? 'Thành viên'}',
                  ),
                  subtitle: Text('${r['role'] ?? r['status'] ?? ''}'),
                  trailing: widget.canWrite
                      ? IconButton(
                          tooltip: 'Xóa khỏi lớp',
                          icon: const Icon(Icons.person_remove_outlined),
                          onPressed: busy
                              ? null
                              : () async {
                                  if (!await teacherToolConfirm(
                                    context,
                                    'Xóa người này khỏi lớp?',
                                  )) {
                                    return;
                                  }
                                  if (!mounted) return;
                                  setState(() => busy = true);
                                  try {
                                    await widget.api.delete(
                                      '/classes/${widget.classId}/$kind/${r[widget.teachers ? 'teacher_id' : 'student_id']}',
                                    );
                                    if (mounted) setState(() => revision++);
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Không xóa được: $e'),
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) setState(() => busy = false);
                                  }
                                },
                        )
                      : null,
                );
              },
            ),
    ),
  );
}

Future<bool> teacherAssignmentWriteAccess(
  TeacherApi api,
  Map<String, dynamic> detail,
) async {
  if (detail['status'] == 'archived' || detail['can_manage'] != true)
    return false;
  final assigned = teacherList(
    await api.get('/classes/me'),
    keys: const ['classes'],
  );
  if (assigned.any((row) => row['id'] == detail['id'])) return true;
  if (detail['course_id'] == null) return false;
  final user = teacherMap(await api.get('/auth/me'));
  final course = teacherMap(await api.get('/courses/${detail['course_id']}'));
  return user['id'] != null && course['instructor_id'] == user['id'];
}
