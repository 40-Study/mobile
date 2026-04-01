part of 'teacher_classes_cubit.dart';

enum ClassStatusFilter {
  all('all', 'Tất cả'),
  active('active', 'Đang học'),
  completed('completed', 'Hoàn thành'),
  cancelled('cancelled', 'Đã hủy');

  const ClassStatusFilter(this.value, this.label);
  final String value;
  final String label;
}

enum DayFilter {
  all('all', 'Tất cả'),
  monday('monday', 'Thứ 2'),
  tuesday('tuesday', 'Thứ 3'),
  wednesday('wednesday', 'Thứ 4'),
  thursday('thursday', 'Thứ 5'),
  friday('friday', 'Thứ 6'),
  saturday('saturday', 'Thứ 7'),
  sunday('sunday', 'CN');

  const DayFilter(this.value, this.label);
  final String value;
  final String label;

  int get weekday => switch (this) {
        DayFilter.monday => 1,
        DayFilter.tuesday => 2,
        DayFilter.wednesday => 3,
        DayFilter.thursday => 4,
        DayFilter.friday => 5,
        DayFilter.saturday => 6,
        DayFilter.sunday => 7,
        DayFilter.all => 0,
      };
}

enum ClassSortBy {
  newest('newest', 'Mới nhất'),
  oldest('oldest', 'Cũ nhất'),
  mostStudents('most_students', 'Nhiều học viên'),
  alphabetical('alphabetical', 'Tên A-Z'),
  startingSoon('starting_soon', 'Sắp khai giảng');

  const ClassSortBy(this.value, this.label);
  final String value;
  final String label;
}

@immutable
sealed class TeacherClassesState extends Equatable {
  const TeacherClassesState({
    this.statusFilter = ClassStatusFilter.all,
    this.courseFilter,
    this.dayFilter = DayFilter.all,
    this.sortBy = ClassSortBy.newest,
    this.searchQuery = '',
    this.availableCourses = const [],
  });

  final ClassStatusFilter statusFilter;
  final String? courseFilter;
  final DayFilter dayFilter;
  final ClassSortBy sortBy;
  final String searchQuery;
  final List<String> availableCourses;

  @override
  List<Object?> get props =>
      [statusFilter, courseFilter, dayFilter, sortBy, searchQuery, availableCourses];
}

final class TeacherClassesInitial extends TeacherClassesState {
  const TeacherClassesInitial({
    super.statusFilter,
    super.courseFilter,
    super.dayFilter,
    super.sortBy,
    super.searchQuery,
    super.availableCourses,
  });
}

final class TeacherClassesLoading extends TeacherClassesState {
  const TeacherClassesLoading({
    super.statusFilter,
    super.courseFilter,
    super.dayFilter,
    super.sortBy,
    super.searchQuery,
    super.availableCourses,
  });
}

final class TeacherClassesLoaded extends TeacherClassesState {
  const TeacherClassesLoaded({
    required this.classes,
    super.statusFilter,
    super.courseFilter,
    super.dayFilter,
    super.sortBy,
    super.searchQuery,
    super.availableCourses,
  });

  final List<ClassModel> classes;

  int get activeCount => classes.where((c) => c.isActive).length;
  int get completedCount => classes.where((c) => c.isCompleted).length;
  int get totalStudents =>
      classes.fold(0, (sum, c) => sum + c.studentCount);

  TeacherClassesLoaded copyWith({
    List<ClassModel>? classes,
    ClassStatusFilter? statusFilter,
    String? courseFilter,
    DayFilter? dayFilter,
    ClassSortBy? sortBy,
    String? searchQuery,
    List<String>? availableCourses,
  }) {
    return TeacherClassesLoaded(
      classes: classes ?? List.of(this.classes),
      statusFilter: statusFilter ?? this.statusFilter,
      courseFilter: courseFilter,
      dayFilter: dayFilter ?? this.dayFilter,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
      availableCourses: availableCourses ?? this.availableCourses,
    );
  }

  @override
  List<Object?> get props => [
        classes,
        statusFilter,
        courseFilter,
        dayFilter,
        sortBy,
        searchQuery,
        availableCourses,
      ];
}

final class TeacherClassesFailure extends TeacherClassesState {
  const TeacherClassesFailure({
    required this.message,
    super.statusFilter,
    super.courseFilter,
    super.dayFilter,
    super.sortBy,
    super.searchQuery,
    super.availableCourses,
  });

  final String message;

  @override
  List<Object?> get props => [
        message,
        statusFilter,
        courseFilter,
        dayFilter,
        sortBy,
        searchQuery,
        availableCourses,
      ];
}
