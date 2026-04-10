import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/bi_models.dart';
import 'bi_centers_state.dart';

class BICentersCubit extends Cubit<BICentersState> {
  BICentersCubit() : super(const BICentersState());

  Future<void> loadCenters() async {
    emit(state.copyWith(status: BICentersStatus.loading));

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      final centers = _getMockCenters();

      emit(state.copyWith(
        status: BICentersStatus.success,
        centers: centers,
        filteredCenters: centers,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BICentersStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      emit(state.copyWith(
        filteredCenters: state.centers,
        searchQuery: '',
      ));
      return;
    }

    final filtered = state.centers
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    emit(state.copyWith(
      filteredCenters: filtered,
      searchQuery: query,
    ));
  }

  void setSortBy(CenterSortBy sortBy) {
    final sorted = List<PartnerCenter>.from(state.filteredCenters);

    switch (sortBy) {
      case CenterSortBy.revenue:
        sorted.sort((a, b) => b.revenue.compareTo(a.revenue));
        break;
      case CenterSortBy.roi:
        sorted.sort((a, b) => b.roi.compareTo(a.roi));
        break;
      case CenterSortBy.growth:
        sorted.sort((a, b) => b.growthPercentage.compareTo(a.growthPercentage));
        break;
      case CenterSortBy.users:
        sorted.sort((a, b) => b.totalUsers.compareTo(a.totalUsers));
        break;
    }

    emit(state.copyWith(
      filteredCenters: sorted,
      sortBy: sortBy,
    ));
  }

  void setFilter(CenterStatusFilter filter) {
    List<PartnerCenter> filtered;

    if (filter == CenterStatusFilter.all) {
      filtered = state.centers;
    } else {
      final status = switch (filter) {
        CenterStatusFilter.all => null,
        CenterStatusFilter.growing => CenterStatus.growing,
        CenterStatusFilter.active => CenterStatus.active,
        CenterStatusFilter.declining => CenterStatus.declining,
        CenterStatusFilter.atRisk => CenterStatus.atRisk,
      };
      filtered = state.centers.where((c) => c.status == status).toList();
    }

    emit(state.copyWith(
      filteredCenters: filtered,
      statusFilter: filter,
    ));
  }

  List<PartnerCenter> _getMockCenters() {
    return [
      PartnerCenter(
        id: '1',
        name: 'Elite Academy',
        logoUrl: '',
        revenue: 580000000,
        revenueContribution: 23.7,
        growthPercentage: 32.5,
        investment: 145000000,
        roi: 4.0,
        aiUsage: 85.0,
        aiCost: 38000000,
        aiRevenue: 152000000,
        totalUsers: 2450,
        totalCourses: 45,
        status: CenterStatus.growing,
        joinedDate: DateTime(2023, 3, 15),
      ),
      PartnerCenter(
        id: '2',
        name: 'Future Learn Hub',
        logoUrl: '',
        revenue: 420000000,
        revenueContribution: 17.1,
        growthPercentage: 24.8,
        investment: 120000000,
        roi: 3.5,
        aiUsage: 78.0,
        aiCost: 28000000,
        aiRevenue: 112000000,
        totalUsers: 1890,
        totalCourses: 38,
        status: CenterStatus.growing,
        joinedDate: DateTime(2023, 5, 20),
      ),
      PartnerCenter(
        id: '3',
        name: 'Smart Study Center',
        logoUrl: '',
        revenue: 385000000,
        revenueContribution: 15.7,
        growthPercentage: 18.2,
        investment: 110000000,
        roi: 3.5,
        aiUsage: 72.0,
        aiCost: 24000000,
        aiRevenue: 96000000,
        totalUsers: 1650,
        totalCourses: 32,
        status: CenterStatus.active,
        joinedDate: DateTime(2023, 2, 10),
      ),
      PartnerCenter(
        id: '4',
        name: 'NextGen Education',
        logoUrl: '',
        revenue: 320000000,
        revenueContribution: 13.1,
        growthPercentage: 15.5,
        investment: 95000000,
        roi: 3.4,
        aiUsage: 68.0,
        aiCost: 20000000,
        aiRevenue: 80000000,
        totalUsers: 1420,
        totalCourses: 28,
        status: CenterStatus.active,
        joinedDate: DateTime(2023, 4, 5),
      ),
      PartnerCenter(
        id: '5',
        name: 'Digital Campus',
        logoUrl: '',
        revenue: 275000000,
        revenueContribution: 11.2,
        growthPercentage: 8.3,
        investment: 88000000,
        roi: 3.1,
        aiUsage: 55.0,
        aiCost: 15000000,
        aiRevenue: 55000000,
        totalUsers: 1180,
        totalCourses: 22,
        status: CenterStatus.active,
        joinedDate: DateTime(2023, 1, 15),
      ),
      PartnerCenter(
        id: '6',
        name: 'EduTech Plus',
        logoUrl: '',
        revenue: 195000000,
        revenueContribution: 8.0,
        growthPercentage: 4.2,
        investment: 72000000,
        roi: 2.7,
        aiUsage: 45.0,
        aiCost: 12000000,
        aiRevenue: 39000000,
        totalUsers: 850,
        totalCourses: 18,
        status: CenterStatus.active,
        joinedDate: DateTime(2023, 6, 10),
      ),
      PartnerCenter(
        id: '7',
        name: 'Knowledge Hub',
        logoUrl: '',
        revenue: 155000000,
        revenueContribution: 6.3,
        growthPercentage: -2.5,
        investment: 68000000,
        roi: 2.3,
        aiUsage: 38.0,
        aiCost: 10000000,
        aiRevenue: 28000000,
        totalUsers: 680,
        totalCourses: 15,
        status: CenterStatus.declining,
        joinedDate: DateTime(2022, 10, 20),
      ),
      PartnerCenter(
        id: '8',
        name: 'Classic Learning',
        logoUrl: '',
        revenue: 125000000,
        revenueContribution: 5.1,
        growthPercentage: -12.5,
        investment: 85000000,
        roi: 1.47,
        aiUsage: 25.0,
        aiCost: 8000000,
        aiRevenue: 12000000,
        totalUsers: 450,
        totalCourses: 15,
        status: CenterStatus.declining,
        joinedDate: DateTime(2022, 8, 5),
      ),
      PartnerCenter(
        id: '9',
        name: 'Basic Education Hub',
        logoUrl: '',
        revenue: 98000000,
        revenueContribution: 4.0,
        growthPercentage: -18.3,
        investment: 92000000,
        roi: 1.07,
        aiUsage: 15.0,
        aiCost: 5000000,
        aiRevenue: 4500000,
        totalUsers: 320,
        totalCourses: 12,
        status: CenterStatus.atRisk,
        joinedDate: DateTime(2022, 11, 20),
      ),
    ];
  }
}
