import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

class TeacherRemindersScreen extends StatefulWidget {
  const TeacherRemindersScreen({super.key, required this.api});
  final TeacherApi api;
  @override
  State<TeacherRemindersScreen> createState() => _TeacherRemindersScreenState();
}

class _TeacherRemindersScreenState extends State<TeacherRemindersScreen> {
  int _revision = 0;
  bool _saving = false;
  Object? _error;
  Future<void> _update(Map<String, dynamic> row, bool enabled) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.api.put(
        '/reminders/settings',
        data: {
          'event_type': row['event_type'],
          'remind_before_minutes': row['remind_before_minutes'],
          'channels': row['channels'],
          'is_enabled': enabled,
        },
      );
      if (mounted) setState(() => _revision++);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nhắc lịch')),
    body: TeacherAsyncView<List<Map<String, dynamic>>>(
      key: ValueKey(_revision),
      load: () async =>
          teacherList(await widget.api.get('/reminders/settings')),
      builder: (context, rows) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (rows.isEmpty)
            const Text('Chưa có cấu hình nhắc lịch từ máy chủ.'),
          for (final row in rows)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(switch (row['event_type']) {
                'class' => 'Buổi học',
                'livestream' => 'Lớp trực tuyến',
                'assignment' => 'Bài tập',
                'quiz' => 'Kiểm tra',
                _ => '${row['event_type']}',
              }),
              subtitle: Text(
                'Trước ${(row['remind_before_minutes'] as List?)?.join(', ') ?? ''} phút\n'
                '${(row['channels'] as List?)?.join(', ') ?? ''}',
              ),
              value: row['is_enabled'] == true,
              onChanged: _saving ? null : (enabled) => _update(row, enabled),
            ),
          if (_saving) const LinearProgressIndicator(),
          if (_error != null)
            Text(
              teacherErrorMessage(_error!),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    ),
  );
}
