import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/widgets/student_attendance_tile.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/app_spacing.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({
    super.key,
    required this.api,
    required this.classId,
    required this.sessionId,
    required this.title,
    this.sessionDate,
    this.startTime,
    this.endTime,
    this.onSaved,
  });
  final TeacherApi api;
  final String classId;
  final String sessionId;
  final String title;
  final String? sessionDate;
  final String? startTime;
  final String? endTime;
  final VoidCallback? onSaved;
  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  static const _searchThreshold = 8;

  late Future<List<Map<String, dynamic>>> _future;
  final _draft = <String, Map<String, dynamic>>{};
  final _saved = <String, Map<String, dynamic>>{};
  bool get _dirty => _edits().isNotEmpty;
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
          'id': row['id'],
          'status': row['status'],
          'note': row['note'] ?? '',
        };
        _saved[id] = Map.of(value);
        _draft[id] = value;
      }
    }
    return students;
  }

  Map<String, Map<String, dynamic>> _edits() {
    final changes = <String, Map<String, dynamic>>{};
    for (final entry in _draft.entries) {
      final saved = _saved[entry.key];
      final patch = <String, dynamic>{
        if (saved?['status'] != entry.value['status'])
          'status': entry.value['status'],
        if ((saved?['note'] ?? '') != entry.value['note'])
          'note': entry.value['note'],
      };
      if (patch.isNotEmpty) changes[entry.key] = patch;
    }
    return changes;
  }

  Future<void> _save(List<Map<String, dynamic>> students) async {
    if (_saving) return;
    if (!_dirty) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Điểm danh đã được lưu.')));
      return;
    }
    final ids = students.map((s) => s['student_id']?.toString()).toSet();
    setState(() {
      _saving = true;
      _error = null;
    });
    var writeAttempted = false;
    try {
      final path = '/sessions/${widget.sessionId}/attendances';
      await _reconcile();
      if (!mounted) return;
      final pending = _edits().entries.where(
        (entry) => ids.contains(entry.key),
      );
      final newRows = [
        for (final entry in pending)
          if (!_saved.containsKey(entry.key))
            {
              'student_id': entry.key,
              'status': _draft[entry.key]?['status'],
              'note': _draft[entry.key]?['note'] ?? '',
            },
      ];
      if (newRows.isNotEmpty) {
        writeAttempted = true;
        await widget.api.post('$path/bulk', data: {'attendances': newRows});
      }
      for (final entry in pending) {
        final saved = _saved[entry.key];
        if (saved == null) continue;
        final id = saved['id'];
        if (id == null)
          throw const FormatException(
            'Thiếu mã bản ghi điểm danh. Vui lòng tải lại.',
          );
        writeAttempted = true;
        await widget.api.put('$path/$id', data: entry.value);
      }

      if (!mounted) return;
      await _reconcile();
      if (!mounted) return;
      if (_dirty) {
        throw const FormatException('Máy chủ chưa xác nhận tất cả thay đổi.');
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã lưu điểm danh.')));
    } catch (error) {
      if (writeAttempted && mounted) {
        try {
          await _reconcile();
        } catch (_) {
          // Preserve the draft until the server is reachable again.
        }
      }
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
        if (writeAttempted) widget.onSaved?.call();
      }
    }
  }

  Future<void> _reconcile() async {
    final fresh = teacherList(
      await widget.api.get('/sessions/${widget.sessionId}/attendances'),
    );
    if (!mounted) return;
    final edits = _edits();
    setState(() {
      _saved
        ..clear()
        ..addEntries(
          fresh
              .where((row) => row['student_id'] != null)
              .map(
                (row) => MapEntry(row['student_id'].toString(), {
                  ...row,
                  'note': row['note'] ?? '',
                }),
              ),
        );
      final merged = Map.of(_saved);
      for (final entry in edits.entries) {
        final basis = _saved[entry.key] ?? _draft[entry.key]!;
        merged[entry.key] = {...basis, ...entry.value};
      }
      _draft
        ..clear()
        ..addAll(merged);
    });
  }

  Future<void> _leave() async {
    if (_saving) return;
    final decision = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => const _UnsavedAttendanceDialog(),
    );
    if (decision == 'save' && mounted) {
      await _save(await _future);
      if (!mounted || _dirty) return;
    }
    if ((decision == 'discard' || decision == 'save') && mounted) {
      setState(_draft.clear);
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
    });
  }

  String _studentName(Map<String, dynamic> student) =>
      '${student['full_name'] ?? student['user_name'] ?? 'Học viên'}';

  String get _scheduleLabel {
    final rawDate = widget.sessionDate?.trim() ?? '';
    final date = DateTime.tryParse(rawDate.split('T').first);
    final weekday = date == null
        ? ''
        : date.weekday == DateTime.sunday
        ? 'Chủ nhật'
        : 'Thứ ${date.weekday + 1}';
    final start = teacherTime(widget.startTime);
    final end = teacherTime(widget.endTime);
    return [
      if (date != null)
        '$weekday, ${DateFormat('dd/MM/yyyy').format(date)}'
      else if (rawDate.isNotEmpty)
        rawDate,
      if (start.isNotEmpty && end.isNotEmpty) '$start–$end',
    ].join(' • ');
  }

  String _studentIdentifier(Map<String, dynamic> student) {
    final username = '${student['user_name'] ?? ''}'.trim();
    return username.isNotEmpty && username != _studentName(student)
        ? username
        : 'Mã học viên ${student['student_id']}';
  }

  Future<void> _editNote(String id, String name) async {
    final status = _draft[id]?['status']?.toString();
    if (status == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chọn trạng thái trước khi thêm ghi chú.'),
        ),
      );
      return;
    }
    var draftNote = '${_draft[id]?['note'] ?? ''}';
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ghi chú · $name'),
        content: TextFormField(
          initialValue: draftNote,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Ghi chú điểm danh'),
          onChanged: (value) => draftNote = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, draftNote),
            child: const Text('Áp dụng'),
          ),
        ],
      ),
    );
    if (note != null && mounted) {
      _set(id, status, note: note);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final background = isDark ? cs.surface : const Color(0xFFF4F6F9);
    const brandBlue = Color(0xFF2563EB);
    final scheduleLabel = _scheduleLabel;
    Widget page({required Widget body, Widget? footer}) => Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Điểm danh'),
        backgroundColor: background,
        scrolledUnderElevation: 0,
      ),
      body: body,
      bottomNavigationBar: footer,
    );

    return PopScope(
      canPop: !_dirty && !_saving,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _leave();
      },
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return page(
              body: TeacherErrorView(
                error: snapshot.error!,
                onRetry: () => setState(() {
                  _future = _load();
                }),
              ),
            );
          }
          if (!snapshot.hasData) {
            return page(body: const Center(child: CircularProgressIndicator()));
          }
          final students = snapshot.data!;
          final marked = students.where((student) {
            final id = student['student_id']?.toString();
            final status = AttendanceStatusX.fromApi(
              _draft[id]?['status']?.toString(),
            );
            return status != AttendanceStatus.unmarked;
          }).length;
          final progress = '$marked/${students.length}';
          final isComplete = students.isNotEmpty && marked == students.length;
          final dirty = _dirty;
          final showSearch = students.length >= _searchThreshold;
          final filtered = !showSearch || _search.isEmpty
              ? students
              : students.where((student) {
                  return _studentName(
                        student,
                      ).toLowerCase().contains(_search) ||
                      _studentIdentifier(
                        student,
                      ).toLowerCase().contains(_search);
                }).toList();
          return page(
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.title.replaceAll(' · ', ' • '),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark
                              ? cs.onSurface
                              : const Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (scheduleLabel.isNotEmpty) ...[
                        AppSpacing.vGap4,
                        Text(
                          scheduleLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? cs.onSurfaceVariant
                                : const Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                      AppSpacing.vGap4,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '$progress học viên đã điểm danh'
                              '${dirty ? ' · Chưa lưu' : ''}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: dirty ? cs.primary : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                          AppSpacing.hGap8,
                          Flexible(
                            child: TextButton(
                              onPressed: _saving || students.isEmpty
                                  ? null
                                  : () => _markAll(students),
                              style: TextButton.styleFrom(
                                foregroundColor: isDark
                                    ? cs.primary
                                    : brandBlue,
                                backgroundColor: isDark
                                    ? cs.primaryContainer
                                    : const Color(0xFFEFF6FF),
                                minimumSize: const Size(0, 30),
                                visualDensity: VisualDensity.standard,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                textStyle: theme.textTheme.labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.5,
                                    ),
                              ),
                              child: const Text(
                                'Đánh dấu cả lớp có mặt',
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vGap4,
                      LinearProgressIndicator(
                        value: students.isEmpty ? 0 : marked / students.length,
                        semanticsLabel: 'Tiến độ điểm danh',
                        color: isComplete ? const Color(0xFF16A34A) : brandBlue,
                        minHeight: 4,
                        trackGap: 0,
                        stopIndicatorRadius: 0,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(2),
                        ),
                      ),
                      if (showSearch) ...[
                        AppSpacing.vGap12,
                        TextField(
                          onChanged: (value) => setState(
                            () => _search = value.trim().toLowerCase(),
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Tìm học viên',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Chưa xác nhận lưu được.\n'
                      '${teacherErrorMessage(_error!)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                Expanded(
                  child: students.isEmpty
                      ? const Center(child: Text('Lớp chưa có học viên.'))
                      : filtered.isEmpty
                      ? const Center(child: Text('Không tìm thấy học viên.'))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.xs,
                            AppSpacing.lg,
                            AppSpacing.sm,
                          ),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => AppSpacing.vGap8,
                          itemBuilder: (context, index) {
                            final row = filtered[index];
                            final id = row['student_id'].toString();
                            final name = _studentName(row);
                            final status = _draft[id]?['status']?.toString();
                            return StudentAttendanceTile(
                              name: name,
                              identifier: _studentIdentifier(row),
                              status: AttendanceStatusX.fromApi(status),
                              note: _draft[id]?['note']?.toString(),
                              isDisabled: _saving,
                              onStatusChanged: (value) {
                                if (value.apiValue != status) {
                                  _set(id, value.apiValue);
                                }
                              },
                              onNoteEdit: () => _editNote(id, name),
                            );
                          },
                        ),
                ),
              ],
            ),
            footer: DecoratedBox(
              decoration: BoxDecoration(
                color: isDark ? cs.surface : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? cs.outlineVariant : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving || (marked == 0 && !dirty)
                          ? null
                          : () => _save(students),
                      style: FilledButton.styleFrom(
                        backgroundColor: brandBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 46),
                        visualDensity: VisualDensity.standard,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        textStyle: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(
                        _saving ? 'Đang lưu…' : 'Lưu điểm danh ($progress)',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UnsavedAttendanceDialog extends StatelessWidget {
  const _UnsavedAttendanceDialog();

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF0F172A);
    const textColor = Color(0xFF64748B);
    const buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    );
    final textTheme = Theme.of(context).textTheme;
    final actionText = textTheme.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      constraints: const BoxConstraints(maxWidth: 400),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFFEF3C7),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFD97706),
                  size: 26,
                ),
              ),
            ),
            AppSpacing.vGap16,
            Semantics(
              namesRoute: true,
              child: Text(
                'Điểm danh chưa lưu',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
            ),
            AppSpacing.vGap8,
            Text(
              'Bạn có muốn lưu lại kết quả điểm danh trước khi '
              'rời khỏi buổi học này không?',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: textColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: () => Navigator.pop(context, 'save'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                textStyle: actionText,
                minimumSize: const Size(0, 44),
                visualDensity: VisualDensity.standard,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                shape: buttonShape,
              ),
              child: const Text('Lưu và quay lại', textAlign: TextAlign.center),
            ),
            AppSpacing.vGap8,
            FilledButton(
              onPressed: () => Navigator.pop(context, 'discard'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFEF2F2),
                foregroundColor: const Color(0xFFDC2626),
                textStyle: actionText,
                minimumSize: const Size(0, 42),
                visualDensity: VisualDensity.standard,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                shape: buttonShape,
              ),
              child: const Text('Bỏ thay đổi', textAlign: TextAlign.center),
            ),
            AppSpacing.vGap4,
            TextButton(
              onPressed: () => Navigator.pop(context, 'stay'),
              style: TextButton.styleFrom(
                foregroundColor: textColor,
                textStyle: textTheme.labelLarge?.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
                minimumSize: const Size(0, 38),
                visualDensity: VisualDensity.standard,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
              ),
              child: const Text('Tiếp tục chỉnh', textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
