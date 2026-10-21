import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/widgets/empty_state.dart';

import 'teacher_contact_picker_screen.dart';
import 'teacher_conversation_screen.dart';
export 'teacher_contact_picker_screen.dart' show TeacherContactPickerScreen;
export 'teacher_conversation_screen.dart' show TeacherConversationScreen;

String _conversationName(Map<String, dynamic> item) {
  final name = item['name'];
  if (name is String && name.isNotEmpty) return name;
  return teacherList(
    item,
    keys: const ['participants'],
  ).map((e) => e['full_name'] ?? e['user_name'] ?? 'Học viên').join(', ');
}

class TeacherMessagesScreen extends StatefulWidget {
  const TeacherMessagesScreen({super.key, this.api});
  final TeacherApi? api;
  @override
  State<TeacherMessagesScreen> createState() => _TeacherMessagesScreenState();
}

class _TeacherMessagesScreenState extends State<TeacherMessagesScreen> {
  late final api = widget.api ?? TeacherApi();
  int page = 1, revision = 0;
  Future<void> _newConversation() async {
    await teacherPush<void>(context, TeacherContactPickerScreen(api: api));
    if (mounted) setState(() => revision++);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Tin nhắn'),
      actions: [
        IconButton(
          tooltip: 'Tải lại',
          onPressed: () => setState(() => revision++),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _newConversation,
      icon: const Icon(Icons.edit_outlined),
      label: const Text('Tin nhắn mới'),
    ),
    body: TeacherAsyncView<dynamic>(
      refreshToken: revision,
      loading: const TeacherListPlaceholder(),
      load: () => api.get('/conversations', query: {'page': page, 'limit': 20}),
      builder: (context, raw) {
        final items = teacherList(raw, keys: const ['conversations']);
        final total =
            (teacherMap(raw)['total_count'] as num?)?.toInt() ?? items.length;
        return ListView(
          padding: const EdgeInsets.only(bottom: 90),
          children: [
            if (items.isEmpty)
              EmptyState(
                style: EmptyStateStyle.inline,
                title: 'Bắt đầu một cuộc trò chuyện',
                message:
                    'Chọn học viên trong lớp hoặc khóa học để trao đổi bài học.',
                actionLabel: 'Chọn học viên',
                onAction: _newConversation,
              ),
            ...items.map(
              (e) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(
                  _conversationName(e).isEmpty
                      ? 'Hội thoại'
                      : _conversationName(e),
                ),
                subtitle: Text(
                  '${teacherMap(e['last_message'])['content'] ?? 'Chưa có tin nhắn'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: (e['unread_count'] as num? ?? 0) > 0
                    ? Badge(label: Text('${e['unread_count']}'))
                    : null,
                onTap: () async {
                  await teacherPush<void>(
                    context,
                    TeacherConversationScreen(
                      api: api,
                      conversationId: '${e['id']}',
                      title: _conversationName(e),
                    ),
                  );
                  if (mounted) setState(() => revision++);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: page > 1
                      ? () => setState(() {
                          page--;
                          revision++;
                        })
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('Trang $page'),
                IconButton(
                  onPressed: page * 20 < total
                      ? () => setState(() {
                          page++;
                          revision++;
                        })
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}
