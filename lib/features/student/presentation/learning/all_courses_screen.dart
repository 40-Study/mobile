import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/learning/learning_bloc.dart';
import 'package:study/features/student/bloc/learning/learning_event.dart';
import 'package:study/features/student/bloc/learning/learning_state.dart';
import 'package:study/features/student/presentation/learning/course_detail/course_detail_screen.dart';
import 'package:study/features/student/presentation/learning/widgets/course_card.dart';
import 'package:study/widgets/async_list_scaffold.dart';

class AllCoursesScreen extends StatelessWidget {
  const AllCoursesScreen({super.key});

  void _navigateToCourse(BuildContext context, String enrollmentId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => diContainer<CourseDetailBloc>()
            ..add(CourseDetailStarted(enrollmentId, isEnrollment: true)),
          child: const CourseDetailScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearningBloc, LearningState>(
      builder: (context, state) {
        final enrollments = switch (state) {
          LearningSuccess(:final enrollments) => enrollments,
          _ => <EnrollmentModel>[],
        };
        final isLoading = state is LearningInProgress;
        final error = state is LearningFailure ? state.message : null;

        return AsyncListScaffold<EnrollmentModel>(
          title: 'Khóa học của tôi',
          items: enrollments,
          isLoading: isLoading,
          error: error,
          onRefresh: () async =>
              context.read<LearningBloc>().add(const LearningRefreshed()),
          emptyIcon: Icons.school_outlined,
          emptyTitle: 'Chưa có khóa học',
          emptyMessage: 'Bạn chưa đăng ký khóa học nào.',
          itemBuilder: (context, enrollment) => CourseCard(
            enrollment: enrollment,
            onTap: () => _navigateToCourse(context, enrollment.id),
          ),
        );
      },
    );
  }
}
