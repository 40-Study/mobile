import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/widgets/empty_state.dart';

class TeacherDiscussionsScreen extends StatefulWidget {
  const TeacherDiscussionsScreen({super.key, this.api, this.lessonId});
  final TeacherApi? api;
  final String? lessonId;
  @override
  State<TeacherDiscussionsScreen> createState() =>
      _TeacherDiscussionsScreenState();
}

class _TeacherDiscussionsScreenState extends State<TeacherDiscussionsScreen> {
  late final api = widget.api ?? TeacherApi();
  int page = 1, revision = 0;
  Future<void> create() async {
    final title = TextEditingController(), content = TextEditingController();
    bool saving = false;
    String? error;
    final route = DialogRoute<void>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('Tạo thảo luận'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  maxLength: 255,
                  decoration: const InputDecoration(labelText: 'Tiêu đề'),
                ),
                TextField(
                  controller: content,
                  minLines: 3,
                  maxLines: 8,
                  decoration: const InputDecoration(labelText: 'Nội dung'),
                ),
                if (error != null)
                  Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialog),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (title.text.trim().length < 3 ||
                          content.text.trim().isEmpty) {
                        update(
                          () => error =
                              'Nhập tiêu đề ít nhất 3 ký tự và nội dung.',
                        );
                        return;
                      }
                      update(() => saving = true);
                      try {
                        await api.post(
                          '/discussions',
                          data: {
                            'title': title.text.trim(),
                            'content': content.text.trim(),
                            'category': 'qna',
                            if (widget.lessonId != null)
                              'lesson_id': widget.lessonId,
                          },
                        );
                        if (dialog.mounted) Navigator.pop(dialog);
                        if (mounted) setState(() => revision++);
                      } catch (e) {
                        if (dialog.mounted) {
                          update(() {
                            error = teacherErrorMessage(e);
                            saving = false;
                          });
                        }
                      }
                    },
              child: Text(saving ? 'Đang đăng…' : 'Đăng'),
            ),
          ],
        ),
      ),
    );
    await Navigator.of(context, rootNavigator: true).push(route);
    await route.completed;
    title.dispose();
    content.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Thảo luận & hỏi đáp'),
      actions: [
        IconButton(
          tooltip: 'Tải lại',
          onPressed: () => setState(() => revision++),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: create,
      icon: const Icon(Icons.add),
      label: const Text('Đăng câu hỏi'),
    ),
    body: TeacherAsyncView<dynamic>(
      refreshToken: revision,
      loading: const TeacherListPlaceholder(),
      load: () => api.get(
        widget.lessonId == null
            ? '/discussions'
            : '/lessons/${widget.lessonId}/discussions',
        query: {'page': page, 'page_size': 20},
      ),
      builder: (context, raw) {
        final posts = teacherList(raw, keys: const ['posts']);
        final total =
            (teacherMap(raw)['total'] as num?)?.toInt() ?? posts.length;
        return ListView(
          padding: const EdgeInsets.only(bottom: 90),
          children: [
            if (posts.isEmpty)
              EmptyState(
                style: EmptyStateStyle.inline,
                title: 'Cùng trao đổi bài học',
                message: 'Đặt câu hỏi và chia sẻ cách học với cộng đồng.',
                actionLabel: 'Đăng câu hỏi',
                onAction: create,
              ),
            ...posts.map(
              (e) => ListTile(
                title: Text('${e['title']}'),
                subtitle: Text(
                  '${e['author_name']} · ${e['reply_count'] ?? 0} trả lời',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await teacherPush<void>(
                    context,
                    TeacherDiscussionScreen(api: api, slug: '${e['slug']}'),
                  );
                  if (mounted) setState(() => revision++);
                },
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
                  child: const Text('Trước'),
                ),
                Text('Trang $page'),
                TextButton(
                  onPressed: page * 20 < total
                      ? () => setState(() {
                          page++;
                          revision++;
                        })
                      : null,
                  child: const Text('Tiếp'),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}

class TeacherDiscussionScreen extends StatefulWidget {
  const TeacherDiscussionScreen({super.key, required this.slug, this.api});
  final String slug;
  final TeacherApi? api;
  @override
  State<TeacherDiscussionScreen> createState() =>
      _TeacherDiscussionScreenState();
}

class _TeacherDiscussionScreenState extends State<TeacherDiscussionScreen> {
  late final api = widget.api ?? TeacherApi();
  final input = TextEditingController();
  int revision = 0;
  bool sending = false;
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Widget comment(Map<String, dynamic> e, {bool nested = false}) => Padding(
    padding: EdgeInsets.fromLTRB(nested ? 16 : 0, 12, 0, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${e['author_name'] ?? ''}',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        SelectableText('${e['content'] ?? ''}'),
        ...teacherList(
          e,
          keys: const ['replies'],
        ).map((e) => comment(e, nested: true)),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Chi tiết thảo luận'),
      actions: [
        IconButton(
          tooltip: 'Tải lại',
          onPressed: () => setState(() => revision++),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: TeacherAsyncView<dynamic>(
      key: ValueKey(revision),
      load: () => api.get('/discussions/${widget.slug}'),
      builder: (context, raw) {
        final post = teacherMap(raw);
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '${post['title'] ?? ''}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('${post['author_name'] ?? ''}'),
            const SizedBox(height: 20),
            SelectableText('${post['content'] ?? ''}'),
            const TeacherSectionTitle(title: 'Trả lời'),
            ...teacherList(post, keys: const ['comments']).map(comment),
            TextField(
              controller: input,
              minLines: 2,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Viết trả lời'),
            ),
            FilledButton(
              onPressed: sending
                  ? null
                  : () async {
                      if (input.text.trim().isEmpty) return;
                      setState(() => sending = true);
                      try {
                        await api.post(
                          '/discussions/${widget.slug}/comments',
                          data: {'content': input.text.trim()},
                        );
                        if (!mounted) return;
                        input.clear();
                        if (mounted) setState(() => revision++);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(teacherErrorMessage(e))),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => sending = false);
                      }
                    },
              child: Text(sending ? 'Đang gửi…' : 'Gửi trả lời'),
            ),
          ],
        );
      },
    ),
  );
}
