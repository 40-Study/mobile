part of 'assignment_cubit.dart';

@immutable
sealed class AssignmentState extends Equatable {
  const AssignmentState();

  @override
  List<Object?> get props => [];
}

final class AssignmentInitial extends AssignmentState {
  const AssignmentInitial();
}

final class AssignmentLoading extends AssignmentState {
  const AssignmentLoading();
}

final class AssignmentLoaded extends AssignmentState {
  const AssignmentLoaded({
    required this.assignments,
    this.hasMore = false,
  });

  final List<AssignmentModel> assignments;
  final bool hasMore;

  AssignmentLoaded copyWith({
    List<AssignmentModel>? assignments,
    bool? hasMore,
  }) {
    return AssignmentLoaded(
      assignments: assignments ?? this.assignments,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [assignments, hasMore];
}

final class AssignmentFailure extends AssignmentState {
  const AssignmentFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

// Assignment Detail States
@immutable
sealed class AssignmentDetailState extends Equatable {
  const AssignmentDetailState();

  @override
  List<Object?> get props => [];
}

final class AssignmentDetailInitial extends AssignmentDetailState {
  const AssignmentDetailInitial();
}

final class AssignmentDetailLoading extends AssignmentDetailState {
  const AssignmentDetailLoading();
}

final class AssignmentDetailLoaded extends AssignmentDetailState {
  const AssignmentDetailLoaded({
    required this.sandbox,
    this.isRunning = false,
    this.isSubmitting = false,
    this.runResult,
    this.lastSubmission,
    this.errorMessage,
  });

  final AssignmentSandboxModel sandbox;
  final bool isRunning;
  final bool isSubmitting;
  final RunCodeResultModel? runResult;
  final SubmissionModel? lastSubmission;
  final String? errorMessage;

  AssignmentDetailLoaded copyWith({
    AssignmentSandboxModel? sandbox,
    bool? isRunning,
    bool? isSubmitting,
    RunCodeResultModel? runResult,
    SubmissionModel? lastSubmission,
    String? errorMessage,
  }) {
    return AssignmentDetailLoaded(
      sandbox: sandbox ?? this.sandbox,
      isRunning: isRunning ?? this.isRunning,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      runResult: runResult ?? this.runResult,
      lastSubmission: lastSubmission ?? this.lastSubmission,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        sandbox,
        isRunning,
        isSubmitting,
        runResult,
        lastSubmission,
        errorMessage,
      ];
}

final class AssignmentDetailFailure extends AssignmentDetailState {
  const AssignmentDetailFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
