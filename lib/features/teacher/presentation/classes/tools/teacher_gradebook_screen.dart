import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../data/grade_rules.dart';
import '../../../data/teacher_api.dart';
import '../../widgets/teacher_widgets.dart';
import 'tool_form.dart';
import 'teacher_grade_columns_screen.dart';
import 'widgets/grade_column_selector.dart';
import 'widgets/grade_student_row.dart';
import 'widgets/grade_save_bar.dart';
import 'widgets/final_grades.dart';
import 'package:study/theme/app_spacing.dart';

class TeacherGradebookScreen extends StatefulWidget {
  const TeacherGradebookScreen({
    super.key,
    required this.api,
    required this.classId,
    required this.canWrite,
    this.embedded = false,
  });
  final TeacherApi api;
  final String classId;
  final bool canWrite;
  final bool embedded;
  @override
  State<TeacherGradebookScreen> createState() => _TeacherGradebookScreenState();
}

class _TeacherGradebookScreenState extends State<TeacherGradebookScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  int revision = 0;
  final drafts = <String, String>{};
  String? columnId, error;
  bool busy = false, uncertain = false;
  Map<String, dynamic>? selectedColumn;
  String get path => '/classes/${widget.classId}';
  Future<Map<String, dynamic>> load() async {
    final book = toolPayload(await widget.api.get('$path/grades'));
    // The backend returns students without grades too; do not create phantom zeros.
    return book;
  }

  Future<void> columnForm([Map<String, dynamic>? column]) async {
    if (await teacherGradeColumnForm(
          context,
          widget.api,
          widget.classId,
          column,
        ) &&
        mounted)
      setState(() => revision++);
  }

  Future<void> manageColumns() async {
    await teacherPush<void>(
      context,
      TeacherGradeColumnsScreen(
        api: widget.api,
        classId: widget.classId,
        canWrite: widget.canWrite,
      ),
    );
    if (mounted)
      setState(() {
        selectedColumn = null;
        columnId = null;
        revision++;
      });
  }

  Future<void> saveDrafts() async {
    if (busy || uncertain || selectedColumn == null) return;
    final col = selectedColumn!;
    for (final entry in drafts.entries) {
      if (entry.value.isNotEmpty &&
          teacherScoreError(entry.value, col['max_score']) != null) {
        setState(
          () => error =
              'Học viên ${entry.key}: ${teacherScoreError(entry.value, col['max_score'])}',
        );
        return;
      }
    }
    final values = teacherDraftGrades(drafts, col);
    if (values.isEmpty) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.post('$path/grades/bulk', data: {'grades': values});
      if (mounted) {
        setState(() {
          drafts.clear();
          revision++;
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          uncertain =
              e.response == null || (e.response?.statusCode ?? 0) >= 500;
          error = uncertain
              ? 'Chưa xác định lô điểm đã lưu hay chưa. Bản nháp được giữ. Hãy quay lại kiểm tra bảng điểm trước khi nhập tiếp; không gửi lặp.'
              : teacherErrorMessage(e);
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = teacherErrorMessage(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> editGrade(Map<String, dynamic> grade) async {
    final saved = await teacherToolForm(
      context,
      title: '${grade['title']}',
      fields: {
        'Điểm': '${grade['score']}',
        'Nhận xét': '${grade['feedback'] ?? ''}',
      },
      validate: (v) => teacherScoreError(v['Điểm']!, grade['max_score']),
      save: (v) async {
        await widget.api.put(
          '/grades/${grade['id']}',
          data: {'score': num.parse(v['Điểm']!), 'feedback': v['Nhận xét']},
        );
      },
    );
    if (saved && mounted) setState(() => revision++);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      canPop: drafts.values.every((v) => v.isEmpty) && !busy,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || busy) return;
        if (await teacherToolConfirm(context, 'Bỏ bản nháp điểm chưa lưu?')) {
          if (mounted) {
            setState(drafts.clear);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) Navigator.pop(context);
            });
          }
        }
      },
      child: Scaffold(
        appBar: widget.embedded
            ? null
            : AppBar(
                title: const Text('Bảng điểm lớp'),
                actions: [
                  if (widget.canWrite)
                    IconButton(
                      tooltip: 'Quản lý cột điểm',
                      onPressed: busy || drafts.values.any((v) => v.isNotEmpty)
                          ? null
                          : manageColumns,
                      icon: const Icon(Icons.view_column_outlined),
                    ),
                  IconButton(
                    tooltip: 'Tổng kết',
                    icon: const Icon(Icons.fact_check_outlined),
                    onPressed: drafts.values.any((v) => v.isNotEmpty) || busy
                        ? null
                        : () => teacherPush<void>(
                            context,
                            TeacherFinalGrades(
                              api: widget.api,
                              classId: widget.classId,
                              canWrite: widget.canWrite,
                            ),
                          ),
                  ),
                  if (widget.canWrite)
                    IconButton(
                      tooltip: 'Thêm cột điểm',
                      icon: const Icon(Icons.add),
                      onPressed: busy ? null : columnForm,
                    ),
                ],
              ),
        body: TeacherAsyncView<Map<String, dynamic>>(
          key: ValueKey(revision),
          load: load,
          builder: (context, book) {
            final columns = teacherList(book['columns']);
            final students = teacherList(book['students']);
            return Column(
              children: [
                if (widget.embedded)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                      vertical: AppSpacing.sm,
                    ),
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        TextButton.icon(
                          onPressed:
                              busy || drafts.values.any((v) => v.isNotEmpty)
                              ? null
                              : () => teacherPush<void>(
                                  context,
                                  TeacherFinalGrades(
                                    api: widget.api,
                                    classId: widget.classId,
                                    canWrite: widget.canWrite,
                                  ),
                                ),
                          icon: const Icon(Icons.fact_check_outlined),
                          label: const Text('Tổng kết'),
                        ),
                        if (widget.canWrite)
                          TextButton.icon(
                            onPressed:
                                busy || drafts.values.any((v) => v.isNotEmpty)
                                ? null
                                : manageColumns,
                            icon: const Icon(Icons.view_column_outlined),
                            label: const Text('Quản lý cột điểm'),
                          ),
                      ],
                    ),
                  ),
                if (widget.canWrite)
                  TeacherGradeColumnSelector(
                    columns: columns,
                    columnId: columnId,
                    selectedColumn: selectedColumn,
                    busy: busy,
                    uncertain: uncertain,
                    hasDrafts: drafts.values.any((v) => v.isNotEmpty),
                    hasDraftEntries: drafts.isNotEmpty,
                    error: error,
                    onChanged: (id) => setState(() {
                      columnId = id;
                      selectedColumn = columns.firstWhere((c) => c['id'] == id);
                    }),
                    onEdit: () => columnForm(selectedColumn),
                  ),
                Expanded(
                  child: students.isEmpty
                      ? const Center(
                          child: Text('Chưa có học viên trong bảng điểm.'),
                        )
                      : ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            final id = '${student['student_id']}';
                            return TeacherGradeStudentRow(
                              student: student,
                              columnId: columnId,
                              selectedColumn: selectedColumn,
                              canWrite: widget.canWrite,
                              busy: busy,
                              uncertain: uncertain,
                              draft: drafts[id] ?? '',
                              onDraftChanged: (value) =>
                                  setState(() => drafts[id] = value),
                              onEditGrade: editGrade,
                            );
                          },
                        ),
                ),
                if (widget.canWrite)
                  TeacherGradeSaveBar(
                    busy: busy,
                    uncertain: uncertain,
                    hasDrafts: drafts.values.any((v) => v.isNotEmpty),
                    changedCount: drafts.values
                        .where((v) => v.isNotEmpty)
                        .length,
                    onSave: saveDrafts,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
