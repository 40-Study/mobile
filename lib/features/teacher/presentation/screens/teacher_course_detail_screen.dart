import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/teacher/bloc/courses/teacher_course_detail_cubit.dart';
import 'package:study/features/teacher/data/models/teacher_course_detail_model.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_course_detail/teacher_course_detail_widgets.dart';

class TeacherCourseDetailScreen extends StatefulWidget {
  const TeacherCourseDetailScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  final String courseId;
  final String courseTitle;

  @override
  State<TeacherCourseDetailScreen> createState() =>
      _TeacherCourseDetailScreenState();
}

class _TeacherCourseDetailScreenState extends State<TeacherCourseDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherCourseDetailCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.courseTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: cs.primary),
            onPressed: () {
              // TODO: Navigate to edit course
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: cs.onSurface),
            onSelected: (value) {
              // TODO: Handle menu actions
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Nhân bản khóa học'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(Icons.archive_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Lưu trữ'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: cs.error),
                    const SizedBox(width: 12),
                    Text('Xóa khóa học',
                        style: TextStyle(color: cs.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<TeacherCourseDetailCubit, TeacherCourseDetailState>(
        builder: (context, state) {
          debugPrint('TeacherCourseDetailScreen: state = $state');
          return switch (state) {
            TeacherCourseDetailInitial() ||
            TeacherCourseDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            TeacherCourseDetailLoaded(:final detail) =>
              _TeacherCourseDetailBody(detail: detail),
            TeacherCourseDetailFailure(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: AppIconSize.hero, color: cs.error),
                    const SizedBox(height: AppSpacing.lg),
                    Text(message),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: () =>
                          context.read<TeacherCourseDetailCubit>().load(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }
}

class _TeacherCourseDetailBody extends StatefulWidget {
  const _TeacherCourseDetailBody({required this.detail});
  final TeacherCourseDetailModel detail;

  @override
  State<_TeacherCourseDetailBody> createState() =>
      _TeacherCourseDetailBodyState();
}

class _TeacherCourseDetailBodyState extends State<_TeacherCourseDetailBody>
    with TickerProviderStateMixin {
  late final TabController _tabCtrl;

  static const _tabs = ['Tổng quan', 'Nội dung', 'Lớp học', 'Thống kê'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.detail;
    final cs = Theme.of(context).colorScheme;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: TeacherCourseHeroHeader(detail: d),
          ),
          SliverToBoxAdapter(
            child: Material(
              color: cs.surface,
              child: TabBar(
                controller: _tabCtrl,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
                labelColor: cs.primary,
                unselectedLabelColor: cs.onSurfaceVariant,
                indicatorColor: cs.primary,
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          TeacherCourseOverviewTab(detail: d),
          TeacherCourseContentTab(detail: d),
          TeacherCourseClassesTab(detail: d),
          TeacherCourseStatsTab(detail: d),
        ],
      ),
    );
  }
}
