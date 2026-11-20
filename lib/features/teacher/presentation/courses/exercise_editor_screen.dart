import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'course_form_widgets.dart';
import 'editors/exercise_settings.dart';
import 'editors/testcase_editor.dart';

class TeacherExerciseEditorScreen extends StatefulWidget {
  const TeacherExerciseEditorScreen({
    super.key,
    required this.api,
    this.exerciseId,
  });
  final TeacherApi api;
  final String? exerciseId;
  @override
  State<TeacherExerciseEditorScreen> createState() =>
      _TeacherExerciseEditorScreenState();
}

class _TeacherExerciseEditorScreenState
    extends State<TeacherExerciseEditorScreen> {
  late String? _id = widget.exerciseId;
  int _revision = 0;
  bool _busy = false;
  Object? _error;
  Future<void> _settings(Map<String, dynamic>? initial) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TeacherExerciseSettings(api: widget.api, initial: initial),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _id = '${teacherMap(result)['id']}';
        _revision++;
      });
    }
  }

  Future<void> _testcase(int order, {bool import = false}) async {
    await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherTestcaseEditor(
          api: widget.api,
          exerciseId: _id!,
          order: order,
          import: import,
        ),
      ),
    );
    if (mounted) setState(() => _revision++);
  }

  Future<void> _delete(Map<String, dynamic> testcase) async {
    if (!await courseConfirm(
          context,
          'Xóa testcase?',
          'Testcase sẽ bị xóa vĩnh viễn.',
          confirm: 'Xóa',
        ) ||
        !mounted) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.api.delete('/exercises/$_id/testcases/${testcase['id']}');
      if (mounted) setState(() => _revision++);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Bài lập trình'),
      actions: [
        if (_id != null)
          TextButton(
            onPressed: () => Navigator.pop(context, {'id': _id}),
            child: const Text('Chọn bài này'),
          ),
      ],
    ),
    body: _id == null
        ? Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Soạn đề, sau đó thêm testcase mẫu và testcase ẩn. Bài lập trình chỉ gắn vào bài học sau khi lưu nội dung ở màn trước.',
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => _settings(null),
                  child: const Text('Tạo bài lập trình'),
                ),
              ],
            ),
          )
        : TeacherAsyncView<dynamic>(
            key: ValueKey(_revision),
            load: () async {
              final results = await Future.wait([
                widget.api.get('/exercises/$_id'),
                widget.api.get('/exercises/$_id/testcases'),
              ]);
              return {
                'exercise': teacherMap(results[0]),
                'testcases': teacherList(
                  results[1],
                  keys: const ['test_cases', 'testcases'],
                ),
              };
            },
            builder: (context, raw) {
              final exercise = Map<String, dynamic>.from(
                raw['exercise'] as Map,
              );
              final cases = teacherList(raw['testcases']);
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    '${exercise['title']}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text('${exercise['description']}'),
                  const SizedBox(height: 12),
                  Text(
                    '${(exercise['language'] as List<dynamic>?)?.join(', ') ?? ''} · ${exercise['time_limit']} giây/testcase · ${exercise['memory_limit']} MB',
                  ),
                  TextButton(
                    onPressed: () => _settings(exercise),
                    child: const Text('Sửa đề và cấu hình'),
                  ),
                  if (_busy) const LinearProgressIndicator(),
                  if (_error != null)
                    TeacherErrorView(
                      error: _error!,
                      onRetry: () => setState(() => _revision++),
                    ),
                  const TeacherSectionTitle(title: 'Testcase'),
                  if (cases.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Chưa có testcase; chưa thể chấm tự động bài lập trình.',
                      ),
                    ),
                  for (var index = 0; index < cases.length; index++)
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        'Testcase ${index + 1} · ${cases[index]['is_hidden'] == true ? 'Ẩn với học viên' : 'Mẫu công khai'}',
                      ),
                      trailing: IconButton(
                        tooltip: 'Xóa testcase ${index + 1}',
                        onPressed: _busy ? null : () => _delete(cases[index]),
                        icon: const Icon(Icons.delete_outline),
                      ),
                      children: [
                        ListTile(
                          title: const Text('Đầu vào'),
                          subtitle: SelectableText('${cases[index]['input']}'),
                        ),
                        ListTile(
                          title: const Text('Kết quả mong đợi'),
                          subtitle: SelectableText(
                            '${cases[index]['expected_output'] ?? ''}',
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _busy ? null : () => _testcase(cases.length),
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm testcase'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _testcase(cases.length, import: true),
                        icon: const Icon(Icons.file_upload_outlined),
                        label: const Text('Nhập nhiều testcase'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
  );
}
