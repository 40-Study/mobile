import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/classes/widgets/teacher_class_elements.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherClassSchedulesPanel extends StatelessWidget {
  const TeacherClassSchedulesPanel({
    super.key,
    required this.detail,
    required this.load,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onGenerate,
  });
  final TeacherClassData detail;
  final Future<List<Map<String, dynamic>>> Function() load;
  final VoidCallback onAdd;
  final ValueChanged<Map<String, dynamic>> onEdit;
  final ValueChanged<String> onDelete;
  final VoidCallback onGenerate;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TeacherSectionTitle(
        title: 'Lịch dạy định kỳ',
        trailing: detail.canManage
            ? TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Thêm lịch'),
              )
            : null,
      ),
      TeacherAsyncView<List<Map<String, dynamic>>>(
        load: load,
        builder: (context, rows) => TeacherClassPanel(
          rows.isEmpty
              ? TeacherClassEmpty(
                  Icons.calendar_month_outlined,
                  'Chưa có lịch dạy định kỳ.',
                )
              : Column(
                  children: [
                    for (var i = 0; i < rows.length; i++) ...[
                      if (i > 0) const Divider(height: AppSpacing.xl),
                      Builder(
                        builder: (context) {
                          final row = rows[i];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  borderRadius: AppRadius.borderMd,
                                ),
                                child: Icon(
                                  Icons.calendar_month_outlined,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              AppSpacing.hGap12,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${row['day_of_week'] == 0 ? 'Chủ nhật' : 'Thứ ${(row['day_of_week'] as num? ?? 0) + 1}'} · ${teacherTime(row['start_time'])}–${teacherTime(row['end_time'])}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    AppSpacing.vGap4,
                                    Text(
                                      [
                                        if ('${row['room'] ?? ''}'.isNotEmpty)
                                          '${row['room']}',
                                        row['is_active'] == false
                                            ? 'Ngừng áp dụng'
                                            : 'Đang áp dụng',
                                      ].join(' · '),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (detail.canManage)
                                PopupMenuButton<String>(
                                  tooltip: 'Thao tác lịch dạy',
                                  onSelected: (action) {
                                    if (action == 'edit') {
                                      onEdit(row);
                                    } else {
                                      onDelete('${row['id']}');
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Chỉnh sửa'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Xóa lịch lặp'),
                                    ),
                                  ],
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
        ),
      ),
      if (detail.canManage)
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg),
          child: OutlinedButton.icon(
            onPressed: onGenerate,
            icon: const Icon(Icons.event_repeat),
            label: const Text('Sinh buổi học từ lịch lặp'),
          ),
        ),
    ],
  );
}
