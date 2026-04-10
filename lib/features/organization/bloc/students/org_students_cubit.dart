import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/organization/data/models/models.dart';
import 'package:study/features/organization/data/repository/organization_repository.dart';

part 'org_students_state.dart';

class OrgStudentsCubit extends Cubit<OrgStudentsState> {
  OrgStudentsCubit({required OrganizationRepository repository})
      : _repository = repository,
        super(const OrgStudentsInitial());

  final OrganizationRepository _repository;

  Future<void> loadStudents({String? status, String? searchQuery}) async {
    emit(const OrgStudentsLoading());

    try {
      final students = await _repository.getStudents(
        status: status,
        searchQuery: searchQuery,
      );

      emit(OrgStudentsLoaded(
        students: students,
        currentFilter: status,
        searchQuery: searchQuery,
      ));
    } catch (e) {
      emit(OrgStudentsFailure(message: e.toString()));
    }
  }

  Future<void> search(String query) async {
    final currentState = state;
    if (currentState is OrgStudentsLoaded) {
      await loadStudents(
        status: currentState.currentFilter,
        searchQuery: query.isEmpty ? null : query,
      );
    }
  }

  Future<void> filterByStatus(String? status) async {
    final currentState = state;
    if (currentState is OrgStudentsLoaded) {
      await loadStudents(
        status: status,
        searchQuery: currentState.searchQuery,
      );
    } else {
      await loadStudents(status: status);
    }
  }

  Future<void> refresh() async {
    final currentState = state;
    if (currentState is OrgStudentsLoaded) {
      await loadStudents(
        status: currentState.currentFilter,
        searchQuery: currentState.searchQuery,
      );
    } else {
      await loadStudents();
    }
  }
}
