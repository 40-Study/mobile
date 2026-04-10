import 'package:equatable/equatable.dart';
import '../../data/models/bi_models.dart';

enum BICentersStatus { initial, loading, success, failure }

enum CenterSortBy { revenue, roi, growth, users }

enum CenterStatusFilter { all, growing, active, declining, atRisk }

class BICentersState extends Equatable {
  const BICentersState({
    this.status = BICentersStatus.initial,
    this.centers = const [],
    this.filteredCenters = const [],
    this.searchQuery = '',
    this.sortBy = CenterSortBy.revenue,
    this.statusFilter = CenterStatusFilter.all,
    this.errorMessage,
  });

  final BICentersStatus status;
  final List<PartnerCenter> centers;
  final List<PartnerCenter> filteredCenters;
  final String searchQuery;
  final CenterSortBy sortBy;
  final CenterStatusFilter statusFilter;
  final String? errorMessage;

  BICentersState copyWith({
    BICentersStatus? status,
    List<PartnerCenter>? centers,
    List<PartnerCenter>? filteredCenters,
    String? searchQuery,
    CenterSortBy? sortBy,
    CenterStatusFilter? statusFilter,
    String? errorMessage,
  }) {
    return BICentersState(
      status: status ?? this.status,
      centers: centers ?? this.centers,
      filteredCenters: filteredCenters ?? this.filteredCenters,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      statusFilter: statusFilter ?? this.statusFilter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        centers,
        filteredCenters,
        searchQuery,
        sortBy,
        statusFilter,
        errorMessage,
      ];
}

extension CenterSortByX on CenterSortBy {
  String get label {
    switch (this) {
      case CenterSortBy.revenue:
        return 'Revenue';
      case CenterSortBy.roi:
        return 'ROI';
      case CenterSortBy.growth:
        return 'Growth';
      case CenterSortBy.users:
        return 'Users';
    }
  }
}

extension CenterStatusFilterX on CenterStatusFilter {
  String get label {
    switch (this) {
      case CenterStatusFilter.all:
        return 'All';
      case CenterStatusFilter.growing:
        return 'Growing';
      case CenterStatusFilter.active:
        return 'Active';
      case CenterStatusFilter.declining:
        return 'Declining';
      case CenterStatusFilter.atRisk:
        return 'At Risk';
    }
  }
}
