import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

class TeacherLiveChat extends StatefulWidget {
  const TeacherLiveChat({
    super.key,
    required this.api,
    required this.sessionId,
    required this.revision,
    required this.canManage,
  });
  final TeacherApi api;
  final String sessionId;
  final int revision;
  final bool canManage;
  @override
  State<TeacherLiveChat> createState() => _TeacherLiveChatState();
}

class _TeacherLiveChatState extends State<TeacherLiveChat> {
  final input = TextEditingController();
  int revision = 0, page = 1;
  bool busy = false;
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Future<void> action(String path, {dynamic data, bool delete = false}) async {
    setState(() => busy = true);
    try {
      if (delete) {
        await widget.api.delete(path);
      } else {
        await widget.api.post(path, data: data);
      }
      if (!mounted) return;
      if (path == '/chat/send') input.clear();
      if (mounted) setState(() => revision++);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(teacherErrorMessage(e))));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: TeacherAsyncView<dynamic>(
          key: ValueKey('$revision-${widget.revision}-$page'),
          load: () => widget.api.get(
            '/chat/${widget.sessionId}/messages',
            query: {'page': page, 'page_size': 30},
          ),
          builder: (context, raw) {
            final items = teacherList(raw, keys: const ['messages']);
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (items.isEmpty)
                  const Text('Chưa có tin nhắn trong buổi học.'),
                ...items.reversed.map(
                  (e) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${e['message'] ?? ''}'),
                    subtitle: Text('${e['user_name'] ?? ''}'),
                    leading: e['is_pinned'] == true
                        ? const Icon(Icons.push_pin, size: 18)
                        : null,
                    trailing: widget.canManage
                        ? PopupMenuButton<String>(
                            enabled: !busy,
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: e['is_pinned'] == true ? 'unpin' : 'pin',
                                child: Text(
                                  e['is_pinned'] == true ? 'Bỏ ghim' : 'Ghim',
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Xóa tin nhắn'),
                              ),
                            ],
                            onSelected: (v) => action(
                              '/chat/${e['id']}${v == 'delete' ? '' : '/$v'}',
                              delete: v == 'delete',
                            ),
                          )
                        : null,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: page > 1 ? () => setState(() => page--) : null,
                      child: const Text('Mới hơn'),
                    ),
                    Text('$page'),
                    TextButton(
                      onPressed: items.length == 30
                          ? () => setState(() => page++)
                          : null,
                      child: const Text('Cũ hơn'),
                    ),
                  ],
                ),
              ],
            );
          },
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
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Nhắn trong lớp…',
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Gửi',
                onPressed: busy
                    ? null
                    : () {
                        if (input.text.trim().isNotEmpty) {
                          action(
                            '/chat/send',
                            data: {
                              'session_id': widget.sessionId,
                              'message': input.text.trim(),
                            },
                          );
                        }
                      },
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class TeacherLiveWhiteboard extends StatefulWidget {
  const TeacherLiveWhiteboard({
    super.key,
    required this.api,
    required this.sessionId,
    required this.revision,
    required this.canManage,
  });
  final TeacherApi api;
  final String sessionId;
  final int revision;
  final bool canManage;
  @override
  State<TeacherLiveWhiteboard> createState() => _TeacherLiveWhiteboardState();
}

class _TeacherLiveWhiteboardState extends State<TeacherLiveWhiteboard> {
  List<Map<String, dynamic>> elements = [];
  Map<String, dynamic> appState = {};
  List<Offset>? stroke;
  int version = 0;
  bool busy = false, loaded = false, dirty = false;
  Object? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void didUpdateWidget(covariant TeacherLiveWhiteboard old) {
    super.didUpdateWidget(old);
    if (old.revision != widget.revision && !dirty && !busy) load();
  }

  Future<void> load() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      final snapshot = teacherMap(
        await widget.api.get('/whiteboard/${widget.sessionId}/snapshot'),
      );
      if (mounted) {
        setState(() {
          elements = teacherList(snapshot, keys: const ['elements']);
          appState = teacherMap(snapshot['app_state']);
          version = (snapshot['version'] as num?)?.toInt() ?? 0;
          dirty = false;
          loaded = true;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> save() async {
    setState(() => busy = true);
    try {
      // Check before saving because the backend accepts whole snapshots.
      final current = teacherMap(
        await widget.api.get('/whiteboard/${widget.sessionId}/snapshot'),
      );
      if (((current['version'] as num?)?.toInt() ?? 0) != version) {
        throw const FormatException(
          'Bảng đã có thay đổi từ người khác. Tải lại trước khi vẽ tiếp.',
        );
      }
      await widget.api.post(
        '/whiteboard/${widget.sessionId}/snapshot',
        data: {
          'session_id': widget.sessionId,
          'elements': elements,
          'app_state': appState,
          'version': version + 1,
        },
      );
      version++;
      dirty = false;
      await widget.api.post(
        '/whiteboard/${widget.sessionId}/event',
        data: {
          'type': 'whiteboard',
          'action': 'sync',
          'payload': jsonEncode({'elements': elements, 'appState': appState}),
        },
      );
      if (mounted) setState(() => error = null);
    } catch (e) {
      if (mounted) setState(() => error = e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> lock(bool locked) async {
    setState(() => busy = true);
    try {
      await widget.api.post(
        '/livestream/${widget.sessionId}/${locked ? 'lock' : 'unlock'}-whiteboard',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              locked
                  ? 'Đã khóa quyền vẽ của học viên.'
                  : 'Đã mở quyền vẽ của học viên.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => error = e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: busy ? null : load,
              icon: const Icon(Icons.refresh),
              label: const Text('Tải lại'),
            ),
            FilledButton.icon(
              onPressed: busy || !dirty ? null : save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Lưu bảng'),
            ),
            if (widget.canManage)
              PopupMenuButton<bool>(
                enabled: !busy,
                onSelected: lock,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: true, child: Text('Khóa học viên vẽ')),
                  PopupMenuItem(value: false, child: Text('Mở quyền vẽ')),
                ],
              ),
          ],
        ),
      ),
      if (dirty) const Text('Có nét vẽ chưa lưu.'),
      if (error != null)
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(teacherErrorMessage(error!)),
        ),
      if (busy) const LinearProgressIndicator(),
      Expanded(
        child: LayoutBuilder(
          builder: (context, bounds) {
            final scale = min(bounds.maxWidth / 1000, bounds.maxHeight / 700);
            return Center(
              child: SizedBox(
                width: 1000 * scale,
                height: 700 * scale,
                child: ClipRect(
                  child: ColoredBox(
                    color: Colors.white,
                    child: GestureDetector(
                      onPanStart: !loaded || busy || !widget.canManage
                          ? null
                          : (details) => setState(
                              () => stroke = [details.localPosition / scale],
                            ),
                      onPanUpdate: !loaded || busy || !widget.canManage
                          ? null
                          : (details) => setState(
                              () => stroke?.add(details.localPosition / scale),
                            ),
                      onPanEnd: !loaded || busy || !widget.canManage
                          ? null
                          : (_) => setState(() {
                              if (stroke != null && stroke!.length > 1) {
                                elements.add({
                                  'id':
                                      'mobile-${DateTime.now().microsecondsSinceEpoch}',
                                  'type': 'freedraw',
                                  'x': 0,
                                  'y': 0,
                                  'width': 1000,
                                  'height': 700,
                                  'angle': 0,
                                  'strokeColor': '#202124',
                                  'backgroundColor': 'transparent',
                                  'fillStyle': 'solid',
                                  'strokeWidth': 2,
                                  'strokeStyle': 'solid',
                                  'roughness': 0,
                                  'opacity': 100,
                                  'groupIds': <String>[],
                                  'frameId': null,
                                  'roundness': null,
                                  'seed': 0,
                                  'version': 1,
                                  'versionNonce': 0,
                                  'isDeleted': false,
                                  'boundElements': null,
                                  'updated':
                                      DateTime.now().millisecondsSinceEpoch,
                                  'link': null,
                                  'locked': false,
                                  'points': stroke!
                                      .map((p) => [p.dx, p.dy])
                                      .toList(),
                                  'pressures': <double>[],
                                  'simulatePressure': true,
                                  'lastCommittedPoint': null,
                                });
                                dirty = true;
                              }
                              stroke = null;
                            }),
                      child: CustomPaint(
                        painter: _WhiteboardPainter(
                          elements: elements,
                          stroke: stroke,
                          scale: scale,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          'Nét vẽ tay được hiển thị trong ứng dụng. Các loại nội dung khác được giữ khi lưu.',
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );
}

class _WhiteboardPainter extends CustomPainter {
  _WhiteboardPainter({
    required this.elements,
    required this.stroke,
    required this.scale,
  });
  final List<Map<String, dynamic>> elements;
  final List<Offset>? stroke;
  final double scale;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(scale);
    void draw(List<Offset> points, Color color, double width) {
      if (points.length < 2) return;
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = width
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    for (final e in elements) {
      if (e['type'] != 'freedraw' || e['isDeleted'] == true) continue;
      final points = (e['points'] as List? ?? [])
          .whereType<List<dynamic>>()
          .where((p) => p.length >= 2 && p[0] is num && p[1] is num)
          .map(
            (p) => Offset(
              (p[0] as num).toDouble() + (e['x'] as num? ?? 0),
              (p[1] as num).toDouble() + (e['y'] as num? ?? 0),
            ),
          )
          .toList();
      final hex = '${e['strokeColor'] ?? ''}'.replaceFirst('#', '');
      draw(
        points,
        Color(int.tryParse('ff$hex', radix: 16) ?? 0xff202124),
        (e['strokeWidth'] as num?)?.toDouble() ?? 2,
      );
    }
    if (stroke != null) draw(stroke!, const Color(0xff202124), 2);
  }

  @override
  bool shouldRepaint(covariant _WhiteboardPainter old) => true;
}
