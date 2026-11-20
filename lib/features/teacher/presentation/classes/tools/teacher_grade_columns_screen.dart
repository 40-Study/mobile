import 'package:flutter/material.dart';
import 'package:study/theme/app_spacing.dart';
import '../../../data/teacher_api.dart';
import '../../../data/grade_rules.dart';
import '../../widgets/teacher_widgets.dart';
import 'tool_form.dart';

Future<bool> teacherGradeColumnForm(
  BuildContext context,
  TeacherApi api,
  String classId, [
  Map<String, dynamic>? column,
]) async {
  final path = '/classes/$classId';
  return teacherToolForm(
    context,
    title: column == null ? 'Thêm cột điểm' : 'Sửa cột điểm',
    choices: const {
      'Loại điểm': {
        'assignment': 'Bài tập',
        'quiz': 'Kiểm tra nhanh',
        'midterm': 'Giữa kỳ',
        'final': 'Cuối kỳ',
        'attendance': 'Chuyên cần',
        'participation': 'Tham gia',
        'project': 'Dự án',
        'other': 'Khác',
      },
    },
    fields: {
      'Tên cột': '${column?['name'] ?? ''}',
      'Loại điểm': '${column?['grade_type'] ?? 'assignment'}',
      'Thang điểm': '${column?['max_score'] ?? 10}',
      'Trọng số (0–1)': '${column?['weight'] ?? 1}',
    },
    validate: (v) {
      final max = num.tryParse(v['Thang điểm']!),
          weight = num.tryParse(v['Trọng số (0–1)']!);
      if (v['Tên cột']!.isEmpty || v['Tên cột']!.length > 100) {
        return 'Tên cột phải có 1–100 ký tự.';
      }
      if (!teacherGradeTypes.contains(v['Loại điểm'])) {
        return 'Loại hợp lệ: ${teacherGradeTypes.join(', ')}';
      }
      if (max == null ||
          !max.isFinite ||
          max <= 0 ||
          weight == null ||
          !weight.isFinite ||
          weight <= 0 ||
          weight > 1) {
        return 'Thang điểm phải lớn hơn 0; trọng số trong (0, 1].';
      }
      return null;
    },
    save: (v) async {
      final data = {
        'name': v['Tên cột'],
        'grade_type': v['Loại điểm'],
        'max_score': num.parse(v['Thang điểm']!),
        'weight': num.parse(v['Trọng số (0–1)']!),
      };
      if (column == null) {
        await api.post('$path/grade-columns', data: data);
      } else {
        await api.put('$path/grade-columns/${column['id']}', data: data);
      }
    },
  );
}

class TeacherGradeColumnsScreen extends StatefulWidget {
  const TeacherGradeColumnsScreen({
    super.key,
    required this.api,
    required this.classId,
    required this.canWrite,
  });
  final TeacherApi api;
  final String classId;
  final bool canWrite;
  @override
  State<TeacherGradeColumnsScreen> createState() =>
      _TeacherGradeColumnsScreenState();
}

class _TeacherGradeColumnsScreenState extends State<TeacherGradeColumnsScreen> {
  int revision = 0;
  bool busy = false;
  String get path => '/classes/${widget.classId}/grade-columns';
  Future<void> edit([Map<String, dynamic>? column]) async {
    final saved = await teacherGradeColumnForm(
      context,
      widget.api,
      widget.classId,
      column,
    );
    if (saved && mounted) setState(() => revision++);
  }

  Future<void> change(
    String action,
    int index,
    List<Map<String, dynamic>> columns,
  ) async {
    if (busy || !widget.canWrite) return;
    final column = columns[index];
    if (action == 'edit') {
      await edit(column);
      return;
    }
    if (action == 'delete' &&
        !await teacherToolConfirm(
          context,
          'Xóa cấu hình cột “${column['name']}”? Điểm đã lưu của học viên vẫn được giữ. Thao tác này không xóa các điểm hoặc tính lại tổng kết.',
        ))
      return;
    if (!mounted) return;
    setState(() => busy = true);
    try {
      if (action == 'delete') {
        await widget.api.delete('$path/${column['id']}');
      } else {
        final ids = columns.map((c) => '${c['id']}').toList();
        final target = action == 'up' ? index - 1 : index + 1;
        if (target < 0 || target >= ids.length) return;
        ids[index] = ids[target];
        ids[target] = '${column['id']}';
        await widget.api.put('$path/reorder', data: {'column_ids': ids});
      }
      if (mounted) {
        setState(() => revision++);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã cập nhật cột điểm.')));
      }
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(teacherErrorMessage(error))));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Cột điểm'),
      actions: [
        if (widget.canWrite)
          IconButton(
            tooltip: 'Thêm cột điểm',
            onPressed: busy ? null : edit,
            icon: const Icon(Icons.add),
          ),
      ],
    ),
    body: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Text(
            'Cấu hình tên, thang điểm và trọng số trước khi nhập. Đổi cấu hình không sửa các điểm đã lưu.',
          ),
        ),
        if (busy) const LinearProgressIndicator(),
        Expanded(
          child: TeacherAsyncView<List<Map<String, dynamic>>>(
            key: ValueKey(revision),
            load: () async => teacherList(await widget.api.get(path)),
            builder: (context, columns) => columns.isEmpty
                ? const Center(
                    child: Text('Chưa có cột điểm. Thêm cột để bắt đầu.'),
                  )
                : ListView.separated(
                    itemCount: columns.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final column = columns[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPadding,
                          vertical: AppSpacing.sm,
                        ),
                        title: Text('${column['name']}'),
                        subtitle: Text(
                          'Thang điểm ${column['max_score']} · Trọng số ${column['weight']}',
                        ),
                        trailing: widget.canWrite
                            ? PopupMenuButton<String>(
                                tooltip: 'Thao tác cột ${column['name']}',
                                enabled: !busy,
                                onSelected: (action) =>
                                    change(action, index, columns),
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Sửa cột'),
                                  ),
                                  PopupMenuItem(
                                    value: 'up',
                                    enabled: index > 0,
                                    child: const Text('Di chuyển lên'),
                                  ),
                                  PopupMenuItem(
                                    value: 'down',
                                    enabled: index < columns.length - 1,
                                    child: const Text('Di chuyển xuống'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Xóa cấu hình cột'),
                                  ),
                                ],
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ),
      ],
    ),
  );
}
