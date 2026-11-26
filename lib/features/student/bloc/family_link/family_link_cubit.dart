import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/family_link/family_link_state.dart';
import 'package:study/features/student/repository/student_repository.dart';

class FamilyLinkCubit extends Cubit<FamilyLinkState> {
  FamilyLinkCubit(this._repository) : super(const FamilyLinkInitial());

  final StudentRepository _repository;

  Future<void> load() async {
    emit(const FamilyLinkLoading());

    // Fetch cả 2 song song
    final (requestsResult, parentsResult) = await (
      _repository.getIncomingLinkRequests(),
      _repository.getLinkedParents(),
    ).wait;

    // Nếu cả 2 đều fail, show error
    if (requestsResult.isFailure && parentsResult.isFailure) {
      final error = requestsResult.errorOrNull ?? parentsResult.errorOrNull;
      emit(FamilyLinkFailure(error?.message ?? 'Không thể tải dữ liệu'));
      return;
    }

    // Show partial data nếu 1 trong 2 fail
    emit(FamilyLinkSuccess(
      pendingRequests: requestsResult.valueOrNull ?? [],
      linkedParents: parentsResult.valueOrNull ?? [],
    ));
  }

  Future<void> refresh() => load();

  Future<bool> respondToRequest(String requestId, {required bool accept}) async {
    final current = state;
    if (current is! FamilyLinkSuccess) return false;

    emit(current.copyWith(isResponding: true));

    final result = await _repository.respondLinkRequest(
      requestId,
      accept: accept,
    );

    if (result.isFailure) {
      emit(current.copyWith(isResponding: false));
      return false;
    }

    // Reload data sau khi respond
    await load();
    return true;
  }

  Future<bool> unlinkParent(String parentId) async {
    final current = state;
    if (current is! FamilyLinkSuccess) return false;

    emit(current.copyWith(isResponding: true));

    final result = await _repository.unlinkParent(parentId);

    if (result.isFailure) {
      emit(current.copyWith(isResponding: false));
      return false;
    }

    // Remove từ local list
    final updated = current.linkedParents
        .where((p) => p.id != parentId)
        .toList();
    emit(current.copyWith(linkedParents: updated, isResponding: false));
    return true;
  }
}
