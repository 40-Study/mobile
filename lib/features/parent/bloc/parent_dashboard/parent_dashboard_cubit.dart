import 'package:bloc/bloc.dart';
import 'package:study/features/parent/bloc/parent_dashboard/parent_dashboard_state.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/data/repository/parent_repository.dart';

class ParentDashboardCubit extends Cubit<ParentDashboardState> {
  ParentDashboardCubit({required ParentRepository repository})
      : _repository = repository,
        super(const ParentDashboardInitial());

  final ParentRepository _repository;

  Future<void> loadDashboard() async {
    emit(const ParentDashboardLoading());

    try {
      final results = await Future.wait([
        _repository.getChildren(),
        _repository.getNotifications(limit: 5),
      ]);

      final children = results[0] as List<ChildModel>;
      final notifications = results[1] as List<ParentNotificationModel>;

      emit(ParentDashboardLoaded(
        children: children,
        notifications: notifications,
        parentName: 'Phu huynh', // TODO: Get from auth/profile
      ));
    } catch (e) {
      emit(ParentDashboardFailure(message: e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}
