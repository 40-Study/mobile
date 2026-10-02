import 'package:study/features/auth/data/models/models.dart';

sealed class ManageChildrenState {
  const ManageChildrenState();
}

class ManageChildrenInitial extends ManageChildrenState {
  const ManageChildrenInitial();
}

class ManageChildrenLoading extends ManageChildrenState {
  const ManageChildrenLoading();
}

class ManageChildrenSuccess extends ManageChildrenState {
  const ManageChildrenSuccess(this.children);
  final List<UserModel> children;
}

class ManageChildrenFailure extends ManageChildrenState {
  const ManageChildrenFailure(this.message);
  final String message;
}
