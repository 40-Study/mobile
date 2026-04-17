import 'package:equatable/equatable.dart';
import 'package:study/features/student/data/models/models.dart';

sealed class LivestreamState extends Equatable {
  const LivestreamState();

  @override
  List<Object?> get props => [];
}

final class LivestreamInitial extends LivestreamState {
  const LivestreamInitial();
}

final class LivestreamLoading extends LivestreamState {
  const LivestreamLoading();
}

final class LivestreamListLoaded extends LivestreamState {
  const LivestreamListLoaded({
    required this.livestreams,
    this.selectedStatus,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.page = 1,
  });

  final List<LivestreamModel> livestreams;
  final LivestreamStatus? selectedStatus;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int page;

  /// Livestream dang phat.
  List<LivestreamModel> get liveNow =>
      livestreams.where((l) => l.status == LivestreamStatus.live).toList();

  /// Livestream sap toi.
  List<LivestreamModel> get upcoming =>
      livestreams.where((l) => l.status == LivestreamStatus.scheduled).toList();

  /// Livestream theo filter.
  List<LivestreamModel> get filteredLivestreams {
    if (selectedStatus == null) return livestreams;
    return livestreams.where((l) => l.status == selectedStatus).toList();
  }

  LivestreamListLoaded copyWith({
    List<LivestreamModel>? livestreams,
    LivestreamStatus? selectedStatus,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? page,
    bool clearStatus = false,
  }) {
    return LivestreamListLoaded(
      livestreams: livestreams ?? this.livestreams,
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
    );
  }

  @override
  List<Object?> get props => [
        livestreams,
        selectedStatus,
        isLoadingMore,
        hasReachedMax,
        page,
      ];
}

final class LivestreamDetailLoaded extends LivestreamState {
  const LivestreamDetailLoaded({required this.livestream});

  final LivestreamModel livestream;

  @override
  List<Object?> get props => [livestream];
}

final class LivestreamError extends LivestreamState {
  const LivestreamError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
