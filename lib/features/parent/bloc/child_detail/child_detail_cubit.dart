import 'package:bloc/bloc.dart';
import 'package:study/features/parent/bloc/child_detail/child_detail_state.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/data/repository/parent_repository.dart';

class ChildDetailCubit extends Cubit<ChildDetailState> {
  ChildDetailCubit({required ParentRepository repository})
      : _repository = repository,
        super(const ChildDetailInitial());

  final ParentRepository _repository;

  Future<void> loadChildDetail(ChildModel child) async {
    emit(const ChildDetailLoading());

    try {
      final results = await Future.wait([
        _repository.getChildClasses(child.studentId ?? child.id),
        _repository.getAllChildAttendances(studentId: child.studentId ?? child.id),
        _repository.getChildEnrollments(child.userId ?? child.id),
      ]);

      final classes = results[0] as List<ChildClassModel>;
      final attendances = results[1] as List<ChildAttendanceModel>;
      final enrollments = results[2] as List<ChildEnrollmentModel>;

      emit(ChildDetailLoaded(
        child: child,
        classes: classes,
        attendances: attendances,
        enrollments: enrollments,
      ));
    } catch (e) {
      emit(ChildDetailFailure(message: e.toString()));
    }
  }

  Future<void> refresh(ChildModel child) async {
    await loadChildDetail(child);
  }

  Future<void> loadClassAttendances({
    required String classId,
    String? studentId,
  }) async {
    final currentState = state;
    if (currentState is! ChildDetailLoaded) return;

    try {
      final attendances = await _repository.getChildAttendances(
        classId: classId,
        studentId: studentId,
      );

      emit(currentState.copyWith(attendances: attendances));
    } catch (e) {
      // Keep current attendances on error
    }
  }
}
