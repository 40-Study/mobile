import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/classes/widgets/teacher_class_elements.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherClassSessionsPanel extends StatelessWidget {
  const TeacherClassSessionsPanel({
    super.key,
    required this.detail,
    required this.load,
    required this.onCreate,
    required this.onOpen,
  });
  final TeacherClassData detail;
  final Future<List<Map<String, dynamic>>> Function() load;
  final VoidCallback onCreate;
  final ValueChanged<Map<String, dynamic>> onOpen;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (detail.canManage)
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Tạo buổi học'),
          ),
        ),
      Expanded(
        child: TeacherAsyncView<List<Map<String, dynamic>>>(
          load: load,
          builder: (context, sessions) => sessions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: TeacherClassPanel(
                    TeacherClassEmpty(
                      Icons.event_outlined,
                      'Chưa có buổi học.',
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: sessions.length,
                  separatorBuilder: (_, _) => AppSpacing.vGap12,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return TeacherClassPanel(
                      ListTile(
                        contentPadding: const EdgeInsets.all(AppSpacing.lg),
                        leading: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: AppRadius.borderMd,
                          ),
                          child: Icon(
                            Icons.event_note_outlined,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(
                          '${session['topic'] ?? 'Buổi học'}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${teacherClassDate(session['date'])} · ${teacherTime(session['start_time'])}–${teacherTime(session['end_time'])}',
                              ),
                              AppSpacing.vGap8,
                              TeacherClassStatus(
                                teacherStatus(session['status']),
                                muted: [
                                  'cancelled',
                                  'completed',
                                ].contains(session['status']),
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => onOpen(session),
                      ),
                      padding: EdgeInsets.zero,
                    );
                  },
                ),
        ),
      ),
    ],
  );
}
