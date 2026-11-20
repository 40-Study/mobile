import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/app_spacing.dart';

const teacherAttendanceLabels = {
  'present': 'Có mặt',
  'absent': 'Vắng',
  'late': 'Đi muộn',
  'excused': 'Có phép',
};

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({
    super.key,
    required this.api,
    required this.classId,
    required this.sessionId,
    required this.title,
  });
  final TeacherApi api;
  final String classId;
  final String sessionId;
  final String title;
  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  late Future<List<Map<String, dynamic>>> _future;
  final _draft = <String, Map<String, dynamic>>{};
  final _saved = <String, Map<String, dynamic>>{};
  bool _dirty = false;
  bool _saving = false;
  Object? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final detail = TeacherClassData(
      teacherPayload(await widget.api.get('/classes/${widget.classId}')),
    );
    if (!detail.canManage) {
      throw StateError('Lớp chỉ đọc hoặc bạn không có quyền điểm danh.');
    }
    final students = await teacherAllPages(
      widget.api,
      '/classes/${widget.classId}/students',
      'students',
    );
    final attendance = teacherList(
      await widget.api.get('/sessions/${widget.sessionId}/attendances'),
    ).map(teacherMap);
    _draft.clear();
    _saved.clear();
    for (final row in attendance) {
      final id = row['student_id']?.toString();
      if (id != null) {
        final value = <String, dynamic>{
          'student_id': id,
          'status': row['status'],
          'note': row['note'] ?? '',
        };
        _saved[id] = Map.of(value);
        _draft[id] = value;
      }
    }
    return students;
  }

  Future<void> _save(List<Map<String, dynamic>> students) async {
    final ids = students.map((s) => s['student_id']?.toString()).toSet();
    final changes = _draft.entries
        .where(
          (entry) =>
              ids.contains(entry.key) &&
              (_saved[entry.key]?['status'] != entry.value['status'] ||
                  _saved[entry.key]?['note'] != entry.value['note']),
        )
        .map((entry) => Map<String, dynamic>.of(entry.value))
        .toList();
    if (changes.isEmpty) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.api.post(
        '/sessions/${widget.sessionId}/attendances/bulk',
        data: {'attendances': changes},
      );
      if (!mounted) return;
      // A successful write is followed by a server read, never a fabricated
      // attendance count. On read failure retain the draft for reconciliation.
      final fresh = teacherList(
        await widget.api.get('/sessions/${widget.sessionId}/attendances'),
      ).map(teacherMap).toList();
      if (!mounted) return;
      setState(() {
        _saved.clear();
        for (final row in fresh) {
          final id = row['student_id'].toString();
          _saved[id] = {
            'student_id': id,
            'status': row['status'],
            'note': row['note'] ?? '',
          };
        }
        _draft
          ..clear()
          ..addEntries(
            _saved.entries.map(
              (e) => MapEntry(e.key, Map<String, dynamic>.of(e.value)),
            ),
          );
        _dirty = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã lưu điểm danh.')));
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _leave() async {
    if (_saving) return;
    final decision = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Điểm danh chưa lưu'),
        content: const Text('Lưu điểm danh trước khi rời buổi học?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'stay'),
            child: const Text('Tiếp tục chỉnh'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: const Text('Bỏ thay đổi'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text('Lưu và quay lại'),
          ),
        ],
      ),
    );
    if (decision == 'save' && mounted) {
      await _save(await _future);
      if (!mounted || _dirty) return;
    }
    if ((decision == 'discard' || decision == 'save') && mounted) {
      setState(() => _dirty = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  void _set(String id, String status, {String? note}) {
    setState(() {
      _draft[id] = {
        'student_id': id,
        'status': status,
        'note': note ?? _draft[id]?['note'] ?? '',
      };
      _dirty = true;
    });
  }

  Future<void> _markAll(List<Map<String, dynamic>> students) async {
    if (_saving || students.isEmpty) return;
    if (_draft.values.any((row) => row['status'] != 'present')) {
      final yes = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: const Text('Ghi đè điểm danh đã chọn?'),
          content: const Text(
            'Các trạng thái đã đánh dấu sẽ chuyển thành Có mặt. Thay đổi chỉ được ghi nhận khi bạn bấm Lưu.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialog, true),
              child: const Text('Đánh dấu tất cả'),
            ),
          ],
        ),
      );
      if (yes != true || !mounted) return;
    }
    if (!mounted) return;
    setState(() {
      for (final student in students) {
        final id = '${student['student_id']}';
        _draft[id] = {
          'student_id': id,
          'status': 'present',
          'note': _draft[id]?['note'] ?? '',
        };
      }
      _dirty = true;
    });
  }

  Future<void> _editNote(String id, String name) async {
    final controller = TextEditingController(
      text: '${_draft[id]?['note'] ?? ''}',
    );
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ghi chú · $name'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Ghi chú điểm danh'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Áp dụng'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (note != null && mounted) {
      final status = _draft[id]?['status']?.toString();
      if (status == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chọn trạng thái trước khi thêm ghi chú.'),
          ),
        );
      } else {
        _set(id, status, note: note);
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_dirty && !_saving,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _leave();
    },
    child: Scaffold(
      appBar: AppBar(title: const Text('Điểm danh')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return TeacherErrorView(
              error: snapshot.error!,
              onRetry: () => setState(() {
                _future = _load();
              }),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final students = snapshot.data!;
          final filtered = students
              .where(
                (s) => '${s['full_name'] ?? s['user_name'] ?? ''}'
                    .toLowerCase()
                    .contains(_search.toLowerCase()),
              )
              .toList();
          return Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${students.length} học viên · ${_draft.length} đã có trạng thái'
                      '${_dirty ? ' · Chưa lưu' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _dirty
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (value) => setState(() => _search = value),
                      decoration: const InputDecoration(
                        labelText: 'Tìm học viên',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    TextButton(
                      onPressed: _saving || students.isEmpty
                          ? null
                          : () => _markAll(students),
                      child: const Text('Đánh dấu tất cả có mặt'),
                    ),
                  ],
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Chưa xác nhận lưu được. Bản sửa vẫn được giữ.\n$_error',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              Expanded(
                child: students.isEmpty
                    ? const Center(child: Text('Lớp chưa có học viên.'))
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox.shrink(),
                        itemBuilder: (context, index) {
                          final row = filtered[index];
                          final id = row['student_id'].toString();
                          final name =
                              '${row['full_name'] ?? row['user_name'] ?? 'Học viên'}';
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.xs,
                            ),
                            padding: AppSpacing.paddingLg,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withValues(alpha: .6),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                      child: Text(
                                        name.isEmpty
                                            ? '?'
                                            : name.characters.first
                                                  .toUpperCase(),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    for (final entry
                                        in teacherAttendanceLabels.entries)
                                      ChoiceChip(
                                        selectedColor: entry.key == 'absent'
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.errorContainer
                                            : Theme.of(
                                                context,
                                              ).colorScheme.primaryContainer,
                                        labelStyle: TextStyle(
                                          color:
                                              _draft[id]?['status'] == entry.key
                                              ? (entry.key == 'absent'
                                                    ? Theme.of(context)
                                                          .colorScheme
                                                          .onErrorContainer
                                                    : Theme.of(context)
                                                          .colorScheme
                                                          .onPrimaryContainer)
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                        ),
                                        label: Text(entry.value),
                                        selected:
                                            _draft[id]?['status'] == entry.key,
                                        onSelected: _saving
                                            ? null
                                            : (_) => _set(id, entry.key),
                                      ),
                                  ],
                                ),
                                TextButton.icon(
                                  onPressed: _saving
                                      ? null
                                      : () => _editNote(id, name),
                                  icon: const Icon(Icons.edit_note),
                                  label: Text(
                                    '${_draft[id]?['note'] ?? ''}'.isEmpty
                                        ? 'Thêm ghi chú'
                                        : '${_draft[id]?['note']}',
                                  ),
                                ),
                                if (!_draft.containsKey(id))
                                  Text(
                                    'Chưa điểm danh',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: !_dirty || _saving
                          ? null
                          : () => _save(students),
                      child: Text(_saving ? 'Đang lưu…' : 'Lưu điểm danh'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
