import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/classes/widgets/teacher_class_elements.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

String teacherClassStudentStatus(dynamic status) => switch (status) {
  'active' => 'Đang học',
  'inactive' => 'Ngừng học',
  'completed' => 'Hoàn thành',
  'dropped' => 'Đã rời lớp',
  null || '' => 'Chưa rõ',
  _ => teacherStatus(status),
};

class TeacherClassStudentsPanel extends StatefulWidget {
  const TeacherClassStudentsPanel({
    super.key,
    required this.load,
    required this.onOpen,
    this.refreshToken,
  });
  final Future<List<Map<String, dynamic>>> Function() load;
  final ValueChanged<Map<String, dynamic>> onOpen;
  final Object? refreshToken;

  @override
  State<TeacherClassStudentsPanel> createState() =>
      _TeacherClassStudentsPanelState();
}

class _TeacherClassStudentsPanelState extends State<TeacherClassStudentsPanel> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) =>
      TeacherAsyncView<List<Map<String, dynamic>>>(
        load: widget.load,
        refreshToken: widget.refreshToken,
        builder: (context, students) => students.isEmpty
            ? const Padding(
                padding: AppSpacing.paddingLg,
                child: TeacherClassPanel(
                  TeacherClassEmpty(
                    Icons.people_outline,
                    'Lớp chưa có học viên.',
                  ),
                ),
              )
            : _studentList(students),
      );

  Widget _studentList(List<Map<String, dynamic>> students) {
    final rows = students.where((student) {
      final name =
          '${student['full_name'] ?? ''} ${student['user_name'] ?? ''}';
      return name.toLowerCase().contains(_query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Tìm học viên',
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
                setState(() => _query = value.trim().toLowerCase()),
          ),
        ),
        Expanded(
          child: rows.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Không tìm thấy học viên phù hợp.'),
                      TextButton(
                        onPressed: _clearSearch,
                        child: const Text('Xóa tìm kiếm'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => AppSpacing.vGap12,
                  itemBuilder: (context, index) {
                    final student = rows[index];
                    final name =
                        '${student['full_name'] ?? student['user_name'] ?? 'Học viên'}';
                    return TeacherClassPanel(
                      ListTile(
                        contentPadding: const EdgeInsets.all(AppSpacing.lg),
                        leading: TeacherClassAvatar(name),
                        title: Text(
                          name,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            [
                              if ('${student['user_name'] ?? ''}'.isNotEmpty)
                                '${student['user_name']}',
                              if (student['status'] != null)
                                teacherClassStudentStatus(student['status']),
                              if (student['enrolled_at'] != null)
                                'Tham gia ${teacherClassDate(student['enrolled_at'])}',
                            ].join(' · '),
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => widget.onOpen(student),
                      ),
                      padding: EdgeInsets.zero,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
