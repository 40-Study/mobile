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
    this.schedules = const [],
    this.assignments = const [],
    this.documents = const [],
    this.selectedTab = 0,
    this.isLoadingStudents = false,
    this.isLoadingSchedules = false,
    this.isLoadingAssignments = false,
    this.isLoadingDocuments = false,
    this.selectedStudentDetail,
    this.isLoadingStudentDetail = false,
  });

  final ClassModel classModel;
  final List<StudentModel> students;
  final List<ClassScheduleModel> schedules;
  final List<ClassAssignmentModel> assignments;
  final List<ClassDocumentModel> documents;
  final int selectedTab;
  final bool isLoadingStudents;
  final bool isLoadingSchedules;
  final bool isLoadingAssignments;
  final bool isLoadingDocuments;
  final StudentDetailModel? selectedStudentDetail;
  final bool isLoadingStudentDetail;

  TeacherClassDetailLoaded copyWith({
    ClassModel? classModel,
    List<StudentModel>? students,
    List<ClassScheduleModel>? schedules,
    List<ClassAssignmentModel>? assignments,
    List<ClassDocumentModel>? documents,
    int? selectedTab,
    bool? isLoadingStudents,
    bool? isLoadingSchedules,
    bool? isLoadingAssignments,
    bool? isLoadingDocuments,
    StudentDetailModel? selectedStudentDetail,
    bool? isLoadingStudentDetail,
    bool clearStudentDetail = false,
  }) {
    return TeacherClassDetailLoaded(
      classModel: classModel ?? this.classModel,
      students: students ?? List.of(this.students),
      schedules: schedules ?? List.of(this.schedules),
      assignments: assignments ?? List.of(this.assignments),
      documents: documents ?? List.of(this.documents),
      selectedTab: selectedTab ?? this.selectedTab,
      isLoadingStudents: isLoadingStudents ?? this.isLoadingStudents,
      isLoadingSchedules: isLoadingSchedules ?? this.isLoadingSchedules,
      isLoadingAssignments: isLoadingAssignments ?? this.isLoadingAssignments,
      isLoadingDocuments: isLoadingDocuments ?? this.isLoadingDocuments,
      selectedStudentDetail:
          clearStudentDetail ? null : (selectedStudentDetail ?? this.selectedStudentDetail),
      isLoadingStudentDetail: isLoadingStudentDetail ?? this.isLoadingStudentDetail,
    );
  }

  @override
  List<Object?> get props => [
        classModel,
        students,
        schedules,
        assignments,
        documents,
        selectedTab,
        isLoadingStudents,
        isLoadingSchedules,
        isLoadingAssignments,
        isLoadingDocuments,
        selectedStudentDetail,
        isLoadingStudentDetail,
      ];
}

final class TeacherClassDetailFailure extends TeacherClassDetailState {
  const TeacherClassDetailFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
