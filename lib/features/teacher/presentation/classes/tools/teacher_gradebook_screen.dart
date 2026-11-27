import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../data/grade_rules.dart';
import '../../../data/teacher_api.dart';
import '../../../data/teacher_core.dart';
import '../../../data/teacher_preview_api.dart';
import '../../widgets/teacher_widgets.dart';
import 'tool_form.dart';
import 'teacher_grade_columns_screen.dart';
import 'widgets/grade_column_selector.dart';
import 'widgets/grade_student_row.dart';
import 'widgets/grade_save_bar.dart';
import 'widgets/final_grades.dart';
import 'package:study/theme/app_spacing.dart';

typedef _GradeBook = ({
  List<Map<String, dynamic>> columns,
  List<Map<String, dynamic>> students,
  Set<String> activeStudentIds,
  Object? rosterError,
});

class TeacherGradebookScreen extends StatefulWidget {
  const TeacherGradebookScreen({
    super.key,
    required this.api,
    required this.classId,
    required this.canWrite,
    this.embedded = false,
    this.refreshToken,
    this.onGradesChanged,
  });
  final TeacherApi api;
  final String classId;
  final bool canWrite;
  final bool embedded;
  final Object? refreshToken;
  final VoidCallback? onGradesChanged;
  @override
  State<TeacherGradebookScreen> createState() => _TeacherGradebookScreenState();
}

class _TeacherGradebookScreenState extends State<TeacherGradebookScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final drafts = <String, String>{};
  final conflictingIds = <String>{};
  final retryIds = <String>{};
  final rowErrors = <String, String>{};
  List<Map<String, dynamic>> attempted = [];
  Set<String> baselineIds = {};
  late Future<_GradeBook> bookFuture = load();
  String? columnId, error;
  String search = '';
  bool busy = false, uncertain = false;
  bool get canWrite => widget.canWrite && widget.api is! TeacherPreviewApi;
  bool get hasDrafts => drafts.values.any((value) => value.trim().isNotEmpty);
  String get path => '/classes/${widget.classId}';
  @override
  void didUpdateWidget(TeacherGradebookScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) bookFuture = load();
  }

  Future<_GradeBook> load() async {
    final book = toolPayload(await widget.api.get('$path/grades'));
    final students = {
      for (final row in teacherList(book['students']))
        if (row['student_id'] != null) row['student_id'].toString(): row,
    };
    final activeStudentIds = <String>{};
    Object? rosterError;
    try {
      final roster = await teacherAllPages(
        widget.api,
        '$path/students',
        'students',
      );
      for (final row in roster) {
        final id = row['student_id']?.toString();
        if (id == null || row['status'] != 'active') continue;
        activeStudentIds.add(id);
        students[id] = {
          'student_id': id,
          'student_name': row['full_name'] ?? row['user_name'] ?? 'Học viên',
          ...?students[id],
          'user_name': row['user_name'],
        };
      }
    } catch (error) {
      rosterError = error;
    }
    return (
      columns: teacherList(book['columns']),
      students: students.values.toList()
        ..sort(
          (a, b) => a['student_name'].toString().toLowerCase().compareTo(
            b['student_name'].toString().toLowerCase(),
          ),
        ),
      activeStudentIds: activeStudentIds,
      rosterError: rosterError,
    );
  }

  void reload() => setState(() => bookFuture = load());

  Future<void> manageColumns() async {
    await teacherPush<void>(
      context,
      TeacherGradeColumnsScreen(
        api: widget.api,
        classId: widget.classId,
        canWrite: canWrite,
      ),
    );
    if (mounted) reload();
  }

  List<Map<String, dynamic>> gradesFor(_GradeBook book, String studentId) =>
      teacherList(
        book.students
            .where((student) => student['student_id'].toString() == studentId)
            .firstOrNull?['grades'],
      );

  bool isSameColumn(Map<String, dynamic> grade, Map<String, dynamic> draft) =>
      grade['title'] == draft['title'] &&
      grade['grade_type'] == draft['grade_type'];

  bool matchesDraft(Map<String, dynamic> grade, Map<String, dynamic> draft) =>
      ['score', 'max_score', 'weight'].every(
        (field) =>
            num.tryParse('${grade[field]}') == num.tryParse('${draft[field]}'),
      );

  Future<void> reconcile() async {
    if (!canWrite || busy || attempted.isEmpty) return;
    setState(() => busy = true);
    try {
      final book = await load();
      if (!mounted) return;
      setState(() {
        for (final draft in attempted) {
          final id = draft['student_id'].toString();
          final sameColumn = gradesFor(
            book,
            id,
          ).where((grade) => isSameColumn(grade, draft)).toList();
          if (sameColumn.length == 1 &&
              sameColumn.single['id'] != null &&
              !baselineIds.contains('${sameColumn.single['id']}') &&
              matchesDraft(sameColumn.single, draft)) {
            drafts.remove(id);
          } else if (sameColumn.isNotEmpty) {
            conflictingIds.add(id);
          } else {
            retryIds.add(id);
          }
        }
        uncertain = false;
        attempted = [];
        bookFuture = Future.value(book);
        error = conflictingIds.isNotEmpty
            ? 'Có điểm khác hoặc nhiều bản ghi cùng cột. Hãy đối chiếu từng dòng.'
            : retryIds.isNotEmpty
            ? 'Một số điểm chưa thấy trên máy chủ. Bản nháp vẫn được giữ.'
            : null;
      });
      widget.onGradesChanged?.call();
    } catch (_) {
      if (mounted)
        setState(
          () => error = 'Chưa kiểm tra được bảng điểm. Thử kiểm tra lại.',
        );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> saveDrafts(_GradeBook book, Map<String, dynamic> col) async {
    if (!canWrite || busy || uncertain || book.rosterError != null) return;
    final scores = Map.fromEntries(
      drafts.entries.where(
        (entry) =>
            entry.value.trim().isNotEmpty &&
            !conflictingIds.contains(entry.key),
      ),
    );
    final invalid = <String, String>{};
    for (final entry in scores.entries) {
      final message = !book.activeStudentIds.contains(entry.key)
          ? 'Học viên không còn trong danh sách đang học.'
          : teacherScoreError(entry.value, col['max_score']);
      if (message != null) invalid[entry.key] = message;
    }
    setState(() {
      rowErrors
        ..clear()
        ..addAll(invalid);
      error = invalid.isEmpty
          ? null
          : 'Kiểm tra lại các dòng điểm bị đánh dấu.';
    });
    if (invalid.isNotEmpty || scores.isEmpty) return;

    final values = teacherDraftGrades(scores, col);
    final sameColumnIds = {
      for (final value in values)
        if (gradesFor(
          book,
          value['student_id'].toString(),
        ).any((grade) => isSameColumn(grade, value)))
          value['student_id'].toString(),
    };
    if (sameColumnIds.isNotEmpty) {
      setState(() {
        conflictingIds.addAll(sameColumnIds);
        error =
            'Một số học viên đã có điểm ở cột này. Hãy đối chiếu từng dòng.';
      });
      return;
    }
    if (scores.keys.any(retryIds.contains)) {
      final confirmed = await teacherToolConfirm(
        context,
        'Một số điểm chưa thấy khi kiểm tra. Xác nhận gửi lại các điểm đang chờ?',
      );
      if (!confirmed || !mounted || busy) return;
    }
    setState(() {
      busy = true;
      attempted = values;
      baselineIds = {
        for (final student in scores.keys)
          for (final grade in gradesFor(book, student))
            if (grade['id'] != null) '${grade['id']}',
      };
    });
    try {
      await widget.api.post('$path/grades/bulk', data: {'grades': values});
      if (mounted) {
        setState(() {
          for (final id in scores.keys) {
            drafts.remove(id);
            retryIds.remove(id);
          }
          attempted = [];
          bookFuture = load();
        });
        widget.onGradesChanged?.call();
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          uncertain =
              e.response == null || (e.response?.statusCode ?? 0) >= 500;
          error = uncertain
              ? 'Chưa biết điểm đã lưu hay chưa. Hãy kiểm tra điểm đã lưu trước khi gửi lại.'
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
    if (!canWrite || busy || uncertain) return;
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
    if (saved && mounted) {
      reload();
      widget.onGradesChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      canPop: !hasDrafts && !busy,
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
                  if (canWrite)
                    IconButton(
                      tooltip: 'Quản lý cột điểm',
                      onPressed: busy || hasDrafts ? null : manageColumns,
                      icon: const Icon(Icons.view_column_outlined),
                    ),
                  IconButton(
                    tooltip: 'Tổng kết',
                    icon: const Icon(Icons.fact_check_outlined),
                    onPressed: hasDrafts || busy
                        ? null
                        : () => teacherPush<void>(
                            context,
                            TeacherFinalGrades(
                              api: widget.api,
                              classId: widget.classId,
                              canWrite: canWrite,
                            ),
                          ),
                  ),
                ],
              ),
        body: FutureBuilder<_GradeBook>(
          future: bookFuture,
          builder: (context, snapshot) {
            final loading = snapshot.connectionState != ConnectionState.done;
            if (!loading && snapshot.hasError) {
              return TeacherErrorView(error: snapshot.error!, onRetry: reload);
            }
            final book = snapshot.data;
            if (book == null)
              return const Center(child: CircularProgressIndicator());
            final columns = book.columns;
            final selectedColumn =
                columns
                    .where((row) => '${row['id']}' == columnId)
                    .firstOrNull ??
                (hasDrafts ? null : columns.firstOrNull);
            final activeColumnId = selectedColumn?['id']?.toString();
            final students = book.students.where((student) {
              return [student['student_name'], student['user_name']].any(
                (value) =>
                    (value ?? '').toString().toLowerCase().contains(search),
              );
            }).toList();
            final savingBlocked = busy || loading;
            final saveableCount = drafts.entries
                .where(
                  (entry) =>
                      entry.value.trim().isNotEmpty &&
                      !conflictingIds.contains(entry.key),
                )
                .length;
            return Column(
              children: [
                if (loading) const LinearProgressIndicator(),
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
                          onPressed: savingBlocked || hasDrafts
                              ? null
                              : () => teacherPush<void>(
                                  context,
                                  TeacherFinalGrades(
                                    api: widget.api,
                                    classId: widget.classId,
                                    canWrite: canWrite,
                                  ),
                                ),
                          icon: const Icon(Icons.fact_check_outlined),
                          label: const Text('Tổng kết'),
                        ),
                        if (canWrite)
                          TextButton.icon(
                            onPressed: savingBlocked || hasDrafts
                                ? null
                                : manageColumns,
                            icon: const Icon(Icons.view_column_outlined),
                            label: const Text('Quản lý cột điểm'),
                          ),
                      ],
                    ),
                  ),
                TeacherGradeColumnSelector(
                  key: ValueKey(activeColumnId),
                  columns: columns,
                  columnId: activeColumnId,
                  busy: savingBlocked,
                  uncertain: uncertain,
                  hasDrafts: hasDrafts,
                  error: hasDrafts && selectedColumn == null
                      ? 'Cột đã thay đổi. Kiểm tra và bỏ các bản nháp của cột này.'
                      : error,
                  onChanged: (id) => setState(() {
                    columnId = id;
                    rowErrors.clear();
                    error = null;
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Tìm học viên',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) =>
                        setState(() => search = value.trim().toLowerCase()),
                  ),
                ),
                if (book.rosterError != null)
                  ListTile(
                    title: const Text('Chưa tải được danh sách học viên'),
                    subtitle: Text(teacherErrorMessage(book.rosterError!)),
                    trailing: TextButton(
                      onPressed: savingBlocked ? null : reload,
                      child: const Text('Thử lại'),
                    ),
                  ),
                Expanded(
                  child: students.isEmpty
                      ? Center(
                          child: Text(
                            search.isEmpty
                                ? 'Chưa có học viên trong bảng điểm.'
                                : 'Không tìm thấy học viên phù hợp.',
                          ),
                        )
                      : ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            final id = '${student['student_id']}';
                            final conflict = conflictingIds.contains(id);
                            return TeacherGradeStudentRow(
                              key: ValueKey(id),
                              student: student,
                              columnId: activeColumnId,
                              selectedColumn: selectedColumn,
                              canWrite: canWrite,
                              canEnterScore: book.activeStudentIds.contains(id),
                              busy: savingBlocked,
                              uncertain: uncertain,
                              draft: drafts[id] ?? '',
                              error: rowErrors[id],
                              conflict: conflict,
                              retry: retryIds.contains(id),
                              onDiscardDraft: () => setState(() {
                                drafts.remove(id);
                                conflictingIds.remove(id);
                                retryIds.remove(id);
                                rowErrors.remove(id);
                                if (conflictingIds.isEmpty && retryIds.isEmpty)
                                  error = null;
                              }),
                              onDraftChanged: (value) => setState(() {
                                if (value.trim().isEmpty) {
                                  drafts.remove(id);
                                } else {
                                  columnId = activeColumnId;
                                  drafts[id] = value;
                                }
                                rowErrors.remove(id);
                              }),
                              onEditGrade: editGrade,
                            );
                          },
                        ),
                ),
                if (canWrite && (hasDrafts || uncertain))
                  TeacherGradeSaveBar(
                    busy: savingBlocked,
                    uncertain: uncertain,
                    hasDrafts: saveableCount > 0,
                    changedCount: saveableCount,
                    draftCount: drafts.length,
                    onCheck: reconcile,
                    onSave: selectedColumn == null || book.rosterError != null
                        ? null
                        : () => saveDrafts(book, selectedColumn),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
