import 'package:equatable/equatable.dart';
import '../../data/models/bi_models.dart';

enum BIDashboardStatus { initial, loading, success, failure }

class BIDashboardState extends Equatable {
  const BIDashboardState({
    this.status = BIDashboardStatus.initial,
    this.metrics,
    this.topCenters = const [],
    this.decliningCenters = const [],
    this.alerts = const [],
    this.selectedPeriod = TimePeriod.month,
    this.errorMessage,
  });

  final BIDashboardStatus status;
  final PlatformMetrics? metrics;
  final List<PartnerCenter> topCenters;
  final List<PartnerCenter> decliningCenters;
  final List<DashboardAlert> alerts;
  final TimePeriod selectedPeriod;
  final String? errorMessage;

  BIDashboardState copyWith({
    BIDashboardStatus? status,
    PlatformMetrics? metrics,
    List<PartnerCenter>? topCenters,
    List<PartnerCenter>? decliningCenters,
    List<DashboardAlert>? alerts,
    TimePeriod? selectedPeriod,
    String? errorMessage,
  }) {
    return BIDashboardState(
      status: status ?? this.status,
      metrics: metrics ?? this.metrics,
      topCenters: topCenters ?? this.topCenters,
      decliningCenters: decliningCenters ?? this.decliningCenters,
      alerts: alerts ?? this.alerts,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        metrics,
        topCenters,
        decliningCenters,
        alerts,
        selectedPeriod,
        errorMessage,
      ];
}

enum TimePeriod {
  week,
  month,
  quarter,
  year,
}

extension TimePeriodX on TimePeriod {
  String get label {
    switch (this) {
      case TimePeriod.week:
        return '7 days';
      case TimePeriod.month:
        return '30 days';
      case TimePeriod.quarter:
        return '90 days';
      case TimePeriod.year:
        return '1 year';
    }
  }
}
