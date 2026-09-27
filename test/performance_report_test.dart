import 'package:flutter_test/flutter_test.dart';

import '../test_driver/performance_report.dart';

void main() {
  test('builds a readable passing profile report', () {
    final report = buildPerformanceMarkdown(<String, dynamic>{
      'startup': <String, dynamic>{
        'duration_millis': 2400,
        'limit_millis': 5000,
        'mode': 'profile',
        'strict': true,
      },
      'auth_register_form': <String, dynamic>{
        'frame_count': 32,
        'average_frame_build_time_millis': 4.2,
        '90th_percentile_frame_build_time_millis': 7.5,
        'missed_frame_build_budget_count': 1,
        'average_frame_rasterizer_time_millis': 2.1,
        '90th_percentile_frame_rasterizer_time_millis': 3.5,
        'missed_frame_rasterizer_budget_count': 0,
      },
    }, generatedAt: DateTime.utc(2026, 9, 27));

    expect(report, contains('# Mobile Performance Report'));
    expect(report, contains('- Result: **PASS**'));
    expect(report, contains('| register form | 32 |'));
    expect(report, contains('2026-09-27T00:00:00.000Z'));
  });
}
