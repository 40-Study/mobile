import 'package:freezed_annotation/freezed_annotation.dart';

part 'org_finance_model.freezed.dart';
part 'org_finance_model.g.dart';

@freezed
abstract class OrgFinanceModel with _$OrgFinanceModel {
  const factory OrgFinanceModel({
    // === REVENUE ===
    @JsonKey(name: 'gross_revenue') @Default(0) double grossRevenue,
    @JsonKey(name: 'monthly_revenue') @Default(0) double monthlyRevenue,
    @JsonKey(name: 'total_revenue') @Default(0) double totalRevenue,
    @JsonKey(name: 'course_revenue') @Default(0) double courseRevenue,
    @JsonKey(name: 'subscription_revenue') @Default(0) double subscriptionRevenue,
    @JsonKey(name: 'other_revenue') @Default(0) double otherRevenue,

    // === RECURRING REVENUE METRICS ===
    @JsonKey(name: 'mrr') @Default(0) double mrr, // Monthly Recurring Revenue
    @JsonKey(name: 'arr') @Default(0) double arr, // Annual Recurring Revenue
    @JsonKey(name: 'mrr_growth') @Default(0) double mrrGrowth,
    @JsonKey(name: 'new_mrr') @Default(0) double newMrr, // From new customers
    @JsonKey(name: 'expansion_mrr') @Default(0) double expansionMrr, // Upsells
    @JsonKey(name: 'churned_mrr') @Default(0) double churnedMrr, // Lost revenue
    @JsonKey(name: 'net_mrr_change') @Default(0) double netMrrChange,

    // === CUSTOMER METRICS ===
    @JsonKey(name: 'total_customers') @Default(0) int totalCustomers,
    @JsonKey(name: 'new_customers') @Default(0) int newCustomers,
    @JsonKey(name: 'churned_customers') @Default(0) int churnedCustomers,
    @JsonKey(name: 'active_customers') @Default(0) int activeCustomers,
    @JsonKey(name: 'arpu') @Default(0) double arpu, // Average Revenue Per User
    @JsonKey(name: 'arppu') @Default(0) double arppu, // Avg Revenue Per Paying User
    @JsonKey(name: 'ltv') @Default(0) double ltv, // Customer Lifetime Value
    @JsonKey(name: 'cac') @Default(0) double cac, // Customer Acquisition Cost
    @JsonKey(name: 'ltv_cac_ratio') @Default(0) double ltvCacRatio,
    @JsonKey(name: 'payback_months') @Default(0) double paybackMonths, // CAC Payback
    @JsonKey(name: 'churn_rate') @Default(0) double churnRate,
    @JsonKey(name: 'retention_rate') @Default(0) double retentionRate,
    @JsonKey(name: 'nrr') @Default(0) double nrr, // Net Revenue Retention

    // === SALES METRICS ===
    @JsonKey(name: 'total_orders') @Default(0) int totalOrders,
    @JsonKey(name: 'avg_order_value') @Default(0) double avgOrderValue,
    @JsonKey(name: 'conversion_rate') @Default(0) double conversionRate,
    @JsonKey(name: 'refund_rate') @Default(0) double refundRate,
    @JsonKey(name: 'total_visitors') @Default(0) int totalVisitors,
    @JsonKey(name: 'paying_conversion') @Default(0) double payingConversion,

    // === COURSE METRICS ===
    @JsonKey(name: 'total_courses_sold') @Default(0) int totalCoursesSold,
    @JsonKey(name: 'avg_course_price') @Default(0) double avgCoursePrice,
    @JsonKey(name: 'revenue_per_course') @Default(0) double revenuePerCourse,
    @JsonKey(name: 'best_selling_category') @Default('') String bestSellingCategory,
    @JsonKey(name: 'completion_rate') @Default(0) double completionRate,

    // === EXPENSES (COGS - Cost of Goods Sold) ===
    @JsonKey(name: 'teacher_payout') @Default(0) double teacherPayout,
    @JsonKey(name: 'platform_fee') @Default(0) double platformFee,
    @JsonKey(name: 'payment_processing_fee') @Default(0) double paymentProcessingFee,
    @JsonKey(name: 'refunds') @Default(0) double refunds,

    // === OPERATING EXPENSES (OPEX) ===
    @JsonKey(name: 'marketing_cost') @Default(0) double marketingCost,
    @JsonKey(name: 'staff_cost') @Default(0) double staffCost,
    @JsonKey(name: 'infrastructure_cost') @Default(0) double infrastructureCost,
    @JsonKey(name: 'other_opex') @Default(0) double otherOpex,

    // === FINANCIAL METRICS ===
    @JsonKey(name: 'gross_profit') @Default(0) double grossProfit,
    @JsonKey(name: 'gross_margin') @Default(0) double grossMargin,
    @JsonKey(name: 'operating_income') @Default(0) double operatingIncome,
    @JsonKey(name: 'operating_margin') @Default(0) double operatingMargin,
    @JsonKey(name: 'ebitda') @Default(0) double ebitda,
    @JsonKey(name: 'ebitda_margin') @Default(0) double ebitdaMargin,
    @JsonKey(name: 'net_income') @Default(0) double netIncome,
    @JsonKey(name: 'net_margin') @Default(0) double netMargin,

    // === CASH FLOW ===
    @JsonKey(name: 'pending_payout') @Default(0) double pendingPayout,
    @JsonKey(name: 'total_payout') @Default(0) double totalPayout,
    @JsonKey(name: 'cash_balance') @Default(0) double cashBalance,
    @JsonKey(name: 'accounts_receivable') @Default(0) double accountsReceivable,

    // === COMPARISON (vs last period) ===
    @JsonKey(name: 'revenue_change') @Default(0) double revenueChange,
    @JsonKey(name: 'expense_change') @Default(0) double expenseChange,
    @JsonKey(name: 'profit_change') @Default(0) double profitChange,
    @JsonKey(name: 'ebitda_change') @Default(0) double ebitdaChange,
    @JsonKey(name: 'customer_change') @Default(0) double customerChange,
    @JsonKey(name: 'arpu_change') @Default(0) double arpuChange,
    @JsonKey(name: 'ltv_change') @Default(0) double ltvChange,

    // === CHART DATA ===
    @JsonKey(name: 'revenue_data') @Default([]) List<double> revenueData,
    @JsonKey(name: 'expense_data') @Default([]) List<double> expenseData,
    @JsonKey(name: 'profit_data') @Default([]) List<double> profitData,
    @JsonKey(name: 'mrr_data') @Default([]) List<double> mrrData,
    @JsonKey(name: 'customer_data') @Default([]) List<int> customerData,
    @JsonKey(name: 'chart_labels') @Default([]) List<String> chartLabels,

    // === COHORT DATA ===
    @JsonKey(name: 'cohort_retention') @Default([]) List<CohortData> cohortRetention,

    // === TOP PERFORMERS ===
    @JsonKey(name: 'top_courses') @Default([]) List<TopCourseRevenue> topCourses,
    @JsonKey(name: 'top_categories') @Default([]) List<CategoryRevenue> topCategories,
  }) = _OrgFinanceModel;

  factory OrgFinanceModel.fromJson(Map<String, dynamic> json) =>
      _$OrgFinanceModelFromJson(json);
}

/// Extension for calculated metrics
extension OrgFinanceModelX on OrgFinanceModel {
  /// Total COGS (Cost of Goods Sold)
  double get totalCogs => teacherPayout + platformFee + paymentProcessingFee + refunds;

  /// Total Operating Expenses
  double get totalOpex => marketingCost + staffCost + infrastructureCost + otherOpex;

  /// Total Expenses
  double get totalExpenses => totalCogs + totalOpex;

  /// Health Score (0-100) based on key metrics
  double get healthScore {
    double score = 0;
    // LTV/CAC ratio > 3 is good
    if (ltvCacRatio >= 3) score += 25;
    else if (ltvCacRatio >= 2) score += 15;
    else if (ltvCacRatio >= 1) score += 5;
    // Churn < 5% is good
    if (churnRate <= 5) score += 25;
    else if (churnRate <= 10) score += 15;
    else if (churnRate <= 20) score += 5;
    // Gross Margin > 50% is good
    if (grossMargin >= 50) score += 25;
    else if (grossMargin >= 30) score += 15;
    else if (grossMargin >= 10) score += 5;
    // MRR Growth > 10% is good
    if (mrrGrowth >= 10) score += 25;
    else if (mrrGrowth >= 5) score += 15;
    else if (mrrGrowth >= 0) score += 5;
    return score;
  }
}

@freezed
abstract class CohortData with _$CohortData {
  const factory CohortData({
    required String month,
    @JsonKey(name: 'initial_customers') required int initialCustomers,
    @JsonKey(name: 'retention_rates') @Default([]) List<double> retentionRates,
  }) = _CohortData;

  factory CohortData.fromJson(Map<String, dynamic> json) =>
      _$CohortDataFromJson(json);
}

@freezed
abstract class TopCourseRevenue with _$TopCourseRevenue {
  const factory TopCourseRevenue({
    required String id,
    required String name,
    @JsonKey(name: 'teacher_name') String? teacherName,
    @Default(0) double revenue,
    @JsonKey(name: 'units_sold') @Default(0) int unitsSold,
    @Default(0) double growth,
    String? thumbnail,
  }) = _TopCourseRevenue;

  factory TopCourseRevenue.fromJson(Map<String, dynamic> json) =>
      _$TopCourseRevenueFromJson(json);
}

@freezed
abstract class CategoryRevenue with _$CategoryRevenue {
  const factory CategoryRevenue({
    required String name,
    @Default(0) double revenue,
    @Default(0) double percentage,
    @Default(0) int courseCount,
    @Default(0) double growth,
  }) = _CategoryRevenue;

  factory CategoryRevenue.fromJson(Map<String, dynamic> json) =>
      _$CategoryRevenueFromJson(json);
}

@freezed
abstract class OrgTransactionModel with _$OrgTransactionModel {
  const factory OrgTransactionModel({
    required String id,
    required String title,
    required double amount,
    @JsonKey(name: 'transaction_type') required String transactionType,
    String? description,
    @JsonKey(name: 'teacher_name') String? teacherName,
    @JsonKey(name: 'student_name') String? studentName,
    @JsonKey(name: 'course_name') String? courseName,
    @JsonKey(name: 'created_at') required String createdAt,
    @Default('completed') String status,
  }) = _OrgTransactionModel;

  factory OrgTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$OrgTransactionModelFromJson(json);
}
