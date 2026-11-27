import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/theme/theme.dart';
import '../../../data/teacher_api.dart';
import '../../../data/teacher_preview_api.dart';
import '../../widgets/teacher_widgets.dart';
import '../widgets/teacher_class_elements.dart';
import '../widgets/teacher_class_students_panel.dart';
import 'teacher_assignment_screen.dart';
import 'teacher_class_member_picker.dart';
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
                      personalClass: detail['organization_id'] == null,
                      className: detail['name']?.toString(),
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
    super.key,
    this.className,
    required this.api,
    required this.classId,
    required this.teachers,
    required this.canWrite,
    this.personalClass = true,
  });
  final TeacherApi api;
  final String classId;
  final bool teachers, canWrite;
  final bool personalClass;
  final String? className;
  @override
  State<TeacherClassPeopleScreen> createState() =>
      _TeacherClassPeopleScreenState();
}

class _TeacherClassPeopleScreenState extends State<TeacherClassPeopleScreen> {
  final _searchController = TextEditingController();
  int revision = 0;
  bool busy = false;
  bool changed = false;
  String query = '';
  String get kind => widget.teachers ? 'teachers' : 'students';
  String get personLabel => widget.teachers ? 'giáo viên' : 'học viên';
  String get path => '/classes/${widget.classId}/$kind';
  bool get canWrite => widget.canWrite && widget.api is! TeacherPreviewApi;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> add() async {
    if (busy || !canWrite) return;
    final added = await teacherPush<bool>(
      context,
      TeacherClassMemberPicker(
        api: widget.api,
        classId: widget.classId,
        className: widget.className,
        teachers: widget.teachers,
      ),
    );
    if (added == true && mounted) _markChanged();
  }

  void _markChanged() {
    setState(() {
      changed = true;
      revision++;
    });
  }

  Map<String, dynamic> _person(Map<String, dynamic> row) {
    if (!widget.teachers) return row;
    final teacher = teacherMap(row['teacher']);
    return teacher.isEmpty ? row : teacher;
  }

  String _name(Map<String, dynamic> person) =>
      (person['full_name'] ?? person['user_name'] ?? 'Thành viên').toString();

  bool _canRemove(Map<String, dynamic> row) {
    if (!canWrite) return false;
    if (!widget.teachers || !widget.personalClass) return true;
    final auth = context.read<AuthBloc?>()?.state;
    final teacherId = row['teacher_id']?.toString();
    return auth is AuthAuthenticated &&
        teacherId != null &&
        teacherId != auth.user.id;
  }

  Future<void> _remove(Map<String, dynamic> row, String name) async {
    if (busy || !_canRemove(row)) return;
    final memberId = row[widget.teachers ? 'teacher_id' : 'student_id'];
    if (memberId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.teachers ? 'Gỡ phân công?' : 'Gỡ học viên?'),
        content: Text('Gỡ “$name” khỏi ${widget.className ?? 'lớp này'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Giữ thành viên'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Gỡ khỏi lớp'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || busy || !_canRemove(row)) return;

    setState(() => busy = true);
    try {
      await widget.api.delete('$path/$memberId');
      if (mounted) _markChanged();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(teacherErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope<bool>(
    canPop: !busy && !changed,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && changed && !busy) Navigator.of(context).pop(true);
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          widget.teachers ? 'Giáo viên trong lớp' : 'Học viên trong lớp',
        ),
      ),
      body: TeacherAsyncView<List<Map<String, dynamic>>>(
        refreshToken: revision,
        load: () => toolPages(widget.api, path, keys: [kind]),
        builder: (context, rows) {
          final shown = rows.where((row) {
            final person = _person(row);
            return '${_name(person)} ${person['user_name'] ?? ''}'
                .toLowerCase()
                .contains(query);
          }).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.className case final name?)
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    if (canWrite)
                      TextButton.icon(
                        onPressed: busy ? null : add,
                        icon: const Icon(Icons.person_add_outlined),
                        label: Text('Thêm $personLabel'),
                      )
                    else
                      Text(
                        widget.api is TeacherPreviewApi
                            ? 'Dữ liệu mẫu · Chỉ xem'
                            : 'Chỉ xem',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (rows.isNotEmpty) ...[
                      AppSpacing.vGap12,
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Tìm $personLabel',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Xóa tìm kiếm',
                                  onPressed: _clearSearch,
                                  icon: const Icon(Icons.clear),
                                ),
                        ),
                        textInputAction: TextInputAction.search,
                        onChanged: (value) =>
                            setState(() => query = value.trim().toLowerCase()),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: shown.isEmpty
                    ? Padding(
                        padding: AppSpacing.paddingLg,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TeacherClassEmpty(
                                rows.isEmpty
                                    ? Icons.groups_outlined
                                    : Icons.search_off_outlined,
                                rows.isEmpty
                                    ? 'Lớp chưa có $personLabel.'
                                    : 'Không tìm thấy $personLabel phù hợp.',
                              ),
                              if (rows.isNotEmpty)
                                TextButton(
                                  onPressed: _clearSearch,
                                  child: const Text('Xóa tìm kiếm'),
                                ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: AppSpacing.paddingHorizontalLg,
                        itemCount: shown.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final row = shown[i];
                          final person = _person(row);
                          final name = _name(person);
                          final status = widget.teachers
                              ? switch (row['role']) {
                                  'primary' => 'Giáo viên chính',
                                  'assistant' => 'Trợ giảng',
                                  _ => 'Giáo viên',
                                }
                              : teacherClassStudentStatus(row['status']);
                          final userName = person['user_name']?.toString();
                          final info = [
                            if (userName != null &&
                                userName != name &&
                                userName.isNotEmpty)
                              userName,
                            status,
                          ].join(' · ');
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: TeacherClassAvatar(name),
                            title: Text(name),
                            subtitle: Text(info),
                            trailing: _canRemove(row)
                                ? PopupMenuButton<String>(
                                    tooltip: 'Tùy chọn cho $name',
                                    enabled: !busy,
                                    onSelected: (_) => _remove(row, name),
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: 'remove',
                                        child: Text('Gỡ khỏi lớp'),
                                      ),
                                    ],
                                  )
                                : null,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    ),
  );

  void _clearSearch() {
    _searchController.clear();
    setState(() => query = '');
  }
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
