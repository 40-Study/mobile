import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/classes/widgets/teacher_class_elements.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherClassStudentsPanel extends StatelessWidget {
  const TeacherClassStudentsPanel({
    super.key,
    required this.load,
    required this.onOpen,
  });
  final Future<List<Map<String, dynamic>>> Function() load;
  final ValueChanged<Map<String, dynamic>> onOpen;
  @override
  Widget build(
    BuildContext context,
  ) => TeacherAsyncView<List<Map<String, dynamic>>>(
    load: load,
    builder: (context, students) => students.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: TeacherClassPanel(
              TeacherClassEmpty(Icons.people_outline, 'Lớp chưa có học viên.'),
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: students.length,
            separatorBuilder: (_, _) => AppSpacing.vGap12,
            itemBuilder: (context, index) {
              final student = students[index];
              final name =
                  '${student['full_name'] ?? student['user_name'] ?? 'Học viên'}';
              return TeacherClassPanel(
                ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.lg),
                  leading: TeacherClassAvatar(name),
                  title: Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      [
                        if ('${student['user_name'] ?? ''}'.isNotEmpty)
                          '${student['user_name']}',
                        if (student['status'] != null)
                          student['status'] == 'active'
                              ? 'Đang học'
                              : teacherStatus(student['status']),
                        if (student['enrolled_at'] != null)
                          'Tham gia ${teacherClassDate(student['enrolled_at'])}',
                      ].join(' · '),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onOpen(student),
                ),
                padding: EdgeInsets.zero,
              );
            },
          ),
  );
}
