import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/course_rules.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_contests_screen.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_video_upload_screen.dart';
import 'package:study/features/teacher/presentation/earnings/teacher_earnings_screen.dart';
import 'package:study/features/teacher/presentation/profile/teacher_professional_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/empty_state.dart';

import 'course_detail_screen.dart';
import 'course_metadata_editor.dart';
import 'widgets/teacher_course_card.dart';

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({super.key, this.api});
  final TeacherApi? api;
  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  late final TeacherApi _api = widget.api ?? TeacherApi();
  final _search = TextEditingController();
  final _scroll = ScrollController();
  String _status = '';
  int _page = 1;
  int _generation = 0;
  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _reload({bool reset = false}) => setState(() {
    if (reset) {
      _page = 1;
      if (_scroll.hasClients) _scroll.jumpTo(0);
    }
    _generation++;
  });
  Future<void> _open(Widget page) async {
    await teacherPush<Object?>(context, page);
    if (mounted) _reload();
  }

  Future<void> _professional() async {
    try {
      final application = await teacherLoadApplication(_api);
      if (mounted)
        await _open(
          TeacherProfessionalScreen(api: _api, application: application),
        );
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(teacherErrorMessage(error))));
    }
  }

  void _clearFilters() {
    _search.clear();
    _status = '';
    _reload(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Khóa học cá nhân', style: theme.textTheme.titleMedium),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            tooltip: 'Quản lý giảng dạy',
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  _professional();
                case 'uploads':
                  _open(TeacherVideoUploadScreen(api: _api));
                case 'contests':
                  _open(TeacherContestsScreen(api: _api));
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'profile', child: Text('Hồ sơ giảng dạy')),
              PopupMenuItem(value: 'uploads', child: Text('Phiên tải video')),
              PopupMenuItem(value: 'contests', child: Text('Cuộc thi của tôi')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(CourseMetadataEditor(api: _api)),
        icon: const Icon(Icons.add),
        label: const Text('Tạo khóa học'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.sm,
              AppSpacing.screenPadding,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Chia sẻ kiến thức, theo cách của bạn.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Card(
                  margin: EdgeInsets.zero,
                  color: cs.primaryContainer,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderLg,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: cs.primaryContainer,
                      foregroundColor: cs.onPrimaryContainer,
                      child: const Icon(Icons.account_balance_wallet_outlined),
                    ),
                    title: const Text('Thu nhập cá nhân'),
                    subtitle: const Text(
                      'Doanh thu khóa học và tài khoản nhận tiền',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _open(TeacherEarningsScreen(api: _api)),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _reload(reset: true),
                  decoration: InputDecoration(
                    labelText: 'Tìm khóa học của tôi',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      tooltip: 'Tìm kiếm',
                      onPressed: () => _reload(reset: true),
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              0,
              AppSpacing.screenPadding,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                for (final status in [
                  '',
                  'draft',
                  'pending_review',
                  'published',
                  'rejected',
                  'archived',
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(
                        status.isEmpty ? 'Tất cả' : teacherCourseStatus(status),
                      ),
                      selected: _status == status,
                      onSelected: (_) {
                        _status = status;
                        _reload(reset: true);
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: TeacherAsyncView<dynamic>(
              refreshToken: _generation,
              loading: const TeacherListPlaceholder(),
              load: () => _api.get(
                '/courses/mine',
                query: {
                  'status': _status,
                  'keyword': _search.text.trim(),
                  'page': _page,
                  'page_size': 20,
                },
              ),
              builder: (context, raw) {
                final data = teacherMap(raw),
                    courses = teacherList(raw, keys: const ['courses']);
                final total =
                    int.tryParse('${data['total']}') ?? courses.length;
                final filtered =
                    _status.isNotEmpty || _search.text.trim().isNotEmpty;
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.sm,
                    AppSpacing.screenPadding,
                    104,
                  ),
                  itemCount: courses.isEmpty ? 1 : courses.length + 2,
                  itemBuilder: (context, index) {
                    if (courses.isEmpty)
                      return EmptyState(
                        style: EmptyStateStyle.inline,
                        title: filtered
                            ? 'Không có khóa khớp bộ lọc'
                            : 'Khóa học đầu tiên của bạn',
                        message: filtered
                            ? 'Thử từ khóa khác hoặc bỏ bộ lọc để xem các khóa còn lại.'
                            : 'Bắt đầu từ một chủ đề bạn muốn chia sẻ. Khóa học luôn thuộc tài khoản cá nhân, kể cả khi bạn làm việc tại tổ chức.',
                        actionLabel: filtered
                            ? 'Xóa bộ lọc'
                            : 'Tạo khóa đầu tiên',
                        onAction: filtered
                            ? _clearFilters
                            : () => _open(CourseMetadataEditor(api: _api)),
                      );
                    if (index == 0)
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Text(
                          '$total khóa học · Cá nhân',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      );
                    if (index == courses.length + 1)
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              tooltip: 'Trang trước',
                              onPressed: _page > 1
                                  ? () {
                                      _page--;
                                      _reload();
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                            ),
                            Flexible(
                              child: Text(
                                'Trang $_page · $total khóa',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Trang sau',
                              onPressed: _page * 20 < total
                                  ? () {
                                      _page++;
                                      _reload();
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      );
                    final item = courses[index - 1];
                    return TeacherCourseCard(
                      course: item,
                      onTap: () => _open(
                        TeacherCourseDetailScreen(
                          api: _api,
                          courseId: '${item['id']}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
