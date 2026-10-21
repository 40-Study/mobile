import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

class TeacherContestEditor extends StatefulWidget {
  const TeacherContestEditor({super.key, this.api, this.initial});
  final TeacherApi? api;
  final Map<String, dynamic>? initial;
  @override
  State<TeacherContestEditor> createState() => _TeacherContestEditorState();
}

class _TeacherContestEditorState extends State<TeacherContestEditor> {
  late final api = widget.api ?? TeacherApi();
  final form = GlobalKey<FormState>();
  late final title = TextEditingController(
    text: widget.initial?['title']?.toString(),
  );
  late final description = TextEditingController(
    text: widget.initial?['description']?.toString(),
  );
  late final duration = TextEditingController(
    text: '${widget.initial?['duration_minutes'] ?? 60}',
  );
  late final capacity = TextEditingController(
    text: '${widget.initial?['max_participants'] ?? 0}',
  );
  late DateTime start =
      DateTime.tryParse('${widget.initial?['start_time']}')?.toLocal() ??
      DateTime.now().add(const Duration(days: 1));
  late DateTime end =
      DateTime.tryParse('${widget.initial?['end_time']}')?.toLocal() ??
      start.add(const Duration(hours: 2));
  late String? quiz = teacherMap(widget.initial?['quiz'])['id']?.toString();
  late bool isPublic = widget.initial?['is_public'] == true;
  bool saving = false;
  String? error;
  @override
  void dispose() {
    title.dispose();
    description.dispose();
    duration.dispose();
    capacity.dispose();
    super.dispose();
  }

  Future<void> pick(bool beginning) async {
    final current = beginning ? start : end;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time != null && mounted) {
      setState(() {
        final v = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        if (beginning) {
          start = v;
        } else {
          end = v;
        }
      });
    }
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    if (quiz == null ||
        !end.isAfter(start) ||
        end.difference(start).inMinutes < int.parse(duration.text)) {
      setState(
        () => error =
            'Chọn bộ câu hỏi và khung thời gian đủ cho thời lượng làm bài.',
      );
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final body = {
        'title': title.text.trim(),
        'description': description.text.trim(),
        'quiz_id': quiz,
        'start_time': start.toUtc().toIso8601String(),
        'end_time': end.toUtc().toIso8601String(),
        'duration_minutes': int.parse(duration.text),
        'max_participants': int.parse(capacity.text),
        'is_public': isPublic,
        if (widget.initial?['course_id'] != null)
          'course_id': widget.initial!['course_id'],
        if (widget.initial?['certificate_min_percentage'] != null)
          'certificate_min_percentage':
              widget.initial!['certificate_min_percentage'],
        if (widget.initial?['prizes'] != null)
          'prizes': (widget.initial!['prizes'] as List)
              .map(
                (p) => {
                  'rank_from': p['rank_from'],
                  'rank_to': p['rank_to'],
                  'grant_certificate': p['grant_certificate'],
                  'voucher_id': p['voucher']?['id'],
                },
              )
              .toList(),
      };
      if (widget.initial == null) {
        await api.post('/contests', data: body);
      } else {
        await api.put('/contests/${widget.initial!['id']}', data: body);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = teacherErrorMessage(e));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.initial == null ? 'Tạo cuộc thi' : 'Sửa cuộc thi'),
    ),
    body: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: title,
            maxLength: 255,
            decoration: const InputDecoration(labelText: 'Tên cuộc thi'),
            validator: (v) =>
                (v ?? '').trim().length < 2 ? 'Nhập ít nhất 2 ký tự' : null,
          ),
          TextFormField(
            controller: description,
            minLines: 3,
            maxLines: 8,
            decoration: const InputDecoration(labelText: 'Giới thiệu'),
          ),
          TeacherAsyncView<dynamic>(
            load: () => api.get('/contests/manage/quiz-options'),
            builder: (context, raw) {
              final options = teacherList(raw, keys: const ['quizzes']);
              return DropdownButtonFormField<String>(
                initialValue: options.any((e) => '${e['id']}' == quiz)
                    ? quiz
                    : null,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Bộ câu hỏi của bạn',
                ),
                items: options
                    .map(
                      (e) => DropdownMenuItem(
                        value: '${e['id']}',
                        child: Text(
                          '${e['title']} (${e['question_count']} câu)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: saving
                    ? null
                    : (value) => setState(() => quiz = value),
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Bắt đầu'),
            subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(start)),
            trailing: const Icon(Icons.calendar_month),
            onTap: saving ? null : () => pick(true),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Kết thúc'),
            subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(end)),
            trailing: const Icon(Icons.calendar_month),
            onTap: saving ? null : () => pick(false),
          ),
          TextFormField(
            controller: duration,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Thời lượng (phút)'),
            validator: (v) {
              final n = int.tryParse(v ?? '');
              return n == null || n < 1 || n > 600 ? 'Từ 1 đến 600 phút' : null;
            },
          ),
          TextFormField(
            controller: capacity,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Số thí sinh tối đa (0: không giới hạn)',
            ),
            validator: (v) {
              final n = int.tryParse(v ?? '');
              return n == null || n < 0 || n > 100000
                  ? 'Từ 0 đến 100.000'
                  : null;
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Hiển thị công khai'),
            value: isPublic,
            onChanged: saving ? null : (v) => setState(() => isPublic = v),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          FilledButton(
            onPressed: saving ? null : save,
            child: Text(saving ? 'Đang lưu…' : 'Lưu bản nháp'),
          ),
        ],
      ),
    ),
  );
}
