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
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => CourseDetailBloc(StudentRepositoryImpl())
            ..add(CourseDetailStarted(enrollmentId)),
          child: const CourseDetailScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoc tap'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const NotificationScreen()),
            ),
          ),
        ],
      ),
      body: BlocBuilder<LearningBloc, LearningState>(
        builder: (context, state) {
          return switch (state) {
            LearningInitial() || LearningInProgress() => const Center(
                child: CircularProgressIndicator(),
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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: cs.error),
          AppSpacing.vGap16,
          Text(message),
          AppSpacing.vGap16,
          FilledButton(
            onPressed: () =>
                context.read<LearningBloc>().add(const LearningStarted()),
            child: const Text('Thu lai'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, LearningSuccess state) {
    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<LearningBloc>().add(const LearningRefreshed());
      },
      child: CustomScrollView(
        slivers: [
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tim kiem khoa hoc...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                ),
                onChanged: (query) {
                  context.read<LearningBloc>().add(LearningSearchChanged(query));
                },
              ),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: CourseFilterChips(
              selectedFilter: state.filter,
              onFilterChanged: (filter) {
                context.read<LearningBloc>().add(LearningFilterChanged(filter));
              },
            ),
          ),

          const SliverToBoxAdapter(child: AppSpacing.vGap16),

          // Course list
          if (state.filteredEnrollments.isEmpty)
            SliverFillRemaining(
              child: EmptyState(
                icon: Icons.school_outlined,
                title: 'Chua co khoa hoc nao',
                message: 'Bat dau hoc khoa hoc dau tien cua ban',
              ),
            )
          else
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final enrollment = state.filteredEnrollments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: CourseCard(
                        enrollment: enrollment,
                        onTap: () => _navigateToCourseDetail(enrollment.id),
                      ),
                    );
                  },
                  childCount: state.filteredEnrollments.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
