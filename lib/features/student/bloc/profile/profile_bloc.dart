import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/data/models/user_model.dart';
import 'package:study/features/student/bloc/profile/profile_event.dart';
import 'package:study/features/student/bloc/profile/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileInitial()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileInProgress());

    // Mock user data — replace với real auth service
    await Future<void>.delayed(const Duration(milliseconds: 300));

    emit(const ProfileSuccess(
      user: UserModel(
        id: 'user-1',
        email: 'student@example.com',
        fullName: 'Nguyen Van A',
        phone: '0901234567',
        bio: 'Hoc sinh lop 10A1',
      ),
    ));
  }

  Future<void> _onLogoutRequested(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // TODO: Call auth service logout
    emit(const ProfileLoggedOut());
  }
}
