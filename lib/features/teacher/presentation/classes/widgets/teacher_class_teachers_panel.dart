import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/classes/widgets/teacher_class_elements.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherClassTeachersPanel extends StatelessWidget {
  const TeacherClassTeachersPanel({super.key, required this.load});
  final Future<List<Map<String, dynamic>>> Function() load;
  @override
  Widget build(
    BuildContext context,
  ) => TeacherAsyncView<List<Map<String, dynamic>>>(
    load: load,
    builder: (context, rows) => TeacherClassPanel(
      rows.isEmpty
          ? TeacherClassEmpty(
              Icons.groups_outlined,
              'Lớp chưa phân công giáo viên.',
            )
          : Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const Divider(height: AppSpacing.xl),
                  Builder(
                    builder: (context) {
                      final row = rows[i];
                      final teacher = teacherMap(row['teacher']);
                      final name =
                          '${teacher['full_name'] ?? teacher['user_name'] ?? teacher['username'] ?? 'Giáo viên'}';
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TeacherClassAvatar(name),
                          AppSpacing.hGap12,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                AppSpacing.vGap4,
                                Text(
                                  row['role'] == 'primary'
                                      ? 'Giáo viên chính'
                                      : 'Trợ giảng',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
    ),
  );
}
