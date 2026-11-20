import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

import 'teacher_conversation_screen.dart';

class TeacherContactPickerScreen extends StatefulWidget {
  const TeacherContactPickerScreen({super.key, required this.api});
  final TeacherApi api;
  @override
  State<TeacherContactPickerScreen> createState() =>
      _TeacherContactPickerScreenState();
}

class _TeacherContactPickerScreenState
    extends State<TeacherContactPickerScreen> {
  bool busy = false;
  int page = 1, revision = 0;
  bool byClass = true;
  String? selectedClass;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nhắn tin cho học viên')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Theo lớp')),
              ButtonSegment(value: false, label: Text('Khóa học cá nhân')),
            ],
            selected: {byClass},
            onSelectionChanged: busy
                ? null
                : (value) => setState(() {
                    byClass = value.first;
                    page = 1;
                    revision++;
                  }),
          ),
        ),
        if (byClass)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TeacherAsyncView<List<TeacherClassData>>(
              load: () => teacherAssignedClasses(widget.api),
              builder: (context, classes) => DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Chọn lớp bạn đang dạy',
                ),
                items: classes
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: busy
                    ? null
                    : (value) => setState(() {
                        selectedClass = value;
                        page = 1;
                        revision++;
                      }),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Expanded(
          child: byClass && selectedClass == null
              ? const Center(child: Text('Chọn lớp để tìm học viên.'))
              : TeacherAsyncView<dynamic>(
                  key: ValueKey(revision),
                  load: () => widget.api.get(
                    byClass
                        ? '/classes/$selectedClass/students'
                        : '/teachers/me/students',
                    query: {'page': page, 'page_size': 50},
                  ),
                  builder: (context, raw) {
                    final students = teacherList(raw, keys: const ['students']);
                    final total =
                        (teacherMap(raw)['total'] as num?)?.toInt() ??
                        students.length;
                    return ListView(
                      children: [
                        if (students.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('Chưa có học viên để liên hệ.'),
                          ),
                        ...students.map(
                          (e) => ListTile(
                            title: Text(
                              '${e['name'] ?? e['full_name'] ?? 'Học viên'}',
                            ),
                            subtitle: Text(
                              '${e['class_name'] ?? e['course_name'] ?? ''}',
                            ),
                            enabled: !busy,
                            onTap: () async {
                              setState(() => busy = true);
                              try {
                                final item = teacherMap(
                                  await widget.api.post(
                                    '/conversations/direct',
                                    data: {
                                      'user_id': byClass
                                          ? e['student_id']
                                          : e['id'],
                                    },
                                  ),
                                );
                                if (!context.mounted) return;
                                await teacherPush<void>(
                                  context,
                                  TeacherConversationScreen(
                                    api: widget.api,
                                    conversationId: '${item['id']}',
                                    title:
                                        '${e['name'] ?? e['full_name'] ?? 'Học viên'}',
                                  ),
                                );
                              } catch (error) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(teacherErrorMessage(error)),
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => busy = false);
                              }
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
                            Text('$page'),
                            TextButton(
                              onPressed: page * 50 < total
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
        ),
      ],
    ),
  );
}
