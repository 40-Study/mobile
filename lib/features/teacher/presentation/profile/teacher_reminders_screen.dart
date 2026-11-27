import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_preview_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherRemindersScreen extends StatefulWidget {
  const TeacherRemindersScreen({super.key, required this.api});
  final TeacherApi api;
  @override
  State<TeacherRemindersScreen> createState() => _TeacherRemindersScreenState();
}

class _TeacherRemindersScreenState extends State<TeacherRemindersScreen> {
  final _saving = <Object?>{};
  final _errors = <Object?, ({Object error, bool enabled})>{};

  bool get _readOnly => widget.api is TeacherPreviewApi;

  Future<void> _update(Map<String, dynamic> row, bool enabled) async {
    final key = row['event_type'];
    if (_readOnly || _saving.contains(key)) return;
    setState(() {
      _saving.add(key);
      _errors.remove(key);
    });
    try {
      final response = await widget.api.put(
        '/reminders/settings',
        data: {
          'event_type': row['event_type'],
          'remind_before_minutes': _reminderMinutes(
            row['remind_before_minutes'],
          ),
          'channels': _reminderChannels(row['channels']),
          'is_enabled': enabled,
        },
      );
      final saved = teacherMap(response);
      if (saved['is_enabled'] is! bool) {
        throw const FormatException('Chưa xác nhận được cài đặt nhắc lịch.');
      }
      if (mounted) {
        setState(() {
          for (final field in [
            'is_enabled',
            'remind_before_minutes',
            'channels',
          ]) {
            if (saved.containsKey(field)) row[field] = saved[field];
          }
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _errors[key] = (error: error, enabled: enabled));
      }
    } finally {
      if (mounted) setState(() => _saving.remove(key));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nhắc lịch')),
    body: TeacherAsyncView<List<Map<String, dynamic>>>(
      load: () async =>
          teacherList(await widget.api.get('/reminders/settings')),
      loading: const TeacherListPlaceholder(),
      builder: (context, rows) => ListView(
        padding: AppSpacing.paddingLg,
        children: [
          if (_readOnly)
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.science_outlined),
              title: Text('Dữ liệu mẫu · Chỉ xem giao diện'),
            ),
          if (rows.isEmpty)
            const TeacherEmptyStateInline(
              icon: Icons.notifications_off_outlined,
              message: 'Chưa có mục nhắc lịch để bật hoặc tắt.',
            ),
          for (final row in rows) ...[
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(switch (row['event_type']) {
                'class' || 'class_session' => 'Buổi học',
                'livestream' => 'Lớp trực tuyến',
                'assignment' => 'Bài tập',
                'quiz' => 'Kiểm tra',
                _ => '${row['event_type']}',
              }),
              subtitle: Text(_reminderDescription(row)),
              value: row['is_enabled'] == true,
              onChanged: _readOnly || _saving.contains(row['event_type'])
                  ? null
                  : (enabled) => _update(row, enabled),
            ),
            if (_saving.contains(row['event_type']))
              const LinearProgressIndicator(),
            if (_errors[row['event_type']] case final failure?)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teacherErrorMessage(failure.error),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _update(row, failure.enabled),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            if (!identical(row, rows.last)) const Divider(height: 1),
          ],
        ],
      ),
    ),
  );
}

String _channelLabel(dynamic channel) => switch (channel) {
  'push' => 'Thông báo trên thiết bị',
  'in_app' => 'Thông báo trong ứng dụng',
  'email' => 'Email',
  'sms' => 'Tin nhắn SMS',
  _ => 'Kênh khác',
};

List<int> _reminderMinutes(Object? value) => switch (value) {
  int minutes => [minutes],
  List<Object?> values => values.whereType<int>().toList(),
  _ => const [],
};

List<String> _reminderChannels(Object? value) => switch (value) {
  String channel => [channel],
  List<Object?> values => values.whereType<String>().toList(),
  _ => const [],
};

String _reminderDescription(Map<String, dynamic> row) {
  final minutes = _reminderMinutes(row['remind_before_minutes']);
  final channels = _reminderChannels(row['channels']);
  final details = [
    if (minutes.isNotEmpty) 'Nhắc trước ${minutes.join(', ')} phút',
    if (channels.isNotEmpty) channels.map(_channelLabel).join(', '),
  ];
  return details.isEmpty
      ? 'Chưa có thời gian và kênh nhắc'
      : details.join('\n');
}
