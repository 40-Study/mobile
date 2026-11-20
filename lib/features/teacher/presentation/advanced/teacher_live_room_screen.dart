import 'dart:async';

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_live_tools.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

class TeacherLiveRoomScreen extends StatefulWidget {
  const TeacherLiveRoomScreen({
    super.key,
    required this.sessionId,
    required this.joinData,
    this.api,
  });
  final String sessionId;
  final Map<String, dynamic> joinData;
  final TeacherApi? api;
  @override
  State<TeacherLiveRoomScreen> createState() => _TeacherLiveRoomScreenState();
}

class _TeacherLiveRoomScreenState extends State<TeacherLiveRoomScreen> {
  late final api = widget.api ?? TeacherApi();
  lk.Room? room;
  lk.EventsListener<lk.RoomEvent>? listener;
  Object? error;
  bool connecting = false, connected = false, working = false;
  int dataRevision = 0;
  bool get moderator =>
      const ['teacher', 'host', 'instructor'].contains(widget.joinData['role']);
  bool get reconnecting =>
      room?.connectionState == lk.ConnectionState.reconnecting;
  @override
  void dispose() {
    final activeRoom = room;
    activeRoom?.removeListener(changed);
    final roomListener = listener;
    unawaited(() async {
      try {
        await roomListener?.dispose();
        try {
          await activeRoom?.disconnect();
        } finally {
          await activeRoom?.dispose();
        }
      } catch (_) {
        // Disposal cannot report a recoverable media action to a closed screen.
      }
    }());
    unawaited(
      api
          .post('/livestream/${widget.sessionId}/leave')
          .catchError((Object _) => null),
    );
    super.dispose();
  }

  void changed() {
    if (mounted) {
      setState(
        () => connected = room?.connectionState == lk.ConnectionState.connected,
      );
    }
  }

  Future<void> connect() async {
    setState(() {
      connecting = true;
      error = null;
    });
    try {
      final room = this.room ??= lk.Room();
      room.removeListener(changed);
      room.addListener(changed);
      await listener?.dispose();
      if (!mounted) return;
      listener = room.createListener()
        ..on<lk.DataReceivedEvent>((event) {
          if (event.topic == 'lk-chat-message' || event.topic == 'whiteboard') {
            if (mounted) setState(() => dataRevision++);
          }
        });
      await room.connect(
        '${widget.joinData['server_url']}',
        '${widget.joinData['token']}',
      );
      if (mounted) setState(() => connected = true);
    } catch (e) {
      if (mounted) setState(() => error = e);
    } finally {
      if (mounted) setState(() => connecting = false);
    }
  }

  Future<void> media(Future<void> Function() callback) async {
    setState(() => working = true);
    try {
      await callback();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Không bật được thiết bị. Kiểm tra quyền camera/micro. ${teacherErrorMessage(e)}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final participants = <lk.Participant>[
      if (room?.localParticipant != null) room!.localParticipant!,
      ...?room?.remoteParticipants.values,
    ];
    final videos = participants
        .expand((p) => p.videoTrackPublications.map((pub) => (p, pub.track)))
        .where((entry) => entry.$2 is lk.VideoTrack)
        .toList();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Phòng học'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Video'),
              Tab(text: 'Trò chuyện'),
              Tab(text: 'Bảng trắng'),
            ],
          ),
        ),
        body: Column(
          children: [
            if (!connected)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      reconnecting
                          ? 'Đang kết nối lại. Vui lòng giữ màn hình mở.'
                          : connecting
                          ? 'Đang kết nối…'
                          : 'Camera và micro mặc định tắt. Bật sau khi vào phòng.',
                    ),
                    if (error != null) Text(teacherErrorMessage(error!)),
                    FilledButton(
                      onPressed: connecting || reconnecting ? null : connect,
                      child: Text(
                        reconnecting
                            ? 'Đang kết nối lại…'
                            : 'Kết nối phòng học',
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: videos.isEmpty
                            ? const Center(
                                child: Text(
                                  'Chưa có hình ảnh. Bật camera để bắt đầu.',
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(12),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: videos.length > 1 ? 2 : 1,
                                      childAspectRatio: 3 / 4,
                                    ),
                                itemCount: videos.length,
                                itemBuilder: (context, index) {
                                  final entry = videos[index];
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      lk.VideoTrackRenderer(
                                        entry.$2! as lk.VideoTrack,
                                      ),
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: ColoredBox(
                                          color: Colors.black54,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              entry.$1.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                      if (connected)
                        SafeArea(
                          top: false,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            children: [
                              IconButton.filledTonal(
                                tooltip:
                                    room?.localParticipant
                                            ?.isMicrophoneEnabled() ==
                                        true
                                    ? 'Tắt micro'
                                    : 'Bật micro',
                                onPressed: working
                                    ? null
                                    : () => media(() async {
                                        await room?.localParticipant
                                            ?.setMicrophoneEnabled(
                                              !(room?.localParticipant
                                                      ?.isMicrophoneEnabled() ??
                                                  false),
                                            );
                                      }),
                                icon: Icon(
                                  room?.localParticipant
                                              ?.isMicrophoneEnabled() ==
                                          true
                                      ? Icons.mic
                                      : Icons.mic_off,
                                ),
                              ),
                              IconButton.filledTonal(
                                tooltip:
                                    room?.localParticipant?.isCameraEnabled() ==
                                        true
                                    ? 'Tắt camera'
                                    : 'Bật camera',
                                onPressed: working
                                    ? null
                                    : () => media(() async {
                                        await room?.localParticipant
                                            ?.setCameraEnabled(
                                              !(room?.localParticipant
                                                      ?.isCameraEnabled() ??
                                                  false),
                                            );
                                      }),
                                icon: Icon(
                                  room?.localParticipant?.isCameraEnabled() ==
                                          true
                                      ? Icons.videocam
                                      : Icons.videocam_off,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Thành viên',
                                onPressed: () => teacherPush<void>(
                                  context,
                                  TeacherLiveParticipantsScreen(
                                    api: api,
                                    sessionId: widget.sessionId,
                                    canManage: moderator,
                                  ),
                                ),
                                icon: const Icon(Icons.people_outline),
                              ),
                              IconButton.filled(
                                tooltip: 'Rời phòng',
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.call_end),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  TeacherLiveChat(
                    api: api,
                    sessionId: widget.sessionId,
                    revision: dataRevision,
                    canManage: moderator,
                  ),
                  TeacherLiveWhiteboard(
                    api: api,
                    sessionId: widget.sessionId,
                    revision: dataRevision,
                    canManage: moderator,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TeacherLiveParticipantsScreen extends StatefulWidget {
  const TeacherLiveParticipantsScreen({
    super.key,
    required this.sessionId,
    required this.canManage,
    this.api,
  });
  final String sessionId;
  final bool canManage;
  final TeacherApi? api;
  @override
  State<TeacherLiveParticipantsScreen> createState() =>
      _TeacherLiveParticipantsScreenState();
}

class _TeacherLiveParticipantsScreenState
    extends State<TeacherLiveParticipantsScreen> {
  late final api = widget.api ?? TeacherApi();
  int revision = 0;
  bool busy = false;
  Future<void> act(Map<String, dynamic> person, String action) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          action == 'kick'
              ? 'Mời người này rời phòng?'
              : 'Tắt micro người này?',
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
    setState(() => busy = true);
    try {
      await api.post(
        '/livestream/${widget.sessionId}/$action',
        data: {
          'user_id': person['user_id'] ?? person['identity'],
          'action': action,
        },
      );
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Người tham gia'),
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
      load: () => api.get('/livestream/${widget.sessionId}/participants'),
      builder: (context, raw) {
        final items = teacherList(raw, keys: const ['participants']);
        return ListView(
          children: items
              .map(
                (e) => ListTile(
                  title: Text('${e['name'] ?? e['user_name'] ?? ''}'),
                  subtitle: Text('${e['role'] ?? ''}'),
                  trailing: widget.canManage
                      ? PopupMenuButton<String>(
                          enabled: !busy,
                          onSelected: (v) => act(e, v),
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'mute',
                              child: Text('Tắt micro'),
                            ),
                            PopupMenuItem(
                              value: 'kick',
                              child: Text('Mời rời phòng'),
                            ),
                          ],
                        )
                      : null,
                ),
              )
              .toList(),
        );
      },
    ),
  );
}
