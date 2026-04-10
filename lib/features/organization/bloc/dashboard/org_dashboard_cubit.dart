import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/organization/data/models/models.dart';
import 'package:study/features/organization/data/repository/organization_repository.dart';

part 'org_dashboard_state.dart';

class OrgDashboardCubit extends Cubit<OrgDashboardState> {
  OrgDashboardCubit({required OrganizationRepository repository})
      : _repository = repository,
        super(const OrgDashboardInitial());

  final OrganizationRepository _repository;

  Future<void> loadDashboard() async {
    emit(const OrgDashboardLoading());

    try {
      final results = await Future.wait([
        _repository.getStats(),
        _repository.getActivities(limit: 5),
        _repository.getCourseRevenue(limit: 5),
        _repository.getTeacherRevenue(limit: 5),
        _repository.getFinanceAlerts(),
      ]);

      emit(OrgDashboardLoaded(
        stats: results[0] as OrgStatsModel,
        activities: results[1] as List<OrgActivityModel>,
        topCourses: results[2] as List<CourseRevenueModel>,
        topTeachers: results[3] as List<TeacherRevenueModel>,
        financeAlerts: results[4] as List<FinanceAlertModel>,
      ));
    } catch (e) {
      emit(OrgDashboardFailure(message: e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}
