import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';

Future<Map<String, dynamic>> teacherLoadApplication(TeacherApi api) async {
  try {
    return teacherPayload(await api.get('/teacher-profiles/me'));
  } on DioException catch (error) {
    if (error.response?.statusCode == 404) return {};
    rethrow;
  }
}

class TeacherProfessionalScreen extends StatefulWidget {
  const TeacherProfessionalScreen({
    super.key,
    required this.api,
    this.application = const {},
  });
  final TeacherApi api;
  final Map<String, dynamic> application;
  @override
  State<TeacherProfessionalScreen> createState() =>
      _TeacherProfessionalScreenState();
}

class _TeacherProfessionalScreenState extends State<TeacherProfessionalScreen> {
  final _form = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  bool _dirty = false;
  bool _saving = false;
  Object? _error;
  static const _labels = {
    'specialization': 'Chuyên môn',
    'education': 'Trình độ học vấn',
    'experience_years': 'Số năm kinh nghiệm',
    'department': 'Bộ môn',
    'certificate_info': 'Thông tin chứng chỉ',
  };
  @override
  void initState() {
    super.initState();
    for (final key in _labels.keys) {
      _controllers[key] = TextEditingController(
        text: '${widget.application[key] ?? ''}',
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
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
        for (final entry in _controllers.entries)
          if (entry.key != 'experience_years' ||
              entry.value.text.trim().isNotEmpty)
            entry.key: entry.key == 'experience_years'
                ? int.parse(entry.value.text.trim())
                : entry.value.text.trim(),
      };
      final id = widget.application['id'];
      if (id == null) {
        await widget.api.post('/teacher-profiles', data: data);
      } else {
        await widget.api.put('/teacher-profiles/$id', data: data);
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
          _error = error;
          _saving = false;
        });
      }
    }
  }

  Future<void> _leave() async {
    if (_saving) return;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hồ sơ chưa lưu'),
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
      appBar: AppBar(title: const Text('Hồ sơ nghề nghiệp')),
      body: Form(
        key: _form,
        onChanged: () => setState(() => _dirty = true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.application.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  'Hoàn thiện thông tin chuyên môn để gửi hồ sơ xét duyệt giáo viên.',
                ),
              ),
            for (final entry in _labels.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _controllers[entry.key],
                  enabled: !_saving,
                  decoration: InputDecoration(labelText: entry.value),
                  maxLines: entry.key == 'certificate_info' ? 4 : 1,
                  maxLength:
                      entry.key == 'experience_years' ||
                          entry.key == 'certificate_info'
                      ? null
                      : 255,
                  keyboardType: entry.key == 'experience_years'
                      ? TextInputType.number
                      : null,
                  validator: (value) {
                    if (entry.key == 'experience_years' &&
                        value != null &&
                        value.isNotEmpty &&
                        (int.tryParse(value) == null || int.parse(value) < 0)) {
                      return 'Nhập số nguyên từ 0.';
                    }
                    if ((entry.key == 'specialization' ||
                            entry.key == 'education') &&
                        (value?.trim().isEmpty ?? true)) {
                      return 'Vui lòng bổ sung thông tin này.';
                    }
                    return null;
                  },
                ),
              ),
            if (_error != null)
              Text(
                'Chưa lưu được. ${teacherErrorMessage(_error!)}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(
                _saving
                    ? 'Đang lưu…'
                    : widget.application.isEmpty
                    ? 'Gửi hồ sơ'
                    : 'Lưu hồ sơ',
              ),
            ),
            if (widget.application['approval_status'] == 'rejected')
              const Text(
                'Lưu thay đổi chưa nộp lại hồ sơ. Quay lại trang trạng thái để gửi xét duyệt.',
              ),
          ],
        ),
      ),
    ),
  );
}
