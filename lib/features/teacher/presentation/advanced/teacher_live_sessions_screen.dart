import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_live_room_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/widgets/empty_state.dart';

class TeacherLiveSessionsScreen extends StatefulWidget {
  const TeacherLiveSessionsScreen({super.key, this.api, this.classId});
  final TeacherApi? api;
  final String? classId;
  @override
  State<TeacherLiveSessionsScreen> createState() =>
      _TeacherLiveSessionsScreenState();
}

class _TeacherLiveSessionsScreenState extends State<TeacherLiveSessionsScreen> {
  late final api = widget.api ?? TeacherApi();
  int revision = 0, page = 1;
  Future<void> create() async {
    final title = TextEditingController();
    String? classId = widget.classId, error;
    bool saving = false;
    final route = DialogRoute<void>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('Tạo phòng học'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  maxLength: 255,
                  decoration: const InputDecoration(labelText: 'Tên buổi học'),
                ),
                if (widget.classId == null)
                  TeacherAsyncView<dynamic>(
                    load: () => api.get(
                      '/classes/me',
                      query: {'page': 1, 'page_size': 100},
                    ),
                    builder: (context, raw) {
                      final classes = teacherList(raw, keys: const ['classes']);
                      return DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Lớp học'),
                        items: classes
                            .map(
                              (e) => DropdownMenuItem(
                                value: '${e['id']}',
                                child: Text(
                                  '${e['name']}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: saving
                            ? null
                            : (v) => update(() => classId = v),
                      );
                    },
                  ),
                const Text(
                  'Phòng được tạo ở trạng thái chờ. Chỉ bắt đầu khi bạn sẵn sàng.',
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
                      if (title.text.trim().length < 3 || classId == null) {
                        update(
                          () => error =
                              'Nhập tên ít nhất 3 ký tự và chọn lớp học.',
                        );
                        return;
                      }
                      update(() => saving = true);
                      try {
                        await api.post(
                          '/livestream',
                          data: {
                            'title': title.text.trim(),
                            'class_id': classId,
                            'max_viewers': 100,
                            'is_recorded': false,
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
              child: Text(saving ? 'Đang tạo…' : 'Tạo phòng'),
            ),
          ],
        ),
      ),
    );
    await Navigator.of(context, rootNavigator: true).push(route);
    await route.completed;
    title.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Phòng học trực tuyến'),
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
      label: const Text('Tạo phòng'),
    ),
    body: TeacherAsyncView<dynamic>(
      refreshToken: revision,
      loading: const TeacherListPlaceholder(),
      load: () =>
          api.get('/livestream', query: {'page': page, 'page_size': 20}),
      builder: (context, raw) {
        final all = teacherList(raw);
        final items = widget.classId == null
            ? all
            : all.where((e) => e['class_id'] == widget.classId).toList();
        final total = (teacherMap(raw)['total'] as num?)?.toInt() ?? all.length;
        return ListView(
          padding: const EdgeInsets.only(bottom: 90),
          children: [
            if (items.isEmpty)
              EmptyState(
                style: EmptyStateStyle.inline,
                title: 'Chưa có buổi trực tuyến trong trang này',
                message:
                    'Tạo phòng cho lớp của bạn hoặc xem các trang còn lại.',
                actionLabel: 'Tạo phòng học',
                onAction: create,
              ),
            ...items.map(
              (e) => ListTile(
                leading: Icon(
                  e['status'] == 'live'
                      ? Icons.videocam
                      : Icons.videocam_outlined,
                ),
                title: Text('${e['title']}'),
                subtitle: Text(switch (e['status']) {
                  'live' => 'Đang diễn ra',
                  'ended' => 'Đã kết thúc',
                  _ =>
                    e['is_overdue'] == true
                        ? 'Chưa bắt đầu · Đã quá giờ'
                        : 'Chưa bắt đầu',
                }),
                onTap: () async {
                  await teacherPush<void>(
                    context,
                    TeacherLiveSessionScreen(api: api, sessionId: '${e['id']}'),
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

class TeacherLiveSessionScreen extends StatefulWidget {
  const TeacherLiveSessionScreen({
    super.key,
    required this.sessionId,
    this.api,
  });
  final String sessionId;
  final TeacherApi? api;
  @override
  State<TeacherLiveSessionScreen> createState() =>
      _TeacherLiveSessionScreenState();
}

class _TeacherLiveSessionScreenState extends State<TeacherLiveSessionScreen> {
  late final api = widget.api ?? TeacherApi();
  int revision = 0;
  bool busy = false;
  Object? error;
  Future<void> action(String action) async {
    if (action == 'end' || action == 'delete') {
      final yes = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(
            action == 'end' ? 'Kết thúc buổi học?' : 'Xóa phòng học?',
          ),
          content: Text(
            action == 'end'
                ? 'Tất cả người tham gia sẽ rời phòng.'
                : 'Phòng học chưa bắt đầu sẽ bị xóa.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Quay lại'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      );
      if (yes != true || !mounted) return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (action == 'join') {
        final auth = context.read<AuthBloc>().state;
        final name = auth is AuthAuthenticated
            ? (auth.user.fullName ?? auth.user.username ?? 'Giáo viên')
            : 'Giáo viên';
        final joined = teacherMap(
          await api.post(
            '/livestream/${widget.sessionId}/join',
            data: {'name': name},
          ),
        );
        if (joined['token'] is! String || joined['server_url'] is! String) {
          throw const FormatException('Chưa nhận được thông tin phòng học.');
        }
        if (!mounted) return;
        await teacherPush<void>(
          context,
          TeacherLiveRoomScreen(
            api: api,
            sessionId: widget.sessionId,
            joinData: joined,
          ),
        );
      } else if (action == 'delete') {
        await api.delete('/livestream/${widget.sessionId}');
        if (mounted) Navigator.pop(context);
      } else {
        await api.post('/livestream/${widget.sessionId}/$action');
      }
      if (mounted) setState(() => revision++);
    } catch (e) {
      if (mounted) setState(() => error = e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Buổi học trực tuyến'),
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
      load: () => api.get('/livestream/${widget.sessionId}'),
      builder: (context, raw) {
        final item = teacherMap(raw);
        final auth = context.read<AuthBloc>().state;
        final own =
            auth is AuthAuthenticated && auth.user.id == item['host_id'];
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '${item['title'] ?? ''}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text('${item['description'] ?? ''}'),
            Text(switch (item['status']) {
              'scheduled' => 'Chưa bắt đầu',
              'live' => 'Đang diễn ra',
              'ended' => 'Đã kết thúc',
              _ => 'Đang cập nhật trạng thái',
            }),
            if (item['scheduled_at'] != null)
              Text('Lịch hẹn: ${teacherDisplayDate(item['scheduled_at'])}'),
            if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  teacherErrorMessage(error!),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (item['status'] == 'live')
              FilledButton.icon(
                onPressed: busy ? null : () => action('join'),
                icon: const Icon(Icons.videocam),
                label: const Text('Vào phòng học'),
              ),
            if (own && item['status'] == 'scheduled') ...[
              FilledButton(
                onPressed: busy ? null : () => action('start'),
                child: const Text('Bắt đầu buổi học'),
              ),
              TextButton(
                onPressed: busy ? null : () => action('delete'),
                child: const Text('Xóa phòng chưa bắt đầu'),
              ),
            ],
            if (own && item['status'] == 'live')
              OutlinedButton(
                onPressed: busy ? null : () => action('end'),
                child: const Text('Kết thúc buổi học'),
              ),
            if (item['status'] == 'ended')
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text('Buổi học đã kết thúc.'),
              ),
          ],
        );
      },
    ),
  );
}
