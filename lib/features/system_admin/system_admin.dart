/// System Admin Business Intelligence Dashboard
///
/// This feature provides a comprehensive BI dashboard for platform owners,
/// investors, and business managers to track and analyze the financial
/// performance, investment efficiency, and AI usage across partner centers.
///
/// IMPORTANT: This is a read-only dashboard for decision-making.
/// The user does NOT manage or control the centers directly.
///
/// Main screens:
/// - Overview Dashboard: Key metrics, top/declining centers, alerts
/// - Partner Centers: List and compare all centers
/// - Center Insight: Detailed view of individual center performance
/// - Analytics: Charts and comparisons across time and centers
/// - AI Performance: Track AI costs, usage, and ROI
/// - Marketing: CAC, conversion rates, channel performance
/// - Insights: Auto-generated business insights and recommendations
library;

export 'data/models/bi_models.dart';
export 'bloc/dashboard/bi_dashboard_cubit.dart';
export 'bloc/dashboard/bi_dashboard_state.dart';
export 'bloc/centers/bi_centers_cubit.dart';
export 'bloc/centers/bi_centers_state.dart';
export 'presentation/screens/screens.dart';
export 'presentation/widgets/widgets.dart';
