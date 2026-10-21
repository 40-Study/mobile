import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'course_form_widgets.dart';
import 'editors/quiz_settings.dart';
import 'editors/question_editor.dart';

class TeacherQuizEditorScreen extends StatefulWidget {
  const TeacherQuizEditorScreen({
    super.key,
    required this.api,
    required this.courseId,
    required this.lessonId,
    this.quizId,
  });
  final TeacherApi api;
  final String courseId;
  final String lessonId;
  final String? quizId;
  @override
  State<TeacherQuizEditorScreen> createState() =>
      _TeacherQuizEditorScreenState();
}

class _TeacherQuizEditorScreenState extends State<TeacherQuizEditorScreen> {
  late String? _id = widget.quizId;
  int _revision = 0;
  Object? _error;
  bool _busy = false;
  Future<void> _configure(Map<String, dynamic>? quiz) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherQuizSettings(
          api: widget.api,
          courseId: widget.courseId,
          lessonId: widget.lessonId,
          initial: quiz,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _id = '${teacherMap(result)['id']}';
        _revision++;
      });
    }
  }

  Future<void> _question({Map<String, dynamic>? initial, int order = 0}) async {
    await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherQuestionEditor(
          api: widget.api,
          quizId: _id!,
          initial: initial,
          order: order,
        ),
      ),
    );
    if (mounted) setState(() => _revision++);
  }

  Future<void> _mutate(Future<dynamic> Function() mutation) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await mutation();
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
      title: const Text('Soạn quiz'),
      actions: [
        if (_id != null)
          TextButton(
            onPressed: () => Navigator.pop(context, {'id': _id}),
            child: const Text('Chọn quiz này'),
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
                  'Tạo cấu hình trước, sau đó thêm câu hỏi. Quiz chỉ gắn vào nội dung bài học sau khi bạn lưu tại màn trước.',
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => _configure(null),
                  child: const Text('Tạo quiz'),
                ),
              ],
            ),
          )
        : TeacherAsyncView<dynamic>(
            key: ValueKey(_revision),
            load: () => widget.api.get('/quizzes/$_id'),
            builder: (context, raw) {
              final quiz = teacherMap(raw);
              final questions = teacherList(quiz['questions']);
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    '${quiz['title']}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'Đạt: ${quiz['pass_percentage']}% · Tối đa ${quiz['max_attempts'] ?? 'không giới hạn'} lượt',
                  ),
                  TextButton(
                    onPressed: () => _configure(quiz),
                    child: const Text('Sửa cấu hình quiz'),
                  ),
                  if (_busy) const LinearProgressIndicator(),
                  if (_error != null)
                    TeacherErrorView(
                      error: _error!,
                      onRetry: () => setState(() => _revision++),
                    ),
                  if (questions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Chưa có câu hỏi. Học viên chưa thể làm quiz này.',
                      ),
                    ),
                  for (var index = 0; index < questions.length; index++)
                    Builder(
                      builder: (context) {
                        final question = questions[index];
                        return ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: Text(
                            '${index + 1}. ${question['question_text']}',
                          ),
                          subtitle: Text(
                            '${question['points']} điểm · ${teacherQuestionTypes[question['question_type']] ?? question['question_type']}',
                          ),
                          trailing: PopupMenuButton<String>(
                            enabled: !_busy,
                            tooltip: 'Thao tác câu hỏi',
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Sửa câu hỏi'),
                              ),
                              PopupMenuItem(
                                value: 'up',
                                enabled: index > 0,
                                child: const Text('Di chuyển lên'),
                              ),
                              PopupMenuItem(
                                value: 'down',
                                enabled: index + 1 < questions.length,
                                child: const Text('Di chuyển xuống'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Xóa câu hỏi'),
                              ),
                            ],
                            onSelected: (v) async {
                              if (v == 'edit') {
                                await _question(initial: question);
                              }
                              if (v == 'delete' &&
                                  await courseConfirm(
                                    context,
                                    'Xóa câu hỏi?',
                                    'Câu hỏi và đáp án sẽ bị xóa khỏi quiz.',
                                    confirm: 'Xóa',
                                  )) {
                                await _mutate(
                                  () => widget.api.delete(
                                    '/quizzes/$_id/questions/${question['id']}',
                                  ),
                                );
                              }
                              if (v == 'up' || v == 'down') {
                                final ids = questions
                                    .map((q) => '${q['id']}')
                                    .toList();
                                ids.insert(
                                  index + (v == 'up' ? -1 : 1),
                                  ids.removeAt(index),
                                );
                                await _mutate(
                                  () => widget.api.put(
                                    '/quizzes/$_id/questions/reorder',
                                    data: {'question_ids': ids},
                                  ),
                                );
                              }
                            },
                          ),
                          children: [
                            for (final answer in teacherList(
                              question['answers'],
                            ))
                              ListTile(
                                title: Text('${answer['answer_text']}'),
                                leading: Icon(
                                  answer['is_correct'] == true
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                ),
                              ),
                            if (question['explanation'] != null)
                              ListTile(
                                title: Text(
                                  'Giải thích: ${question['explanation']}',
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () => _question(order: questions.length),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm câu hỏi'),
                  ),
                ],
              );
            },
          ),
  );
}
