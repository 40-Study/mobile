import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/learning/learning_bloc.dart';
import 'package:study/features/student/bloc/learning/learning_event.dart';
import 'package:study/features/student/bloc/learning/learning_state.dart';
import 'package:study/features/student/presentation/learning/course_detail_screen.dart';
import 'package:study/features/student/presentation/learning/widgets/course_card.dart';
import 'package:study/features/student/presentation/learning/widgets/course_filter_chips.dart';
import 'package:study/features/student/presentation/notification/notification_screen.dart';
import 'package:study/features/student/repository/student_repository_impl.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/empty_state.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<LearningBloc>().add(const LearningStarted());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCourseDetail(String enrollmentId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) =>
              CourseDetailBloc(StudentRepositoryImpl())
                ..add(CourseDetailStarted(enrollmentId)),
          child: const CourseDetailScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Học tập'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Thông báo',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const NotificationScreen(),
              ),
            ),
          ),
          AppSpacing.hGap8,
        ],
      ),
      body: BlocBuilder<LearningBloc, LearningState>(
        builder: (context, state) {
          return switch (state) {
            LearningInitial() || LearningInProgress() => const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            LearningFailure(:final message) => _buildError(context, message),
            LearningSuccess() => _buildContent(context, state),
          };
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: AppSpacing.paddingScreenAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sync_problem, size: 44, color: cs.error),
            AppSpacing.vGap12,
            Text('Không thể tải khóa học', style: tt.titleMedium),
            AppSpacing.vGap4,
            Text(
              message,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap16,
            FilledButton.icon(
              onPressed: () =>
                  context.read<LearningBloc>().add(const LearningStarted()),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LearningSuccess state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<LearningBloc>().add(const LearningRefreshed());
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.sm,
                AppSpacing.screenPadding,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Khóa học của bạn', style: tt.headlineSmall),
                  AppSpacing.vGap4,
                  Text(
                    '${state.enrollments.length} khóa học trong thư viện',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  AppSpacing.vGap16,
                  TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm khóa học',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: state.searchQuery.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                context.read<LearningBloc>().add(
                                  const LearningSearchChanged(''),
                                );
                              },
                              icon: const Icon(Icons.close_rounded),
                              tooltip: 'Xóa tìm kiếm',
                            ),
                    ),
                    onChanged: (query) {
                      context.read<LearningBloc>().add(
                        LearningSearchChanged(query),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: CourseFilterChips(
              selectedFilter: state.filter,
              onFilterChanged: (filter) {
                context.read<LearningBloc>().add(LearningFilterChanged(filter));
              },
            ),
          ),
          const SliverToBoxAdapter(child: AppSpacing.vGap16),
          if (state.filteredEnrollments.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.school_outlined,
                title: 'Không tìm thấy khóa học',
                message: 'Thử thay đổi từ khóa hoặc bộ lọc',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                0,
                AppSpacing.screenPadding,
                AppSpacing.xl,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final enrollment = state.filteredEnrollments[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: CourseCard(
                      enrollment: enrollment,
                      onTap: () => _navigateToCourseDetail(enrollment.id),
                    ),
                  );
                }, childCount: state.filteredEnrollments.length),
              ),
            ),
        ],
      ),
    );
  }
}
