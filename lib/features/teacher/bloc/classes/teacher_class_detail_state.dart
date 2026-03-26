part of 'teacher_class_detail_cubit.dart';

@immutable
sealed class TeacherClassDetailState extends Equatable {
  const TeacherClassDetailState();

  @override
  List<Object?> get props => [];
}

final class TeacherClassDetailInitial extends TeacherClassDetailState {
  const TeacherClassDetailInitial();
}

final class TeacherClassDetailLoading extends TeacherClassDetailState {
  const TeacherClassDetailLoading();
}

final class TeacherClassDetailLoaded extends TeacherClassDetailState {
  const TeacherClassDetailLoaded({
    required this.classModel,
    this.students = const [],
    this.teachers = const [],
    this.schedules = const [],
    this.attendances = const [],
    this.selectedTab = 0,
    this.isLoadingStudents = false,
    this.isLoadingTeachers = false,
    this.isLoadingSchedules = false,
    this.isLoadingAttendances = false,
  });

  final ClassModel classModel;
  final List<StudentModel> students;
  final List<ClassTeacherModel> teachers;
  final List<ClassScheduleModel> schedules;
  final List<AttendanceModel> attendances;
  final int selectedTab;
  final bool isLoadingStudents;
  final bool isLoadingTeachers;
  final bool isLoadingSchedules;
  final bool isLoadingAttendances;

  TeacherClassDetailLoaded copyWith({
    ClassModel? classModel,
    List<StudentModel>? students,
    List<ClassTeacherModel>? teachers,
    List<ClassScheduleModel>? schedules,
    List<AttendanceModel>? attendances,
    int? selectedTab,
    bool? isLoadingStudents,
    bool? isLoadingTeachers,
    bool? isLoadingSchedules,
    bool? isLoadingAttendances,
  }) {
    return TeacherClassDetailLoaded(
      classModel: classModel ?? this.classModel,
      students: students ?? List.of(this.students),
      teachers: teachers ?? List.of(this.teachers),
      schedules: schedules ?? List.of(this.schedules),
      attendances: attendances ?? List.of(this.attendances),
      selectedTab: selectedTab ?? this.selectedTab,
      isLoadingStudents: isLoadingStudents ?? this.isLoadingStudents,
      isLoadingTeachers: isLoadingTeachers ?? this.isLoadingTeachers,
      isLoadingSchedules: isLoadingSchedules ?? this.isLoadingSchedules,
      isLoadingAttendances: isLoadingAttendances ?? this.isLoadingAttendances,
    );
  }

  @override
  List<Object?> get props => [
        classModel,
        students,
        teachers,
        schedules,
        attendances,
        selectedTab,
        isLoadingStudents,
        isLoadingTeachers,
        isLoadingSchedules,
        isLoadingAttendances,
      ];
}

final class TeacherClassDetailFailure extends TeacherClassDetailState {
  const TeacherClassDetailFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
