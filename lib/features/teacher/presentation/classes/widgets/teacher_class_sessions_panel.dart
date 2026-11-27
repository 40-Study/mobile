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
    this.refreshToken,
  });
  final TeacherClassData detail;
  final Future<List<Map<String, dynamic>>> Function() load;
  final VoidCallback onCreate;
  final ValueChanged<Map<String, dynamic>> onOpen;
  final Object? refreshToken;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (detail.canManage)
        Padding(
          padding: AppSpacing.paddingHorizontalLg,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Tạo buổi lẻ'),
            ),
          ),
        ),
      Expanded(
        child: TeacherAsyncView<List<Map<String, dynamic>>>(
          load: load,
          refreshToken: refreshToken,
          builder: (context, sessions) {
            if (sessions.isEmpty) {
              return const Padding(
                padding: AppSpacing.paddingLg,
                child: TeacherClassPanel(
                  TeacherClassEmpty(
                    Icons.event_outlined,
                    'Chưa có buổi cụ thể.',
                  ),
                ),
              );
            }
            final now = DateTime.now();
            final upcoming = <Map<String, dynamic>>[];
            final history = <Map<String, dynamic>>[];
            for (final session in sessions) {
              (_isUpcoming(session, now) ? upcoming : history).add(session);
            }
            upcoming.sort((a, b) => _sortKey(a).compareTo(_sortKey(b)));
            history.sort((a, b) => _sortKey(b).compareTo(_sortKey(a)));
            final items = <Object>[
              if (upcoming.isNotEmpty) ...['Sắp tới và đang dạy', ...upcoming],
              if (history.isNotEmpty) ...['Đã qua và đã hủy', ...history],
            ];
            return ListView.separated(
              key: PageStorageKey('class-sessions-${detail.id}'),
              padding: AppSpacing.paddingLg,
              itemCount: items.length,
              separatorBuilder: (_, _) => AppSpacing.vGap12,
              itemBuilder: (context, index) {
                final item = items[index];
                if (item is String) {
                  return Text(
                    item,
                    style: Theme.of(context).textTheme.titleSmall,
                  );
                }
                final session = item as Map<String, dynamic>;
                final status = session['status'];
                final wasScheduled =
                    status == 'scheduled' && !_isUpcoming(session, now);
                final topic = '${session['topic'] ?? ''}'.trim();
                final date = teacherClassDate(session['date']);
                final start = teacherTime(session['start_time']);
                final end = teacherTime(session['end_time']);
                return TeacherClassPanel(
                  ListTile(
                    contentPadding: AppSpacing.paddingHorizontalLg,
                    title: Text(
                      topic.isEmpty ? 'Buổi học' : topic,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$date · $start–$end'),
                          AppSpacing.vGap4,
                          TeacherClassStatus(
                            wasScheduled
                                ? 'Quá giờ · Chưa bắt đầu'
                                : teacherStatus(status),
                            muted: ['cancelled', 'completed'].contains(status),
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
            );
          },
        ),
      ),
    ],
  );

  bool _isUpcoming(Map<String, dynamic> session, DateTime now) {
    if (['completed', 'cancelled'].contains(session['status'])) return false;
    final date = DateTime.tryParse('${session['date']}');
    if (date == null) return session['status'] == 'in_progress';
    final end = teacherTime(session['end_time']).split(':');
    final endTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.tryParse(end.first) ?? 23,
      int.tryParse(end.last) ?? 59,
    );
    return endTime.isAfter(now);
  }

  String _sortKey(Map<String, dynamic> session) =>
      '${session['date']} ${teacherTime(session['start_time'])}';
}
