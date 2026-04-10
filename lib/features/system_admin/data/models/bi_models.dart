import 'package:equatable/equatable.dart';

/// Key metrics for the overview dashboard
class PlatformMetrics extends Equatable {
  const PlatformMetrics({
    required this.totalRevenue,
    required this.ebitda,
    required this.netProfit,
    required this.cashBalance,
    required this.burnRate,
    required this.totalInvestment,
    required this.aiCost,
    required this.aiRevenue,
    required this.averageRoi,
    required this.revenueGrowth,
    required this.profitMargin,
  });

  final double totalRevenue;
  final double ebitda;
  final double netProfit;
  final double cashBalance;
  final double burnRate;
  final double totalInvestment;
  final double aiCost;
  final double aiRevenue;
  final double averageRoi;
  final double revenueGrowth;
  final double profitMargin;

  @override
  List<Object?> get props => [
        totalRevenue,
        ebitda,
        netProfit,
        cashBalance,
        burnRate,
        totalInvestment,
        aiCost,
        aiRevenue,
        averageRoi,
        revenueGrowth,
        profitMargin,
      ];
}

/// Partner center summary for list and comparison
class PartnerCenter extends Equatable {
  const PartnerCenter({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.revenue,
    required this.revenueContribution,
    required this.growthPercentage,
    required this.investment,
    required this.roi,
    required this.aiUsage,
    required this.aiCost,
    required this.aiRevenue,
    required this.totalUsers,
    required this.totalCourses,
    required this.status,
    required this.joinedDate,
  });

  final String id;
  final String name;
  final String logoUrl;
  final double revenue;
  final double revenueContribution;
  final double growthPercentage;
  final double investment;
  final double roi;
  final double aiUsage;
  final double aiCost;
  final double aiRevenue;
  final int totalUsers;
  final int totalCourses;
  final CenterStatus status;
  final DateTime joinedDate;

  @override
  List<Object?> get props => [
        id,
        name,
        logoUrl,
        revenue,
        revenueContribution,
        growthPercentage,
        investment,
        roi,
        aiUsage,
        aiCost,
        aiRevenue,
        totalUsers,
        totalCourses,
        status,
        joinedDate,
      ];
}

enum CenterStatus {
  active,
  growing,
  declining,
  atRisk,
}

/// Detailed center insights
class CenterInsight extends Equatable {
  const CenterInsight({
    required this.centerId,
    required this.centerName,
    required this.revenueContribution,
    required this.revenuePercentage,
    required this.revenueTrend,
    required this.financial,
    required this.investment,
    required this.aiPerformance,
    required this.topContributors,
  });

  final String centerId;
  final String centerName;
  final double revenueContribution;
  final double revenuePercentage;
  final List<RevenueDataPoint> revenueTrend;
  final FinancialBreakdown financial;
  final InvestmentAnalysis investment;
  final AIPerformance aiPerformance;
  final List<TopContributor> topContributors;

  @override
  List<Object?> get props => [
        centerId,
        centerName,
        revenueContribution,
        revenuePercentage,
        revenueTrend,
        financial,
        investment,
        aiPerformance,
        topContributors,
      ];
}

class RevenueDataPoint extends Equatable {
  const RevenueDataPoint({
    required this.date,
    required this.value,
  });

  final DateTime date;
  final double value;

  @override
  List<Object?> get props => [date, value];
}

class FinancialBreakdown extends Equatable {
  const FinancialBreakdown({
    required this.revenue,
    required this.aiCost,
    required this.infrastructureCost,
    required this.supportCost,
    required this.otherCosts,
    required this.ebitda,
    required this.netProfit,
  });

  final double revenue;
  final double aiCost;
  final double infrastructureCost;
  final double supportCost;
  final double otherCosts;
  final double ebitda;
  final double netProfit;

  @override
  List<Object?> get props => [
        revenue,
        aiCost,
        infrastructureCost,
        supportCost,
        otherCosts,
        ebitda,
        netProfit,
      ];
}

class InvestmentAnalysis extends Equatable {
  const InvestmentAnalysis({
    required this.marketingSpend,
    required this.aiCost,
    required this.totalInvestment,
    required this.roi,
  });

  final double marketingSpend;
  final double aiCost;
  final double totalInvestment;
  final double roi;

  @override
  List<Object?> get props => [marketingSpend, aiCost, totalInvestment, roi];
}

class AIPerformance extends Equatable {
  const AIPerformance({
    required this.totalRequests,
    required this.cost,
    required this.generatedRevenue,
    required this.roi,
    required this.costPerUser,
    required this.usageTrend,
  });

  final int totalRequests;
  final double cost;
  final double generatedRevenue;
  final double roi;
  final double costPerUser;
  final List<AIUsageDataPoint> usageTrend;

  @override
  List<Object?> get props => [
        totalRequests,
        cost,
        generatedRevenue,
        roi,
        costPerUser,
        usageTrend,
      ];
}

class AIUsageDataPoint extends Equatable {
  const AIUsageDataPoint({
    required this.date,
    required this.requests,
    required this.cost,
  });

  final DateTime date;
  final int requests;
  final double cost;

  @override
  List<Object?> get props => [date, requests, cost];
}

class TopContributor extends Equatable {
  const TopContributor({
    required this.userId,
    required this.userName,
    required this.avatarUrl,
    required this.contribution,
    required this.coursesCompleted,
  });

  final String userId;
  final String userName;
  final String avatarUrl;
  final double contribution;
  final int coursesCompleted;

  @override
  List<Object?> get props => [
        userId,
        userName,
        avatarUrl,
        contribution,
        coursesCompleted,
      ];
}

/// ROI comparison data
class ROIComparison extends Equatable {
  const ROIComparison({
    required this.centers,
    required this.averageROI,
    required this.highestROI,
    required this.lowestROI,
  });

  final List<CenterROI> centers;
  final double averageROI;
  final double highestROI;
  final double lowestROI;

  @override
  List<Object?> get props => [centers, averageROI, highestROI, lowestROI];
}

class CenterROI extends Equatable {
  const CenterROI({
    required this.centerId,
    required this.centerName,
    required this.investment,
    required this.revenue,
    required this.roi,
    required this.category,
  });

  final String centerId;
  final String centerName;
  final double investment;
  final double revenue;
  final double roi;
  final ROICategory category;

  @override
  List<Object?> get props => [
        centerId,
        centerName,
        investment,
        revenue,
        roi,
        category,
      ];
}

enum ROICategory {
  high,
  medium,
  low,
}

/// Marketing tracking data
class MarketingData extends Equatable {
  const MarketingData({
    required this.totalSpend,
    required this.cac,
    required this.conversionRate,
    required this.totalAcquisitions,
    required this.channels,
    required this.centerSpends,
  });

  final double totalSpend;
  final double cac;
  final double conversionRate;
  final int totalAcquisitions;
  final List<ChannelPerformance> channels;
  final List<CenterMarketingSpend> centerSpends;

  @override
  List<Object?> get props => [
        totalSpend,
        cac,
        conversionRate,
        totalAcquisitions,
        channels,
        centerSpends,
      ];
}

class ChannelPerformance extends Equatable {
  const ChannelPerformance({
    required this.channel,
    required this.spend,
    required this.acquisitions,
    required this.cac,
    required this.conversionRate,
  });

  final String channel;
  final double spend;
  final int acquisitions;
  final double cac;
  final double conversionRate;

  @override
  List<Object?> get props => [channel, spend, acquisitions, cac, conversionRate];
}

class CenterMarketingSpend extends Equatable {
  const CenterMarketingSpend({
    required this.centerId,
    required this.centerName,
    required this.spend,
    required this.acquisitions,
    required this.cac,
  });

  final String centerId;
  final String centerName;
  final double spend;
  final int acquisitions;
  final double cac;

  @override
  List<Object?> get props => [centerId, centerName, spend, acquisitions, cac];
}

/// Auto-generated insights
class BusinessInsight extends Equatable {
  const BusinessInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.centerId,
    required this.centerName,
    required this.createdAt,
    required this.metadata,
  });

  final String id;
  final String title;
  final String description;
  final InsightType type;
  final InsightSeverity severity;
  final String? centerId;
  final String? centerName;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        severity,
        centerId,
        centerName,
        createdAt,
        metadata,
      ];
}

enum InsightType {
  revenue,
  investment,
  roi,
  aiPerformance,
  growth,
  risk,
}

enum InsightSeverity {
  positive,
  neutral,
  warning,
  critical,
}

/// Alert for dashboard
class DashboardAlert extends Equatable {
  const DashboardAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.centerId,
  });

  final String id;
  final String title;
  final String message;
  final AlertType type;
  final DateTime timestamp;
  final String? centerId;

  @override
  List<Object?> get props => [id, title, message, type, timestamp, centerId];
}

enum AlertType {
  loss,
  inefficiency,
  opportunity,
  milestone,
}
