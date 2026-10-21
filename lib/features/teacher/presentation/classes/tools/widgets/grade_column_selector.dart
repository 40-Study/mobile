import 'package:flutter/material.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_surface.dart';

class TeacherGradeColumnSelector extends StatelessWidget {
  const TeacherGradeColumnSelector({
    super.key,
    required this.columns,
    required this.columnId,
    required this.selectedColumn,
    required this.busy,
    required this.uncertain,
    required this.hasDrafts,
    required this.hasDraftEntries,
    required this.error,
    required this.onChanged,
    required this.onEdit,
  });
  final List<Map<String, dynamic>> columns;
  final String? columnId;
  final Map<String, dynamic>? selectedColumn;
  final bool busy, uncertain, hasDrafts, hasDraftEntries;
  final String? error;
  final ValueChanged<String?> onChanged;
  final VoidCallback onEdit;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: TeacherSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: columns.any((c) => c['id'] == columnId)
                ? columnId
                : null,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Cột điểm để nhập mới',
            ),
            items: columns
                .map(
                  (c) => DropdownMenuItem(
                    value: '${c['id']}',
                    child: Text(
                      '${c['name']} · /${c['max_score']} · trọng số ${c['weight']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: busy || uncertain || hasDrafts ? null : onChanged,
          ),
          if (selectedColumn != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: busy || hasDraftEntries ? null : onEdit,
                child: const Text('Sửa cấu hình cột'),
              ),
            ),
          const Text(
            'Ô trống là chưa nhập điểm. Điểm đã có được sửa riêng; tổng kết dùng trọng số của từng điểm đã lưu.',
          ),
          if (error != null)
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    ),
  );
}
