import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/data/teacher_preview_api.dart';
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
    this.onChanged,
  });
  final TeacherApi api;
  final String? organizationId;
  final String workplaceLabel;
  final VoidCallback? onChanged;
  @override
  State<TeacherClassesScreen> createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends State<TeacherClassesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static const _statuses = {
    '': 'Tất cả',
    'active': 'Đang hoạt động',
    'draft': 'Nháp',
    'archived': 'Lưu trữ',
  };
  late Future<List<TeacherClassData>> _future;
  final _scrollController = ScrollController();
  bool get _preview => widget.api is TeacherPreviewApi;
  bool get _hasFilter =>
      _managed || _search.trim().isNotEmpty || _status.isNotEmpty;
  int _scopeRevision = 0;
  bool _managed = false;
  String _search = '';
  String _status = '';
  final _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<TeacherClassData>> _load() async {
    final organizationId = widget.organizationId;
    final classes = _managed
        ? (await teacherAllPages(
            widget.api,
            '/classes',
            'classes',
          )).map(TeacherClassData.new).toList()
        : await teacherAssignedClasses(widget.api);
    return classes.where((c) => c.inScope(organizationId)).toList();
  }

  @override
  void didUpdateWidget(covariant TeacherClassesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.organizationId == widget.organizationId &&
        oldWidget.api == widget.api)
      return;
    _managed = false;
    _search = '';
    _status = '';
    _searchController.clear();
    _startScope();
  }

  void _startScope() {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    _scopeRevision++;
    _future = _load();
  }

  Future<void> _reload() async {
    final future = _load();
    setState(() => _future = future);
    try {
      await future;
    } catch (_) {
      // The FutureBuilder displays the error and retry action.
    }
  }

  Future<void> _openClass(String id, {bool created = false}) async {
    var changed = created;
    await teacherPush<void>(
      context,
      TeacherClassScreen(
        api: widget.api,
        classId: id,
        workplaceLabel: widget.workplaceLabel,
        onChanged: () => changed = true,
      ),
    );
    if (changed && mounted) {
      widget.onChanged?.call();
      await _reload();
    }
  }

  Future<void> _create() async {
    final result = await teacherPush<Object?>(
      context,
      TeacherClassEditor(api: widget.api),
    );
    if (!mounted || result == null) return;
    if (result is String) {
      await _openClass(result, created: true);
      return;
    } else if (result == true) {
      widget.onChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã tạo lớp. Danh sách đang được cập nhật.'),
        ),
      );
    }
    if (mounted) await _reload();
  }

  void _clearFilters() => setState(() {
    _search = '';
    _status = '';
    _searchController.clear();
    if (_managed) {
      _managed = false;
      _startScope();
    }
  });

  Future<void> _showFilters() async {
    FocusScope.of(context).unfocus();
    var managed = _managed;
    var status = _status;
    final scope = widget.organizationId;
    final selected = await showModalBottomSheet<(bool, String)>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Lọc lớp', style: Theme.of(context).textTheme.titleLarge),
                AppSpacing.vGap12,
                const Text('Phạm vi lớp'),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    ChoiceChip(
                      label: const Text('Được phân công'),
                      selected: !managed,
                      onSelected: (_) => update(() => managed = false),
                    ),
                    ChoiceChip(
                      label: const Text('Lớp có quyền xem'),
                      selected: managed,
                      onSelected: (_) => update(() => managed = true),
                    ),
                  ],
                ),
                AppSpacing.vGap8,
                const Text('Trạng thái'),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    for (final item in _statuses.entries)
                      ChoiceChip(
                        label: Text(item.value),
                        selected: item.key == status,
                        onSelected: (_) => update(() => status = item.key),
                      ),
                  ],
                ),
                AppSpacing.vGap12,
                FilledButton(
                  onPressed: () => Navigator.pop(context, (managed, status)),
                  child: const Text('Áp dụng'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted || selected == null || scope != widget.organizationId) return;
    setState(() {
      _status = selected.$2;
      if (_managed != selected.$1) {
        _managed = selected.$1;
        _startScope();
      }
    });
  }

  Widget _filters(BuildContext context) {
    final search = TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _search = value),
      decoration: InputDecoration(
        labelText: 'Tìm lớp',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _search.isEmpty
            ? null
            : IconButton(
                tooltip: 'Xóa từ khóa',
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() {
                  _search = '';
                  _searchController.clear();
                }),
              ),
      ),
    );
    final filter = OutlinedButton.icon(
      onPressed: _showFilters,
      icon: const Icon(Icons.filter_list),
      label: const Text('Lọc'),
    );
    final scope = _managed ? 'Lớp có quyền xem' : 'Được phân công';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 280 ||
                MediaQuery.textScalerOf(context).scale(14) > 20) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [search, AppSpacing.vGap8, filter],
              );
            }
            return Row(
              children: [
                Expanded(child: search),
                AppSpacing.hGap8,
                filter,
              ],
            );
          },
        ),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                _status.isEmpty ? scope : '$scope · ${_statuses[_status]}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            if (widget.organizationId == null && !_preview)
              TextButton.icon(
                onPressed: _create,
                icon: const Icon(Icons.add),
                label: const Text('Tạo lớp'),
              ),
          ],
        ),
        AppSpacing.vGap8,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<TeacherClassData>>(
      key: ValueKey(_scopeRevision),
      future: _future,
      builder: (context, snapshot) {
        final ready = snapshot.connectionState == ConnectionState.done;
        final data = snapshot.data;
        final query = _search.trim().toLowerCase();
        final classes =
            data?.where((c) {
              final code = c.json['class_code'] ?? c.json['code'] ?? '';
              return ('${c.name} $code'.toLowerCase().contains(query)) &&
                  (_status.isEmpty || c.json['status'] == _status);
            }).toList() ??
            const <TeacherClassData>[];
        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView.builder(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            itemCount: classes.isEmpty || snapshot.hasError
                ? 2
                : classes.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _filters(context);
              if (snapshot.hasError && ready)
                return TeacherErrorView(
                  error: snapshot.error!,
                  onRetry: _reload,
                );
              if (!ready && data == null)
                return const Center(child: CircularProgressIndicator());
              if (classes.isEmpty)
                return EmptyState(
                  style: EmptyStateStyle.inline,
                  icon: Icons.school_outlined,
                  title: _hasFilter
                      ? 'Không tìm thấy lớp phù hợp'
                      : 'Chưa có lớp',
                  message: _hasFilter
                      ? 'Thử từ khóa khác hoặc xóa bộ lọc để xem thêm lớp.'
                      : _managed
                      ? 'Bạn chưa có lớp có thể xem tại nơi làm việc này.'
                      : 'Bạn chưa được phân công lớp tại nơi làm việc này.',
                  actionLabel: _hasFilter ? 'Xóa bộ lọc' : null,
                  onAction: _hasFilter ? _clearFilters : null,
                );
              final row = classes[index - 1];
              return Padding(
                key: ValueKey(row.id),
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: TeacherClassCard(
                  classData: row,
                  onTap: () => _openClass(row.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
