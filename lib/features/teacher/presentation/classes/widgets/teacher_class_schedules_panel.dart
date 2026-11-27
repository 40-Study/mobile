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
    this.refreshToken,
  });
  final TeacherClassData detail;
  final Future<List<Map<String, dynamic>>> Function() load;
  final VoidCallback onAdd;
  final ValueChanged<Map<String, dynamic>> onEdit;
  final ValueChanged<Map<String, dynamic>> onDelete;
  final VoidCallback onGenerate;
  final Object? refreshToken;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(
          'Dùng lịch lặp theo tuần để tạo các buổi có ngày cụ thể.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      if (detail.canManage)
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Thêm lịch định kỳ'),
          ),
        ),
      TeacherAsyncView<List<Map<String, dynamic>>>(
        load: load,
        refreshToken: refreshToken,
        builder: (context, rows) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TeacherClassPanel(
              rows.isEmpty
                  ? const TeacherClassEmpty(
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
                                    padding: const EdgeInsets.all(
                                      AppSpacing.sm,
                                    ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          teacherClassScheduleSlot(row),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        if (row['effective_from'] != null)
                                          Text(
                                            row['effective_until'] != null
                                                ? '${teacherClassDate(row['effective_from'])} – ${teacherClassDate(row['effective_until'])}'
                                                : 'Từ ${teacherClassDate(row['effective_from'])}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        AppSpacing.vGap4,
                                        Text(
                                          [
                                            if ('${row['room'] ?? ''}'
                                                .isNotEmpty)
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
                                          onDelete(row);
                                        }
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Chỉnh sửa'),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Xóa lịch định kỳ'),
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
            if (detail.canManage &&
                rows.any((row) => row['is_active'] != false)) ...[
              AppSpacing.vGap16,
              OutlinedButton.icon(
                onPressed: onGenerate,
                icon: const Icon(Icons.event_repeat),
                label: const Text('Tạo các buổi từ lịch định kỳ'),
              ),
            ],
          ],
        ),
      ),
    ],
  );
}

String teacherClassScheduleSlot(Map<String, dynamic> row) {
  final day = int.tryParse('${row['day_of_week']}') ?? -1;
  final weekday = switch (day) {
    0 => 'Chủ nhật',
    >= 1 && <= 6 => 'Thứ ${day + 1}',
    _ => 'Hằng tuần',
  };
  final start = teacherTime(row['start_time']);
  final end = teacherTime(row['end_time']);
  return '$weekday · $start–$end';
}
