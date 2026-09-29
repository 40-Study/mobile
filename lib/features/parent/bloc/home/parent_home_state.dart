import 'package:equatable/equatable.dart';
import 'package:study/features/parent/data/models/models.dart';

/// Trạng thái của từng phân vùng dữ liệu trên Parent Home Screen
enum HomeSectionStatus { initial, loading, success, failure }

/// Base state cho Parent Home BLoC.
sealed class ParentHomeState extends Equatable {
  const ParentHomeState();

  @override
  List<Object?> get props => [];
}

class ParentHomeInitial extends ParentHomeState {
  const ParentHomeInitial();
}

/// Loading toàn màn hình khi mới khởi tạo ứng dụng và chưa có danh sách con
class ParentHomeLoading extends ParentHomeState {
  const ParentHomeLoading();
}

/// Trạng thái thành công hiển thị Dashboard với cơ chế Partial Failure &
/// Skeleton per-section.
class ParentHomeSuccess extends ParentHomeState {
  const ParentHomeSuccess({
    required this.children,
    required this.selectedChildId,
    this.alerts = const [],
    this.alertsStatus = HomeSectionStatus.initial,
    this.alertsErrorMessage,
    this.schedules = const [],
    this.schedulesStatus = HomeSectionStatus.initial,
    this.schedulesErrorMessage,
    this.analytics,
    this.analyticsList = const [],
    this.analyticsStatus = HomeSectionStatus.initial,
    this.analyticsErrorMessage,
  });

  final List<FamilyScopeChild> children;
  final String? selectedChildId;

  // Khối 1: Cần xử lý (Alerts - 4 Tiers)
  final List<ParentAlertItem> alerts;
  final HomeSectionStatus alertsStatus;
  final String? alertsErrorMessage;

  // Khối 2: Hôm nay / Tiếp theo (Schedules)
  final List<ParentScheduleItem> schedules;
  final HomeSectionStatus schedulesStatus;
  final String? schedulesErrorMessage;

  // Khối 3: Phân tích học tập (Analytics)
  final ParentAnalyticsData? analytics;
  final List<ParentAnalyticsData> analyticsList;
  final HomeSectionStatus analyticsStatus;
  final String? analyticsErrorMessage;

  ParentHomeData get toLegacyData => ParentHomeData(
        children: children,
        selectedChildId: selectedChildId,
        alerts: alerts,
        schedules: schedules,
        analytics: analytics,
      );

  ParentHomeSuccess copyWith({
    List<FamilyScopeChild>? children,
    String? selectedChildId,
    bool clearSelectedChild = false,
    List<ParentAlertItem>? alerts,
    HomeSectionStatus? alertsStatus,
    String? alertsErrorMessage,
    List<ParentScheduleItem>? schedules,
    HomeSectionStatus? schedulesStatus,
    String? schedulesErrorMessage,
    ParentAnalyticsData? analytics,
    List<ParentAnalyticsData>? analyticsList,
    HomeSectionStatus? analyticsStatus,
    String? analyticsErrorMessage,
  }) {
    return ParentHomeSuccess(
      children: children ?? this.children,
      selectedChildId: clearSelectedChild
          ? null
          : (selectedChildId ?? this.selectedChildId),
      alerts: alerts ?? this.alerts,
      alertsStatus: alertsStatus ?? this.alertsStatus,
      alertsErrorMessage: alertsErrorMessage ?? this.alertsErrorMessage,
      schedules: schedules ?? this.schedules,
      schedulesStatus: schedulesStatus ?? this.schedulesStatus,
      schedulesErrorMessage:
          schedulesErrorMessage ?? this.schedulesErrorMessage,
      analytics: analytics ?? this.analytics,
      analyticsList: analyticsList ?? this.analyticsList,
      analyticsStatus: analyticsStatus ?? this.analyticsStatus,
      analyticsErrorMessage:
          analyticsErrorMessage ?? this.analyticsErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        children,
        selectedChildId,
        alerts,
        alertsStatus,
        alertsErrorMessage,
        schedules,
        schedulesStatus,
        schedulesErrorMessage,
        analytics,
        analyticsList,
        analyticsStatus,
        analyticsErrorMessage,
      ];
}


/// Lỗi toàn màn hình (chỉ xảy ra khi không thể tải danh sách con ban đầu)
class ParentHomeFailure extends ParentHomeState {
  const ParentHomeFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
