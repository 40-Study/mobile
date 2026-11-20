import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_realtime.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

class TeacherConversationScreen extends StatefulWidget {
  const TeacherConversationScreen({
    super.key,
    required this.conversationId,
    this.title = 'Hội thoại',
    this.api,
    this.realtime = true,
  });
  final String conversationId, title;
  final TeacherApi? api;
  final bool realtime;
  @override
  State<TeacherConversationScreen> createState() =>
      _TeacherConversationScreenState();
}

class _TeacherConversationScreenState extends State<TeacherConversationScreen> {
  late final api = widget.api ?? TeacherApi();
  final input = TextEditingController();
  TeacherRealtime? socket;
  bool connected = false, sending = false, blocked = false;
  int revision = 0, page = 1;
  @override
  void initState() {
    super.initState();
    if (widget.realtime) {
      socket = TeacherRealtime(
        api: api,
        channels: ['conversation:${widget.conversationId}'],
        onEvent: () {
          if (mounted) setState(() => revision++);
        },
        onStatus: (value) {
          if (mounted) setState(() => connected = value);
        },
      );
      socket!.connect();
    }
  }

  @override
  void dispose() {
    socket?.dispose();
    input.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> load() async {
    final detail = teacherMap(
      await api.get('/conversations/${widget.conversationId}'),
    );
    final messages = teacherMap(
      await api.get(
        '/conversations/${widget.conversationId}/messages',
        query: {'page': page, 'limit': 30},
      ),
    );
    blocked = detail['is_blocked'] == true;
    if (page == 1) {
      await api.post('/conversations/${widget.conversationId}/read');
    }
    return messages;
  }

  Future<void> send() async {
    if (sending || blocked || input.text.trim().isEmpty) return;
    setState(() => sending = true);
    try {
      await api.post(
        '/conversations/${widget.conversationId}/messages',
        data: {'type': 'TEXT', 'content': input.text.trim()},
      );
      if (!mounted) return;
      input.clear();
      if (mounted) {
        setState(() {
          page = 1;
          revision++;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(teacherErrorMessage(e))));
        setState(() => revision++);
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title.isEmpty ? 'Hội thoại' : widget.title),
      actions: [
        IconButton(
          tooltip: 'Tải lại',
          onPressed: () => setState(() => revision++),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: Column(
      children: [
        if (!connected)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Chưa kết nối trực tiếp. Bạn có thể tải lại tin nhắn.'),
          ),
        Expanded(
          child: TeacherAsyncView<Map<String, dynamic>>(
            refreshToken: revision,
            load: load,
            builder: (context, data) {
              final messages = teacherList(data, keys: const ['messages']);
              final total =
                  (data['total_count'] as num?)?.toInt() ?? messages.length;
              return Column(
                children: [
                  if (blocked)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Hội thoại đang bị chặn. Không thể gửi tin nhắn.',
                      ),
                    ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ...messages.reversed.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${e['sender_full_name'] ?? e['sender_name'] ?? ''}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                                SelectableText(
                                  '${e['content'] ?? '[Tệp đính kèm]'}',
                                ),
                                Text(
                                  teacherDisplayDate(e['created_at']),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: page > 1
                                  ? () => setState(() {
                                      page--;
                                      revision++;
                                    })
                                  : null,
                              child: const Text('Mới hơn'),
                            ),
                            Text('Trang $page'),
                            TextButton(
                              onPressed: page * 30 < total
                                  ? () => setState(() {
                                      page++;
                                      revision++;
                                    })
                                  : null,
                              child: const Text('Cũ hơn'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: input,
                              enabled: !blocked && !sending,
                              minLines: 1,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: 'Viết tin nhắn…',
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Gửi',
                            onPressed: blocked || sending ? null : send,
                            icon: const Icon(Icons.send),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}
