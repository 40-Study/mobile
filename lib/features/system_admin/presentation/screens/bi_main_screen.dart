import 'package:flutter/material.dart';
import 'package:study/widgets/simple_gradient_background.dart';
import '../widgets/widgets.dart';
import 'bi_dashboard_screen.dart';
import 'bi_centers_screen.dart';
import 'bi_analytics_screen.dart';
import 'bi_ai_performance_screen.dart';
import 'bi_insights_screen.dart';
import 'bi_settings_screen.dart';

/// Màn hình chính cho System Admin BI Dashboard
/// Kết hợp tất cả các màn hình với bottom navigation
class BIMainScreen extends StatefulWidget {
  const BIMainScreen({super.key});

  @override
  State<BIMainScreen> createState() => _BIMainScreenState();
}

class _BIMainScreenState extends State<BIMainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    BIDashboardScreen(),
    BICentersScreen(),
    BIAnalyticsScreen(),
    BIAIPerformanceScreen(),
    BIInsightsScreen(),
    BISettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SimpleGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.95),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BIBottomNavigation(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        ),
      ),
    );
  }
}
