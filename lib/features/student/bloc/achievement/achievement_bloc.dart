import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/course/data/models/certificate_model.dart';
import 'package:study/features/student/bloc/achievement/achievement_event.dart';
import 'package:study/features/student/bloc/achievement/achievement_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/repository/student_repository.dart';

class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  AchievementBloc(this._repository) : super(const AchievementInitial()) {
    on<AchievementStarted>(_onStarted);
    on<AchievementTabChanged>(_onTabChanged);
  }

  final StudentRepository _repository;

  Future<void> _onStarted(
    AchievementStarted event,
    Emitter<AchievementState> emit,
  ) async {
    emit(const AchievementInProgress());

    final (stats, badges) = await (
      _repository.getStats(),
      _repository.getBadges(),
    ).wait;

    if (stats.isFailure) {
      emit(AchievementFailure(stats.errorOrNull?.message ?? 'Loi'));
      return;
    }

    emit(AchievementSuccess(
      stats: stats.valueOrNull ?? const StudentStatsModel(),
      badges: badges.valueOrNull ?? [],
      certificates: _mockCertificates(),
    ));
  }

  List<CertificateModel> _mockCertificates() {
    return [
      CertificateModel(
        id: '1',
        certificateNumber: 'CERT-2024-001',
        courseTitle: 'UI/UX Design Fundamentals',
        instructorName: 'Alex Johnson',
        issueDate: DateTime(2024, 4, 20),
      ),
      CertificateModel(
        id: '2',
        certificateNumber: 'CERT-2024-002',
        courseTitle: 'Design Thinking for Designers',
        instructorName: 'David Chen',
        issueDate: DateTime(2024, 4, 5),
      ),
      CertificateModel(
        id: '3',
        certificateNumber: 'CERT-2024-003',
        courseTitle: 'Python từ cơ bản đến nâng cao',
        instructorName: 'Nguyễn Minh Anh',
        issueDate: DateTime(2024, 3, 15),
      ),
      CertificateModel(
        id: '4',
        certificateNumber: 'CERT-2024-004',
        courseTitle: 'Lập trình Web với React',
        instructorName: 'Trần Hoàng Nam',
        issueDate: DateTime(2024, 2, 28),
      ),
    ];
  }

  void _onTabChanged(
    AchievementTabChanged event,
    Emitter<AchievementState> emit,
  ) {
    final currentState = state;
    if (currentState is AchievementSuccess) {
      emit(currentState.copyWith(selectedTab: event.tab));
    }
  }
}
