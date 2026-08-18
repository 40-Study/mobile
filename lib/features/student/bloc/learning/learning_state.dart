import 'package:equatable/equatable.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';

enum EnrollmentFilter { all, inProgress, completed, upcoming }

sealed class LearningState extends Equatable {
  const LearningState();

  @override
  List<Object?> get props => [];
}

final class LearningInitial extends LearningState {
  const LearningInitial();
}

final class LearningInProgress extends LearningState {
  const LearningInProgress();
}

final class LearningSuccess extends LearningState {
  const LearningSuccess({
    this.enrollments = const [],
    this.filter = EnrollmentFilter.all,
    this.searchQuery = '',
  });

  final List<EnrollmentModel> enrollments;
  final EnrollmentFilter filter;
  final String searchQuery;

  List<EnrollmentModel> get filteredEnrollments {
    var result = enrollments.where((e) {
      return switch (filter) {
        EnrollmentFilter.all => true,
        EnrollmentFilter.inProgress =>
          e.status == 'active' && (e.progressPercentage) < 100,
        EnrollmentFilter.completed =>
          e.completedAt != null || (e.progressPercentage) >= 100,
        EnrollmentFilter.upcoming => e.status == 'pending',
      };
    }).toList();

    if (searchQuery.isNotEmpty) {
      result = result.where((e) {
        final title = e.course?.title.toLowerCase() ?? '';
        return title.contains(searchQuery.toLowerCase());
      }).toList();
    }

    return result;
  }

  @override
  List<Object?> get props => [enrollments, filter, searchQuery];

  LearningSuccess copyWith({
    List<EnrollmentModel>? enrollments,
    EnrollmentFilter? filter,
    String? searchQuery,
  }) {
    return LearningSuccess(
      enrollments: enrollments ?? this.enrollments,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final class LearningFailure extends LearningState {
  const LearningFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
