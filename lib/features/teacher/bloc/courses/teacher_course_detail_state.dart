part of 'teacher_course_detail_cubit.dart';

@immutable
sealed class TeacherCourseDetailState extends Equatable {
  const TeacherCourseDetailState();

  @override
  List<Object?> get props => [];
}

final class TeacherCourseDetailInitial extends TeacherCourseDetailState {
  const TeacherCourseDetailInitial();
}

final class TeacherCourseDetailLoading extends TeacherCourseDetailState {
  const TeacherCourseDetailLoading();
}

final class TeacherCourseDetailLoaded extends TeacherCourseDetailState {
  const TeacherCourseDetailLoaded({
    required this.detail,
    this.currentTab = 0,
  });

  final TeacherCourseDetailModel detail;
  final int currentTab;

  TeacherCourseDetailLoaded copyWith({
    TeacherCourseDetailModel? detail,
    int? currentTab,
  }) {
    return TeacherCourseDetailLoaded(
      detail: detail ?? this.detail,
      currentTab: currentTab ?? this.currentTab,
    );
  }

  @override
  List<Object?> get props => [detail, currentTab];
}

final class TeacherCourseDetailFailure extends TeacherCourseDetailState {
  const TeacherCourseDetailFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
