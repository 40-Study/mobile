import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/discussion/discussion_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

class DiscussionListCubit extends Cubit<DiscussionState> {
  DiscussionListCubit({required StudentRepository repository})
      : _repository = repository,
        super(const DiscussionInitial());

  final StudentRepository _repository;

  /// Tai danh sach bai viet.
  Future<void> loadDiscussions() async {
    emit(const DiscussionLoading());
    try {
      final discussions = await _repository.getDiscussions();
      emit(DiscussionListLoaded(discussions: discussions));
    } catch (e) {
      emit(DiscussionError(e.toString()));
    }
  }

  /// Lam moi.
  Future<void> refresh() async {
    final currentState = state;
    try {
      final discussions = await _repository.getDiscussions(
        category: currentState is DiscussionListLoaded
            ? currentState.selectedCategory?.value
            : null,
        sort: currentState is DiscussionListLoaded
            ? currentState.sortBy
            : 'recent',
      );

      if (currentState is DiscussionListLoaded) {
        emit(currentState.copyWith(
          discussions: discussions,
          page: 1,
          hasReachedMax: false,
        ));
      } else {
        emit(DiscussionListLoaded(discussions: discussions));
      }
    } catch (e) {
      emit(DiscussionError(e.toString()));
    }
  }

  /// Loc theo danh muc.
  Future<void> filterByCategory(DiscussionCategory? category) async {
    final currentState = state;
    if (currentState is! DiscussionListLoaded) return;

    emit(const DiscussionLoading());

    try {
      final discussions = await _repository.getDiscussions(
        category: category?.value,
        sort: currentState.sortBy,
      );
      emit(DiscussionListLoaded(
        discussions: discussions,
        selectedCategory: category,
        sortBy: currentState.sortBy,
      ));
    } catch (e) {
      emit(DiscussionError(e.toString()));
    }
  }

  /// Sap xep.
  Future<void> sortBy(String sort) async {
    final currentState = state;
    if (currentState is! DiscussionListLoaded) return;

    emit(const DiscussionLoading());

    try {
      final discussions = await _repository.getDiscussions(
        category: currentState.selectedCategory?.value,
        sort: sort,
      );
      emit(currentState.copyWith(
        discussions: discussions,
        sortBy: sort,
        page: 1,
        hasReachedMax: false,
      ));
    } catch (e) {
      emit(DiscussionError(e.toString()));
    }
  }

  /// Tai them.
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! DiscussionListLoaded ||
        currentState.isLoadingMore ||
        currentState.hasReachedMax) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.page + 1;
      final moreDiscussions = await _repository.getDiscussions(
        category: currentState.selectedCategory?.value,
        sort: currentState.sortBy,
        page: nextPage,
      );

      if (moreDiscussions.isEmpty) {
        emit(currentState.copyWith(isLoadingMore: false, hasReachedMax: true));
      } else {
        emit(currentState.copyWith(
          discussions: [...currentState.discussions, ...moreDiscussions],
          isLoadingMore: false,
          page: nextPage,
        ));
      }
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }
}

class DiscussionDetailCubit extends Cubit<DiscussionState> {
  DiscussionDetailCubit({
    required StudentRepository repository,
    required String slug,
  })  : _repository = repository,
        _slug = slug,
        super(const DiscussionInitial());

  final StudentRepository _repository;
  final String _slug;

  /// Tai chi tiet bai viet.
  Future<void> loadDetail() async {
    emit(const DiscussionLoading());
    try {
      final discussion = await _repository.getDiscussion(_slug);
      emit(DiscussionDetailLoaded(discussion: discussion));
    } catch (e) {
      emit(DiscussionError(e.toString()));
    }
  }

  /// Vote.
  Future<void> vote(VoteType voteType) async {
    final currentState = state;
    if (currentState is! DiscussionDetailLoaded) return;

    emit(currentState.copyWith(isVoting: true));

    try {
      if (currentState.discussion.userVote == voteType) {
        // Remove vote
        await _repository.removeVote(currentState.discussion.id);
        final newCount = voteType == VoteType.upvote
            ? currentState.discussion.upvoteCount - 1
            : currentState.discussion.upvoteCount;
        emit(currentState.copyWith(
          discussion: currentState.discussion.copyWith(
            userVote: VoteType.none,
            upvoteCount: newCount,
          ),
          isVoting: false,
        ));
      } else {
        // Add/change vote
        await _repository.voteDiscussion(currentState.discussion.id, voteType);
        var newCount = currentState.discussion.upvoteCount;
        if (voteType == VoteType.upvote) {
          newCount += currentState.discussion.userVote == VoteType.downvote ? 1 : 1;
        } else if (currentState.discussion.userVote == VoteType.upvote) {
          newCount -= 1;
        }
        emit(currentState.copyWith(
          discussion: currentState.discussion.copyWith(
            userVote: voteType,
            upvoteCount: newCount,
          ),
          isVoting: false,
        ));
      }
    } catch (e) {
      emit(currentState.copyWith(isVoting: false));
    }
  }

  /// Binh luan.
  Future<void> addComment(String content, {String? parentId}) async {
    final currentState = state;
    if (currentState is! DiscussionDetailLoaded) return;

    emit(currentState.copyWith(isCommenting: true));

    try {
      await _repository.addComment(_slug, content, parentId: parentId);
      // Reload to get new comments
      final discussion = await _repository.getDiscussion(_slug);
      emit(DiscussionDetailLoaded(discussion: discussion));
    } catch (e) {
      emit(currentState.copyWith(isCommenting: false));
    }
  }
}

class CreateDiscussionCubit extends Cubit<CreateDiscussionState> {
  CreateDiscussionCubit({required StudentRepository repository})
      : _repository = repository,
        super(const CreateDiscussionInitial());

  final StudentRepository _repository;

  /// Tao bai viet moi.
  Future<void> create({
    required String title,
    required String content,
    required DiscussionCategory category,
  }) async {
    emit(const CreateDiscussionSubmitting());
    try {
      final discussion = await _repository.createDiscussion(
        title: title,
        content: content,
        category: category.value,
      );
      emit(CreateDiscussionSuccess(discussion));
    } catch (e) {
      emit(CreateDiscussionError(e.toString()));
    }
  }

  /// Reset state.
  void reset() {
    emit(const CreateDiscussionInitial());
  }
}
