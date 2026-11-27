import 'package:flutter/material.dart';
import 'package:study/theme/app_spacing.dart';

class TeacherGradeColumnSelector extends StatelessWidget {
  const TeacherGradeColumnSelector({
    super.key,
    required this.columns,
    required this.columnId,
    required this.busy,
    required this.uncertain,
    required this.hasDrafts,
    required this.error,
    required this.onChanged,
  });
  final List<Map<String, dynamic>> columns;
  final String? columnId;
  final bool busy, uncertain, hasDrafts;
  final String? error;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (columns.isNotEmpty)
          DropdownButtonFormField<String>(
            initialValue: columns.any((c) => '${c['id']}' == columnId)
                ? columnId
                : null,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Cột điểm đang xem'),
            items: columns
                .map(
                  (c) => DropdownMenuItem(
                    value: '${c['id']}',
                    child: Text(
                      '${c['name']} · Thang ${c['max_score']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: busy || uncertain || hasDrafts ? null : onChanged,
          ),
        if (error != null) ...[
          AppSpacing.vGap8,
          Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    ),
  );
}
