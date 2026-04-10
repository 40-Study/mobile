import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/organization/data/models/models.dart';
import 'package:study/features/organization/data/repository/organization_repository.dart';

part 'org_teachers_state.dart';

class OrgTeachersCubit extends Cubit<OrgTeachersState> {
  OrgTeachersCubit({required OrganizationRepository repository})
      : _repository = repository,
        super(const OrgTeachersInitial());

  final OrganizationRepository _repository;

  Future<void> loadTeachers({String? status, String? searchQuery}) async {
    emit(const OrgTeachersLoading());

    try {
      final teachers = await _repository.getTeachers(
        status: status,
        searchQuery: searchQuery,
      );

      emit(OrgTeachersLoaded(
        teachers: teachers,
        currentFilter: status,
        searchQuery: searchQuery,
      ));
    } catch (e) {
      emit(OrgTeachersFailure(message: e.toString()));
    }
  }

  Future<void> search(String query) async {
    final currentState = state;
    if (currentState is OrgTeachersLoaded) {
      await loadTeachers(
        status: currentState.currentFilter,
        searchQuery: query.isEmpty ? null : query,
      );
    }
  }

  Future<void> filterByStatus(String? status) async {
    final currentState = state;
    if (currentState is OrgTeachersLoaded) {
      await loadTeachers(
        status: status,
        searchQuery: currentState.searchQuery,
      );
    } else {
      await loadTeachers(status: status);
    }
  }

  Future<void> inviteTeacher(String email) async {
    try {
      await _repository.inviteTeacher(email);
      await loadTeachers();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateTeacherStatus(String teacherId, String status) async {
    try {
      await _repository.updateTeacherStatus(teacherId, status);
      await loadTeachers();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> refresh() async {
    final currentState = state;
    if (currentState is OrgTeachersLoaded) {
      await loadTeachers(
        status: currentState.currentFilter,
        searchQuery: currentState.searchQuery,
      );
    } else {
      await loadTeachers();
    }
  }
}
