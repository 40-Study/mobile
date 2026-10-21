import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/classes/teacher_class_editor.dart';
import 'package:study/features/teacher/presentation/classes/teacher_class_screen.dart';
import 'package:study/features/teacher/presentation/classes/widgets/teacher_class_card.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/app_spacing.dart';
import 'package:study/widgets/empty_state.dart';

class TeacherClassesScreen extends StatefulWidget {
  const TeacherClassesScreen({
    super.key,
    required this.api,
    required this.organizationId,
    required this.workplaceLabel,
  });
  final TeacherApi api;
  final String? organizationId;
  final String workplaceLabel;
  @override
  State<TeacherClassesScreen> createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends State<TeacherClassesScreen> {
  late Future<List<TeacherClassData>> _future;
  bool _managed = false;
  String _search = '';
  String _status = '';
  final _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<TeacherClassData>> _load() async {
    final classes = _managed
        ? (await teacherAllPages(
            widget.api,
            '/classes',
            'classes',
          )).map(TeacherClassData.new).toList()
        : await teacherAssignedClasses(widget.api);
    return classes.where((c) => c.inScope(widget.organizationId)).toList();
  }

  void _reload() => setState(() {
    _future = _load();
  });
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Danh sách lớp',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // Personal class creation is explicitly authorized for a Teacher.
                // Org membership alone never grants this shortcut.
                if (widget.organizationId == null)
                  IconButton(
                    tooltip: 'Tạo lớp cá nhân',
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await teacherPush<Object?>(
                        context,
                        TeacherClassEditor(api: widget.api),
                      );
                      if (mounted) _reload();
                    },
                  ),
              ],
            ),
            Text(widget.workplaceLabel),
            AppSpacing.vGap12,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ChoiceChip(
                  label: const Text('Được phân công'),
                  selected: !_managed,
                  onSelected: (_) => setState(() {
                    _managed = false;
                    _future = _load();
                  }),
                ),
                ChoiceChip(
                  label: const Text('Có quyền truy cập'),
                  selected: _managed,
                  onSelected: (_) => setState(() {
                    _managed = true;
                    _future = _load();
                  }),
                ),
              ],
            ),
            AppSpacing.vGap16,
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _search = value),
              decoration: const InputDecoration(
                labelText: 'Tìm lớp',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            AppSpacing.vGap12,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (final item in const {
                  '': 'Tất cả',
                  'active': 'Đang dạy',
                  'draft': 'Nháp',
                  'archived': 'Lưu trữ',
                }.entries)
                  FilterChip(
                    label: Text(item.value),
                    selected: _status == item.key,
                    onSelected: (_) => setState(() => _status = item.key),
                  ),
              ],
            ),
          ],
        ),
      ),
      Expanded(
        child: FutureBuilder<List<TeacherClassData>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return TeacherErrorView(error: snapshot.error!, onRetry: _reload);
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final classes = snapshot.data!
                .where(
                  (c) =>
                      c.name.toLowerCase().contains(_search.toLowerCase()) &&
                      (_status.isEmpty || c.json['status'] == _status),
                )
                .toList();
            return RefreshIndicator(
              onRefresh: () async {
                _reload();
                await _future;
              },
              child: classes.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      children: [
                        EmptyState(
                          style: EmptyStateStyle.inline,
                          icon: Icons.school_outlined,
                          title: _search.isNotEmpty || _status.isNotEmpty
                              ? 'Chưa tìm thấy lớp'
                              : 'Lớp học sẽ xuất hiện ở đây',
                          message: _search.isNotEmpty || _status.isNotEmpty
                              ? 'Thử từ khóa khác hoặc xóa bộ lọc để xem thêm lớp.'
                              : 'Bạn chưa có lớp ${_managed ? 'có quyền truy cập' : 'được phân công'} tại ${widget.workplaceLabel}.',
                          actionLabel: _search.isNotEmpty || _status.isNotEmpty
                              ? 'Xóa bộ lọc'
                              : null,
                          onAction: _search.isNotEmpty || _status.isNotEmpty
                              ? () => setState(() {
                                  _search = '';
                                  _status = '';
                                  _searchController.clear();
                                })
                              : null,
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        0,
                        AppSpacing.screenPadding,
                        AppSpacing.xl,
                      ),
                      itemCount: classes.length,
                      separatorBuilder: (_, _) => AppSpacing.vGap12,
                      itemBuilder: (context, index) {
                        final row = classes[index];
                        return TeacherClassCard(
                          classData: row,
                          workplaceLabel: widget.workplaceLabel,
                          onTap: () => teacherPush<Object?>(
                            context,
                            TeacherClassScreen(
                              api: widget.api,
                              classId: row.id,
                              workplaceLabel: widget.workplaceLabel,
                            ),
                          ),
                        );
                      },
                    ),
            );
          },
        ),
      ),
    ],
  );
}
