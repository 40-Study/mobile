import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/student_stats_model.dart';

import 'academic_level_roadmap.dart';

/// Legacy Wrapper cho [AcademicLevelRoadmap]
/// Giữ tương thích 100% với các vị trí gọi OverviewStatistics cũ
class OverviewStatistics extends StatelessWidget {
  const OverviewStatistics({
    super.key,
    required this.stats,
    this.earnedBadgesCount,
    this.totalBadgesCount,
    this.joinedDateText,
    this.enableAnimation = true,
  });

  final StudentStatsModel stats;
  final int? earnedBadgesCount;
  final int? totalBadgesCount;
  final String? joinedDateText;
  final bool enableAnimation;

  @override
  Widget build(BuildContext context) {
    return AcademicLevelRoadmap(
      stats: stats,
      earnedBadgesCount: earnedBadgesCount,
      totalBadgesCount: totalBadgesCount,
      enableAnimation: enableAnimation,
    );
  }
}
