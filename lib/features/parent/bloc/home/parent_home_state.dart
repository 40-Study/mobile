import 'package:study/features/parent/data/models/parent_home_data.dart';

/// Base state cho Parent Home BLoC.
sealed class ParentHomeState {
  const ParentHomeState();
}

class ParentHomeInitial extends ParentHomeState {
  const ParentHomeInitial();
}

class ParentHomeLoading extends ParentHomeState {
  const ParentHomeLoading();
}

class ParentHomeSuccess extends ParentHomeState {
  const ParentHomeSuccess({
    required this.data,
    required this.selectedChildId,
  });

  final ParentHomeData data;
  final String? selectedChildId;
}

class ParentHomeFailure extends ParentHomeState {
  const ParentHomeFailure(this.message);

  final String message;
}
