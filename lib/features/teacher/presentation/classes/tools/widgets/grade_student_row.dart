import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_surface.dart';

import 'package:study/features/teacher/data/grade_rules.dart';

class TeacherGradeStudentRow extends StatelessWidget {
  const TeacherGradeStudentRow({
    super.key,
    required this.student,
    required this.columnId,
    required this.selectedColumn,
    required this.canWrite,
    required this.busy,
    required this.uncertain,
    required this.draft,
    required this.onDraftChanged,
    required this.onEditGrade,
  });
  final Map<String, dynamic> student;
  final Map<String, dynamic>? selectedColumn;
  final bool canWrite, busy, uncertain;
  final String draft;
  final String? columnId;
  final ValueChanged<String> onDraftChanged;
  final ValueChanged<Map<String, dynamic>> onEditGrade;
  @override
  Widget build(BuildContext context) {
    final id = '${student['student_id']}';
    final grades = teacherList(student['grades']);
    final existing =
        selectedColumn != null &&
        grades.any(
          (g) =>
              g['title'] == selectedColumn!['name'] &&
              g['grade_type'] == selectedColumn!['grade_type'],
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TeacherSurface(
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          key: ValueKey(id),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            child: const Icon(Icons.person_outline),
          ),
          shape: const Border(),
          collapsedShape: const Border(),
          title: Text('${student['student_name']}'),
          subtitle: Text('${grades.length} điểm đã lưu'),
          children: [
            for (final grade in grades)
              ListTile(
                title: Text(
                  '${grade['title']}: ${grade['score']}/${grade['max_score']}',
                ),
                subtitle: Text(
                  '${grade['feedback'] ?? ''}\nTrọng số ${grade['weight']} · ${grade['graded_by_name'] ?? ''} · ${grade['graded_at'] ?? ''}',
                ),
                trailing: canWrite && !busy
                    ? IconButton(
                        tooltip: 'Sửa điểm',
                        onPressed: () => onEditGrade(grade),
                        icon: const Icon(Icons.edit_outlined),
                      )
                    : null,
              ),
            if (canWrite && selectedColumn != null && !existing)
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  key: ValueKey('$id/$columnId'),
                  initialValue: draft,
                  enabled: !busy && !uncertain,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText:
                        '${selectedColumn!['name']} · tối đa ${selectedColumn!['max_score']}',
                    helperText: 'Để trống nếu chưa chấm',
                  ),
                  onChanged: (v) => onDraftChanged(v),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) => v == null || v.isEmpty
                      ? null
                      : teacherScoreError(v, selectedColumn!['max_score']),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
