import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/data/teacher_preview_api.dart';
import 'package:study/theme/theme.dart';

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
  bool get _preview => widget.api is TeacherPreviewApi;
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
    if (_preview || _saving || !_form.currentState!.validate()) return;
    if (_status == 'archived' && widget.classData?.archived != true) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Lưu trữ lớp?'),
          content: Text(
            'Sau khi lưu trữ, ${widget.classData!.name} chuyển sang chế độ chỉ xem.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Tiếp tục chỉnh'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Lưu trữ lớp'),
            ),
          ],
        ),
      );
      if (!mounted || confirmed != true || _saving) return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final data = <String, dynamic>{
        'name': _name.text.trim(),
        'description': _description.text.trim(),
        if (_max.text.trim().isNotEmpty)
          'max_students': int.parse(_max.text.trim()),
      };
      Object result = true;
      if (widget.classData == null) {
        final created = TeacherClassData(
          teacherPayload(await widget.api.post('/classes', data: data)),
        );
        if (created.id.trim().isNotEmpty) result = created.id;
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
          if (mounted) Navigator.pop(context, result);
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
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _form,
              onChanged: () => setState(() => _dirty = true),
              child: ListView(
                padding: AppSpacing.paddingLg,
                children: [
                  if (_preview)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text('Dữ liệu mẫu · Chỉ xem'),
                    ),
                  if (widget.classData == null)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Lớp mới là bản nháp. Bạn được phân công làm giáo viên chính và có thể thêm lịch sau khi tạo.',
                      ),
                    ),
                  TextFormField(
                    controller: _name,
                    enabled: !_saving && !_preview,
                    maxLength: 255,
                    decoration: const InputDecoration(labelText: 'Tên lớp'),
                    textInputAction: TextInputAction.next,
                    validator: (value) => (value?.trim().length ?? 0) < 2
                        ? 'Nhập ít nhất 2 ký tự.'
                        : null,
                  ),
                  AppSpacing.vGap16,
                  TextFormField(
                    controller: _description,
                    enabled: !_saving && !_preview,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Mô tả (tùy chọn)',
                    ),
                  ),
                  AppSpacing.vGap16,
                  TextFormField(
                    controller: _max,
                    enabled: !_saving && !_preview,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Số học viên tối đa (tùy chọn)',
                    ),
                    validator: (value) =>
                        value == null ||
                            value.trim().isEmpty ||
                            (int.tryParse(value.trim()) ?? 0) > 0
                        ? null
                        : 'Nhập số nguyên dương.',
                  ),
                  if (widget.classData != null) ...[
                    AppSpacing.vGap16,
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'Trạng thái',
                      ),
                      items: ['draft', 'active', 'archived']
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(teacherStatus(s)),
                            ),
                          )
                          .toList(),
                      onChanged: _saving || _preview
                          ? null
                          : (value) => setState(() {
                              _status = value!;
                              _dirty = true;
                            }),
                    ),
                  ],
                  if (_status == 'archived') ...[
                    AppSpacing.vGap8,
                    const Text('Lớp chuyển sang chế độ chỉ xem khi lưu trữ.'),
                  ],
                ],
              ),
            ),
          ),
          if (!_preview)
            Material(
              child: SafeArea(
                top: false,
                minimum: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error case final error?) ...[
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          teacherErrorMessage(error),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                      AppSpacing.vGap8,
                    ],
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      child: Text(
                        _saving
                            ? 'Đang lưu…'
                            : widget.classData == null
                            ? 'Tạo lớp'
                            : 'Lưu thay đổi',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
