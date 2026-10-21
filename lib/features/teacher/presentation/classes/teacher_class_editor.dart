import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';

class TeacherClassEditor extends StatefulWidget {
  const TeacherClassEditor({super.key, required this.api, this.classData});
  final TeacherApi api;
  final TeacherClassData? classData;
  @override
  State<TeacherClassEditor> createState() => _TeacherClassEditorState();
}

class _TeacherClassEditorState extends State<TeacherClassEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _max;
  late String _status;
  bool _dirty = false;
  bool _saving = false;
  Object? _error;
  @override
  void initState() {
    super.initState();
    final json = widget.classData?.json;
    _name = TextEditingController(text: json?['name']?.toString());
    _description = TextEditingController(
      text: json?['description']?.toString(),
    );
    _max = TextEditingController(text: json?['max_students']?.toString());
    _status = json?['status']?.toString() ?? 'draft';
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _max.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final data = <String, dynamic>{
        'name': _name.text.trim(),
        'description': _description.text.trim(),
        if (_max.text.trim().isNotEmpty) 'max_students': int.parse(_max.text),
      };
      if (widget.classData == null) {
        await widget.api.post('/classes', data: data);
      } else {
        final detail = TeacherClassData(
          teacherPayload(
            await widget.api.get('/classes/${widget.classData!.id}'),
          ),
        );
        if (!detail.canManage) {
          throw StateError('Bạn không có quyền sửa lớp này.');
        }
        await widget.api.put(
          '/classes/${detail.id}',
          data: {...data, 'status': _status},
        );
      }
      if (mounted) {
        setState(() {
          _dirty = false;
          _saving = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pop(context, true);
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = error;
        });
      }
    }
  }

  Future<void> _leave() async {
    if (_saving) return;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin lớp chưa lưu'),
        content: const Text('Bỏ thay đổi và quay lại?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tiếp tục chỉnh'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Bỏ thay đổi'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      setState(() => _dirty = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_dirty && !_saving,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _leave();
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          widget.classData == null ? 'Tạo lớp cá nhân' : 'Chỉnh sửa lớp',
        ),
      ),
      body: Form(
        key: _form,
        onChanged: () => setState(() => _dirty = true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.classData == null)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Lớp mới là bản nháp. Sau khi tạo, phân công giáo viên để lớp xuất hiện trong lịch và danh sách được phân công.',
                ),
              ),
            TextFormField(
              controller: _name,
              enabled: !_saving,
              maxLength: 255,
              decoration: const InputDecoration(labelText: 'Tên lớp'),
              validator: (value) => (value?.trim().length ?? 0) < 2
                  ? 'Nhập ít nhất 2 ký tự.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              enabled: !_saving,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _max,
              enabled: !_saving,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số học viên tối đa (tùy chọn)',
              ),
              validator: (value) =>
                  value == null ||
                      value.isEmpty ||
                      (int.tryParse(value) ?? 0) > 0
                  ? null
                  : 'Nhập số nguyên dương.',
            ),
            if (widget.classData != null)
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Trạng thái'),
                items: ['draft', 'active', 'archived']
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(teacherStatus(s)),
                      ),
                    )
                    .toList(),
                onChanged: _saving
                    ? null
                    : (value) => setState(() {
                        _status = value!;
                        _dirty = true;
                      }),
              ),
            if (_status == 'archived')
              const Text('Lưu trữ chuyển các nghiệp vụ lớp sang chỉ đọc.'),
            if (_error != null)
              Text(
                'Chưa lưu được. $_error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Đang lưu…' : 'Lưu lớp'),
            ),
          ],
        ),
      ),
    ),
  );
}
