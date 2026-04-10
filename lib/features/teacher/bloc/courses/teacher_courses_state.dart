part of 'teacher_courses_cubit.dart';

enum CourseFilter {
  all('all', 'Tất cả'),
  published('published', 'Xuất bản'),
  onSale('on_sale', 'Đang bán'),
  draft('draft', 'Bản nháp'),
  archived('archived', 'Lưu trữ');

  const CourseFilter(this.value, this.label);
  final String value;
  final String label;
}

enum CourseSortBy {
  newest('newest', 'Mới nhất'),
  oldest('oldest', 'Cũ nhất'),
  mostClasses('most_classes', 'Nhiều lớp học'),
  mostStudents('most_students', 'Nhiều học viên'),
  highestRevenue('highest_revenue', 'Doanh số cao'),
  highestRating('highest_rating', 'Đánh giá cao'),
  bestSelling('best_selling', 'Bán chạy');

  const CourseSortBy(this.value, this.label);
  final String value;
  final String label;
}

@immutable
sealed class TeacherCoursesState extends Equatable {
  const TeacherCoursesState({
    this.selectedFilter = CourseFilter.all,
    this.sortBy = CourseSortBy.newest,
    this.searchQuery = '',
  });

  final CourseFilter selectedFilter;
  final CourseSortBy sortBy;
  final String searchQuery;

  @override
  List<Object?> get props => [selectedFilter, sortBy, searchQuery];
}

final class TeacherCoursesInitial extends TeacherCoursesState {
  const TeacherCoursesInitial({
    super.selectedFilter,
    super.sortBy,
    super.searchQuery,
  });
}

final class TeacherCoursesLoading extends TeacherCoursesState {
  const TeacherCoursesLoading({
    super.selectedFilter,
    super.sortBy,
    super.searchQuery,
  });
}

final class TeacherCoursesLoaded extends TeacherCoursesState {
  const TeacherCoursesLoaded({
    required this.courses,
    super.selectedFilter,
    super.sortBy,
    super.searchQuery,
  });

  final List<CourseModel> courses;

  int get totalCount => courses.length;
  int get publishedCount =>
      courses.where((c) => c.status == 'published').length;
  int get draftCount => courses.where((c) => c.status == 'draft').length;
  int get onSaleCount =>
      courses.where((c) => c.status == 'on_sale' || c.isPublished).length;

  double get totalRevenue =>
      courses.fold(0.0, (sum, c) => sum + (c.priceValue * c.studentCount));

  TeacherCoursesLoaded copyWith({
    List<CourseModel>? courses,
    CourseFilter? selectedFilter,
    CourseSortBy? sortBy,
    String? searchQuery,
  }) {
    return TeacherCoursesLoaded(
      courses: courses ?? this.courses,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [courses, selectedFilter, sortBy, searchQuery];
}

final class TeacherCoursesFailure extends TeacherCoursesState {
  const TeacherCoursesFailure({
    required this.message,
    super.selectedFilter,
    super.sortBy,
    super.searchQuery,
  });

  final String message;

  @override
  List<Object?> get props => [message, selectedFilter, sortBy, searchQuery];
}
