import 'dart:async';

import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

import '../../../data/teacher_api.dart';
import '../widgets/teacher_class_elements.dart';

class TeacherClassMemberPicker extends StatefulWidget {
  const TeacherClassMemberPicker({
    super.key,
    required this.api,
    required this.classId,
    this.className,
    required this.teachers,
  });

  final TeacherApi api;
  final String classId;
  final String? className;
  final bool teachers;

  @override
  State<TeacherClassMemberPicker> createState() =>
      _TeacherClassMemberPickerState();
}

class _TeacherClassMemberPickerState extends State<TeacherClassMemberPicker> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  int _revision = 0;
  bool _loading = false;
  bool _saving = false;
  String _keyword = '';
  Object? _searchError;
  Object? _saveError;
  List<Map<String, dynamic>> _rows = [];
  String? _selectedId;
  String _role = 'assistant';

  String get _kind => widget.teachers ? 'teachers' : 'students';
  String get _label => widget.teachers ? 'giáo viên' : 'học viên';
  String get _classPath => '/classes/${widget.classId}';

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _updateKeyword(String text) {
    _debounce?.cancel();
    final keyword = text.trim();
    final request = ++_revision;
    setState(() {
      _keyword = keyword;
      _selectedId = null;
      _rows = [];
      _searchError = null;
      _saveError = null;
      _loading = keyword.isNotEmpty;
    });
    if (keyword.isNotEmpty) {
      _debounce = Timer(
        const Duration(milliseconds: 350),
        () => _search(keyword, request),
      );
    }
  }

  Future<void> _search(String keyword, int request) async {
    try {
      final endpoint = widget.teachers
          ? 'assignable-teachers'
          : 'enrollable-students';
      final result = await widget.api.get(
        '$_classPath/$endpoint',
        query: {'keyword': keyword},
      );
      if (!mounted || request != _revision) return;
      final rows = teacherList(result, keys: [_kind]);
      setState(() {
        _rows = rows.where((row) => row['id'] != null).toList();
        _loading = false;
      });
    } catch (error) {
      if (!mounted || request != _revision) return;
      setState(() {
        _searchError = error;
        _loading = false;
      });
    }
  }

  Future<void> _add() async {
    final id = _selectedId;
    if (_saving || id == null) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await widget.api.post(
        '$_classPath/$_kind',
        data: {
          widget.teachers ? 'teacher_id' : 'student_id': id,
          if (widget.teachers) 'role': _role,
        },
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saveError = error;
          _saving = false;
        });
      }
    }
  }

  Widget _results() {
    if (_keyword.isEmpty) {
      return _message(Icons.search, 'Nhập tên hoặc tên đăng nhập của $_label.');
    }
    if (_loading) return const Center(child: CircularProgressIndicator());
    final error = _searchError;
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(teacherErrorMessage(error)),
            TextButton(
              onPressed: () => _updateKeyword(_keyword),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    if (_rows.isEmpty) {
      return _message(
        Icons.search_off_outlined,
        'Không tìm thấy $_label có thể thêm với từ khóa này.',
      );
    }
    return ListView.builder(
      padding: AppSpacing.paddingHorizontalLg,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: _rows.length + (_rows.length >= 20 ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _rows.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Đang hiện tối đa 20 kết quả. Nhập cụ thể hơn để tìm tiếp.',
            ),
          );
        }
        final row = _rows[index];
        final id = row['id'].toString();
        final username = row['user_name']?.toString();
        final name = row['full_name']?.toString() ?? username ?? _label;
        final selected = id == _selectedId;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: TeacherClassAvatar(name),
          title: Text(name),
          subtitle: username == null || username.isEmpty || username == name
              ? null
              : Text(username),
          selected: selected,
          trailing: selected ? const Icon(Icons.check_circle_outline) : null,
          onTap: _saving
              ? null
              : () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _selectedId = id;
                    _saveError = null;
                  });
                },
        );
      },
    );
  }

  Widget _message(IconData icon, String text) => Center(
    child: Padding(
      padding: AppSpacing.paddingLg,
      child: TeacherClassEmpty(icon, text),
    ),
  );

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: Scaffold(
      appBar: AppBar(title: Text('Tìm và chọn $_label')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.className case final name?)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  TextField(
                    controller: _searchController,
                    enabled: !_saving,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      labelText: 'Tên hoặc tên đăng nhập',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Xóa tìm kiếm',
                              onPressed: _saving
                                  ? null
                                  : () {
                                      _searchController.clear();
                                      _updateKeyword('');
                                    },
                              icon: const Icon(Icons.clear),
                            ),
                    ),
                    onChanged: _updateKeyword,
                  ),
                ],
              ),
            ),
            Expanded(child: _results()),
            Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.teachers && _selectedId != null) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _role,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Vai trò'),
                      items: const [
                        DropdownMenuItem(
                          value: 'assistant',
                          child: Text('Trợ giảng'),
                        ),
                        DropdownMenuItem(
                          value: 'primary',
                          child: Text('Giáo viên chính'),
                        ),
                      ],
                      onChanged: _saving
                          ? null
                          : (value) {
                              if (value != null) setState(() => _role = value);
                            },
                    ),
                    AppSpacing.vGap12,
                  ],
                  if (_saveError case final error?)
                    Text(
                      teacherErrorMessage(error),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  FilledButton(
                    onPressed: _selectedId == null || _saving ? null : _add,
                    child: Text(
                      _saving ? 'Đang thêm…' : 'Thêm $_label vào lớp',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
