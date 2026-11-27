import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/grade_rules.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_surface.dart';
import 'package:study/theme/app_spacing.dart';

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
    required this.canEnterScore,
    required this.error,
    required this.conflict,
    required this.retry,
    required this.onDiscardDraft,
  });

  final Map<String, dynamic> student;
  final Map<String, dynamic>? selectedColumn;
  final bool canWrite, canEnterScore, busy, uncertain, conflict, retry;
  final String? error;
  final String draft;
  final String? columnId;
  final ValueChanged<String> onDraftChanged;
  final ValueChanged<Map<String, dynamic>> onEditGrade;
  final VoidCallback onDiscardDraft;

  Widget _grade(
    BuildContext context,
    Map<String, dynamic> grade, {
    bool selected = false,
  }) {
    final score = grade['score'];
    final feedback = grade['feedback']?.toString().trim() ?? '';
    final metadata = [
      if (grade['weight'] != null) 'Trọng số ${grade['weight']}',
      if (grade['graded_by_name'] case final String name when name.isNotEmpty)
        name,
    ].join(' · ');
    return ListTile(
      contentPadding: AppSpacing.paddingHorizontalMd,
      title: Text(
        '${grade['title'] ?? 'Điểm'} · ${score ?? 'Chưa chấm'}${score != null ? '/${grade['max_score']}' : ''}',
        style: selected ? Theme.of(context).textTheme.titleSmall : null,
      ),
      subtitle: feedback.isEmpty && (selected || metadata.isEmpty)
          ? null
          : Text(
              [
                if (feedback.isNotEmpty) feedback,
                if (!selected && metadata.isNotEmpty) metadata,
              ].join('\n'),
            ),
      trailing: canWrite && !busy && !uncertain
          ? IconButton(
              tooltip: 'Sửa điểm ${grade['title'] ?? ''}',
              onPressed: () => onEditGrade(grade),
              icon: const Icon(Icons.edit_outlined),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = '${student['student_id']}';
    final grades = teacherList(student['grades']);
    final column = selectedColumn;
    final selectedGrade = column == null
        ? null
        : grades
              .where(
                (grade) =>
                    grade['title'] == column['name'] &&
                    grade['grade_type'] == column['grade_type'],
              )
              .firstOrNull;
    final otherGrades = grades
        .where((grade) => !identical(grade, selectedGrade))
        .toList();
    final canInput =
        canWrite &&
        canEnterScore &&
        column != null &&
        selectedGrade == null &&
        !conflict;
    final cs = Theme.of(context).colorScheme;
    final issue = conflict ? 'Có điểm khác hoặc nhiều bản ghi cùng cột' : error;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TeacherSurface(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: AppSpacing.paddingHorizontalMd,
              leading: CircleAvatar(
                backgroundColor: cs.primaryContainer,
                foregroundColor: cs.onPrimaryContainer,
                child: const Icon(Icons.person_outline),
              ),
              title: Text('${student['student_name'] ?? 'Học viên'}'),
              subtitle: issue == null && !retry
                  ? null
                  : Text(
                      issue ?? 'Chưa thấy điểm trên máy chủ',
                      style: TextStyle(
                        color: issue != null ? cs.error : cs.onSurfaceVariant,
                      ),
                    ),
            ),
            if (selectedGrade != null)
              _grade(context, selectedGrade, selected: true),
            if (canInput)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: TextFormField(
                  key: ValueKey('$id/$columnId'),
                  initialValue: draft,
                  enabled: !busy && !uncertain,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Điểm ${column['name']}',
                    hintText: 'Chưa chấm',
                    suffixText: '/${column['max_score']}',
                    errorText: error,
                  ),
                  onChanged: onDraftChanged,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? null
                      : teacherScoreError(value, column['max_score']),
                ),
              )
            else if (column != null && selectedGrade == null && !conflict)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Text('Chưa chấm · ${column['name']}'),
              ),
            if (!busy && !uncertain && draft.isNotEmpty && !canInput)
              ListTile(
                contentPadding: AppSpacing.paddingHorizontalMd,
                title: Text('Điểm nháp: $draft'),
                trailing: TextButton(
                  onPressed: onDiscardDraft,
                  child: const Text('Bỏ nháp'),
                ),
              ),
            if (otherGrades.isNotEmpty)
              ExpansionTile(
                key: PageStorageKey('other-grades/$id'),
                tilePadding: AppSpacing.paddingHorizontalMd,
                shape: const Border(),
                collapsedShape: const Border(),
                title: Text(
                  selectedGrade == null && column == null
                      ? 'Điểm đã lưu (${otherGrades.length})'
                      : 'Điểm khác (${otherGrades.length})',
                ),
                children: [
                  for (final grade in otherGrades) _grade(context, grade),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
