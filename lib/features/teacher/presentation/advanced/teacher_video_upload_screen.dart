import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/video_upload_controller.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

class TeacherVideoUploadScreen extends StatefulWidget {
  const TeacherVideoUploadScreen({
    super.key,
    this.api,
    this.courseId,
    this.onUploaded,
  });
  final TeacherApi? api;
  final String? courseId;
  final ValueChanged<Map<String, dynamic>>? onUploaded;
  @override
  State<TeacherVideoUploadScreen> createState() =>
      _TeacherVideoUploadScreenState();
}

class _TeacherVideoUploadScreenState extends State<TeacherVideoUploadScreen> {
  late final api = widget.api ?? TeacherApi();
  late final controller = TeacherVideoUploadController(api: api);
  String? courseId;
  PlatformFile? file;
  String? resumeId;
  int revision = 0;
  @override
  void initState() {
    super.initState();
    courseId = widget.courseId;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> pick() async {
    try {
      final selected = await FilePicker.pickFiles(type: FileType.video);
      if (mounted && selected != null) {
        setState(() => file = selected.files.single);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(teacherErrorMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('Tải video bài giảng')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Video thuộc khóa học cá nhân. Có thể tiếp tục phiên bị gián đoạn bằng đúng tệp gốc.',
          ),
          if (widget.courseId == null)
            TeacherAsyncView<List<Map<String, dynamic>>>(
              load: () async => teacherList(
                await api.get('/courses/mine', query: {'page_size': 100}),
                keys: const ['courses'],
              ),
              builder: (context, courses) => DropdownButtonFormField<String>(
                initialValue: courseId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Khóa học'),
                items: courses
                    .map(
                      (e) => DropdownMenuItem(
                        value: '${e['id']}',
                        child: Text('${e['title']}'),
                      ),
                    )
                    .toList(),
                onChanged: controller.busy
                    ? null
                    : (v) => setState(() => courseId = v),
              ),
            ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: controller.busy ? null : pick,
            icon: const Icon(Icons.video_file_outlined),
            label: Text(file?.name ?? 'Chọn video'),
          ),
          if (controller.busy || controller.session != null) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: controller.progress),
            Text('${(controller.progress * 100).round()}% đã tải'),
          ],
          if (controller.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                teacherErrorMessage(controller.error!),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (controller.result != null) ...[
            const SizedBox(height: 16),
            Text(switch (controller.result!['status']) {
              'ready' => 'Video đã sẵn sàng.',
              'failed' => 'Xử lý video thất bại. Có thể yêu cầu xử lý lại.',
              _ =>
                'Video đã tải xong, máy chủ đang xử lý. Chỉ phát được khi xử lý hoàn tất.',
            }),
            OutlinedButton(
              onPressed: () async {
                try {
                  final status = teacherMap(
                    await api.get(
                      '/videos/upload/${controller.result!['upload_id']}/status',
                    ),
                  );
                  if (mounted) {
                    setState(
                      () => controller.result = {
                        ...controller.result!,
                        ...status,
                      },
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(teacherErrorMessage(e))),
                    );
                  }
                }
              },
              child: const Text('Kiểm tra xử lý'),
            ),
            if (widget.onUploaded != null)
              FilledButton(
                onPressed: controller.result!['status'] != 'ready'
                    ? null
                    : () {
                        widget.onUploaded!(controller.result!);
                        Navigator.pop(context);
                      },
                child: const Text('Dùng video này'),
              ),
            if (controller.result!['status'] == 'failed')
              OutlinedButton(
                onPressed: () async {
                  try {
                    await api.post(
                      '/videos/upload/${controller.result!['upload_id']}/reprocess',
                    );
                    if (mounted) {
                      setState(
                        () => controller.result!['status'] = 'processing',
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(teacherErrorMessage(e))),
                      );
                    }
                  }
                },
                child: const Text('Yêu cầu xử lý lại'),
              ),
          ] else
            FilledButton(
              onPressed:
                  controller.busy || file?.path == null || courseId == null
                  ? null
                  : () async {
                      await controller.upload(
                        file: File(file!.path!),
                        fileName: file!.name,
                        resourceId: courseId!,
                        resumeId:
                            resumeId ??
                            controller.session?['upload_id']?.toString(),
                      );
                      if (mounted) setState(() => revision++);
                    },
              child: Text(
                resumeId != null || controller.session != null
                    ? 'Tiếp tục tải'
                    : 'Bắt đầu tải',
              ),
            ),
          if (controller.busy)
            TextButton(
              onPressed: controller.pause,
              child: const Text('Tạm dừng'),
            ),
          if (!controller.busy &&
              controller.session != null &&
              controller.result == null)
            TextButton(
              onPressed: () async {
                try {
                  await controller.abort();
                  if (mounted) setState(() => resumeId = null);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(teacherErrorMessage(e))),
                    );
                  }
                }
              },
              child: const Text('Hủy phiên tải'),
            ),
          const TeacherSectionTitle(title: 'Phiên tải chưa hoàn tất'),
          TeacherAsyncView<List<Map<String, dynamic>>>(
            key: ValueKey(revision),
            load: () async =>
                teacherList(await api.get('/videos/upload/incomplete')),
            builder: (context, items) => Column(
              children: [
                if (items.isEmpty) const Text('Không có phiên tải dang dở.'),
                ...items.map(
                  (e) => ListTile(
                    title: Text(
                      '${e['original_file_name'] ?? e['file_name'] ?? 'Video'}',
                    ),
                    subtitle: Text('${e['status'] ?? ''}'),
                    trailing: const Icon(Icons.restore),
                    onTap: controller.busy
                        ? null
                        : () {
                            if ([
                              'uploaded',
                              'processing',
                              'ready',
                              'failed',
                            ].contains(e['status'])) {
                              setState(() {
                                controller.result = e;
                                resumeId = null;
                              });
                            } else {
                              setState(() {
                                resumeId = '${e['upload_id']}';
                                controller.result = null;
                              });
                              pick();
                            }
                          },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
