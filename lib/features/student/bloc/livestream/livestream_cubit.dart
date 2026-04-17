import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/livestream/livestream_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

class LivestreamListCubit extends Cubit<LivestreamState> {
  LivestreamListCubit({required StudentRepository repository})
      : _repository = repository,
        super(const LivestreamInitial());

  final StudentRepository _repository;

  /// Tai danh sach livestream.
  Future<void> loadLivestreams() async {
    emit(const LivestreamLoading());
    try {
      final livestreams = await _repository.getLivestreams();
      emit(LivestreamListLoaded(livestreams: livestreams));
    } catch (e) {
      emit(LivestreamError(e.toString()));
    }
  }

  /// Lam moi.
  Future<void> refresh() async {
    final currentState = state;
    try {
      final livestreams = await _repository.getLivestreams(
        status: currentState is LivestreamListLoaded
            ? currentState.selectedStatus?.name
            : null,
      );

      if (currentState is LivestreamListLoaded) {
        emit(currentState.copyWith(
          livestreams: livestreams,
          page: 1,
          hasReachedMax: false,
        ));
      } else {
        emit(LivestreamListLoaded(livestreams: livestreams));
      }
    } catch (e) {
      emit(LivestreamError(e.toString()));
    }
  }

  /// Loc theo trang thai.
  Future<void> filterByStatus(LivestreamStatus? status) async {
    final currentState = state;
    if (currentState is! LivestreamListLoaded) return;

    emit(const LivestreamLoading());

    try {
      final livestreams = await _repository.getLivestreams(
        status: status?.name,
      );
      emit(LivestreamListLoaded(
        livestreams: livestreams,
        selectedStatus: status,
      ));
    } catch (e) {
      emit(LivestreamError(e.toString()));
    }
  }

  /// Tai them.
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! LivestreamListLoaded ||
        currentState.isLoadingMore ||
        currentState.hasReachedMax) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.page + 1;
      final moreLivestreams = await _repository.getLivestreams(
        status: currentState.selectedStatus?.name,
        page: nextPage,
      );

      if (moreLivestreams.isEmpty) {
        emit(currentState.copyWith(isLoadingMore: false, hasReachedMax: true));
      } else {
        emit(currentState.copyWith(
          livestreams: [...currentState.livestreams, ...moreLivestreams],
          isLoadingMore: false,
          page: nextPage,
        ));
      }
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }
}

class LivestreamDetailCubit extends Cubit<LivestreamState> {
  LivestreamDetailCubit({
    required StudentRepository repository,
    required String livestreamId,
  })  : _repository = repository,
        _livestreamId = livestreamId,
        super(const LivestreamInitial());

  final StudentRepository _repository;
  final String _livestreamId;

  /// Tai chi tiet livestream.
  Future<void> loadDetail() async {
    emit(const LivestreamLoading());
    try {
      final livestream = await _repository.getLivestream(_livestreamId);
      emit(LivestreamDetailLoaded(livestream: livestream));
    } catch (e) {
      emit(LivestreamError(e.toString()));
    }
  }

  /// Lam moi.
  Future<void> refresh() async {
    try {
      final livestream = await _repository.getLivestream(_livestreamId);
      emit(LivestreamDetailLoaded(livestream: livestream));
    } catch (e) {
      emit(LivestreamError(e.toString()));
    }
  }
}
