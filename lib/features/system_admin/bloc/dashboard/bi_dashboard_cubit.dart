import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/bi_models.dart';
import 'bi_dashboard_state.dart';

class BIDashboardCubit extends Cubit<BIDashboardState> {
  BIDashboardCubit() : super(const BIDashboardState());

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: BIDashboardStatus.loading));

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      final metrics = _getMockMetrics();
      final topCenters = _getMockTopCenters();
      final decliningCenters = _getMockDecliningCenters();
      final alerts = _getMockAlerts();

      emit(state.copyWith(
        status: BIDashboardStatus.success,
        metrics: metrics,
        topCenters: topCenters,
        decliningCenters: decliningCenters,
        alerts: alerts,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BIDashboardStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void changePeriod(TimePeriod period) {
    emit(state.copyWith(selectedPeriod: period));
    loadDashboard();
  }

  PlatformMetrics _getMockMetrics() {
    return const PlatformMetrics(
      totalRevenue: 2450000000,
      ebitda: 612500000,
      netProfit: 490000000,
      cashBalance: 1850000000,
      burnRate: 125000000,
      totalInvestment: 890000000,
      aiCost: 156000000,
      aiRevenue: 624000000,
      averageRoi: 2.75,
      revenueGrowth: 18.5,
      profitMargin: 20.0,
    );
  }

  List<PartnerCenter> _getMockTopCenters() {
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
    ];
  }

  List<PartnerCenter> _getMockDecliningCenters() {
    return [
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

  List<DashboardAlert> _getMockAlerts() {
    return [
      DashboardAlert(
        id: '1',
        title: 'Revenue Drop',
        message: 'Basic Education Hub revenue decreased 18.3% this month',
        type: AlertType.loss,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        centerId: '9',
      ),
      DashboardAlert(
        id: '2',
        title: 'High AI Cost',
        message: 'Classic Learning has high AI cost with low return',
        type: AlertType.inefficiency,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        centerId: '8',
      ),
      DashboardAlert(
        id: '3',
        title: 'Growth Milestone',
        message: 'Elite Academy reached 2,000+ active users',
        type: AlertType.milestone,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        centerId: '1',
      ),
    ];
  }
}
