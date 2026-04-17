import 'package:equatable/equatable.dart';
import 'package:study/features/student/data/models/models.dart';

sealed class DiscussionState extends Equatable {
  const DiscussionState();

  @override
  List<Object?> get props => [];
}

final class DiscussionInitial extends DiscussionState {
  const DiscussionInitial();
}

final class DiscussionLoading extends DiscussionState {
  const DiscussionLoading();
}

final class DiscussionListLoaded extends DiscussionState {
  const DiscussionListLoaded({
    required this.discussions,
    this.selectedCategory,
    this.sortBy = 'recent',
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.page = 1,
  });

  final List<ForumPostModel> discussions;
  final DiscussionCategory? selectedCategory;
  final String sortBy;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int page;

  DiscussionListLoaded copyWith({
    List<ForumPostModel>? discussions,
    DiscussionCategory? selectedCategory,
    String? sortBy,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? page,
    bool clearCategory = false,
  }) {
    return DiscussionListLoaded(
      discussions: discussions ?? this.discussions,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      sortBy: sortBy ?? this.sortBy,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
    );
  }

  @override
  List<Object?> get props => [
        discussions,
        selectedCategory,
        sortBy,
        isLoadingMore,
        hasReachedMax,
        page,
      ];
}

final class DiscussionDetailLoaded extends DiscussionState {
  const DiscussionDetailLoaded({
    required this.discussion,
    this.isVoting = false,
    this.isCommenting = false,
  });

  final ForumPostModel discussion;
  final bool isVoting;
  final bool isCommenting;

  DiscussionDetailLoaded copyWith({
    ForumPostModel? discussion,
    bool? isVoting,
    bool? isCommenting,
  }) {
    return DiscussionDetailLoaded(
      discussion: discussion ?? this.discussion,
      isVoting: isVoting ?? this.isVoting,
      isCommenting: isCommenting ?? this.isCommenting,
    );
  }

  @override
  List<Object?> get props => [discussion, isVoting, isCommenting];
}

final class DiscussionError extends DiscussionState {
  const DiscussionError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// Create Discussion States
sealed class CreateDiscussionState extends Equatable {
  const CreateDiscussionState();

  @override
  List<Object?> get props => [];
}

final class CreateDiscussionInitial extends CreateDiscussionState {
  const CreateDiscussionInitial();
}

final class CreateDiscussionSubmitting extends CreateDiscussionState {
  const CreateDiscussionSubmitting();
}

final class CreateDiscussionSuccess extends CreateDiscussionState {
  const CreateDiscussionSuccess(this.discussion);

  final ForumPostModel discussion;

  @override
  List<Object?> get props => [discussion];
}

final class CreateDiscussionError extends CreateDiscussionState {
  const CreateDiscussionError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
