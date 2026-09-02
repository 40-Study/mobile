import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/contribution/contribution_state.dart';
import 'package:study/features/student/repository/student_repository.dart';

class ContributionCubit extends Cubit<ContributionState> {
  ContributionCubit(this._repository) : super(const ContributionInitial());

  final StudentRepository _repository;

  Future<void> load(String userId) async {
    emit(const ContributionLoading());

    final result = await _repository.getContributions(userId);

    result.when(
      success: (data) => emit(ContributionSuccess(data)),
      failure: (f) => emit(ContributionFailure(f.message ?? 'Lỗi tải dữ liệu')),
    );
  }
}
