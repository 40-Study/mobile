import 'package:flutter_test/flutter_test.dart';

import '../test_driver/screens_performance_report.dart';

Map<String, dynamic> _metrics({int frames = 100, int misses = 5}) => {
  'frame_count': frames,
  '90th_percentile_frame_build_time_millis': 8.0,
  '90th_percentile_frame_rasterizer_time_millis': 4.0,
  'worst_frame_build_time_millis': 20.0,
  'worst_frame_rasterizer_time_millis': 6.0,
  'missed_frame_build_budget_count': misses,
  'missed_frame_rasterizer_budget_count': 0,
};

Map<String, dynamic> _case({int frames = 100, int misses = 5}) => {
  'screen': 'HomeScreen',
  'density': 'large',
  'errors': <String>[],
  'scroll_exercised': false,
  'entry': _metrics(frames: frames, misses: misses),
};

Map<String, dynamic> _data(Map<String, dynamic> c, {bool strict = true}) => {
  'screen_suite': {
    'mode': strict ? 'profile' : 'debug',
    'strict': strict,
    'expected_cases': ['HomeScreen/large'],
    'screen_count': 1,
  },
  'screen_cases': {'HomeScreen/large': c},
};

void main() {
  test(
    'strict gate accepts exactly 5 percent misses and rejects one above',
    () {
      expect(screenCaptureIssues(_case(), strict: true), isEmpty);
      expect(
        screenCaptureIssues(_case(misses: 6), strict: true),
        contains('entry: build misses > 5%'),
      );
      // Rounding up 5% of a small sample would silently allow 6.9% misses.
      expect(
        screenCaptureIssues(_case(frames: 29, misses: 2), strict: true),
        isNotEmpty,
      );
    },
  );

  test(
    'requires complete finite timings and a capture for exercised scrolling',
    () {
      final c = _case()..['scroll_exercised'] = true;
      expect(
        screenCaptureIssues(c, strict: false),
        contains('scroll: missing capture'),
      );
      c['entry']['90th_percentile_frame_build_time_millis'] = double.nan;
      expect(
        screenCaptureIssues(c, strict: false),
        contains(
          'entry: missing/invalid 90th_percentile_frame_build_time_millis',
        ),
      );
    },
  );

  test('flags too few frames and UI exceptions even in debug', () {
    final c = _case(frames: 14)..['errors'] = ['RenderFlex overflow'];
    expect(
      screenCaptureIssues(c, strict: false),
      containsAll(['entry: fewer than 15 frames', 'UI: RenderFlex overflow']),
    );
  });

  test('report fails when a screen in the inventory was never measured', () {
    final data = _data(_case());
    data['screen_suite']['expected_cases'] = [
      'HomeScreen/large',
      'LearningScreen/empty',
    ];
    final report = buildScreensPerformanceMarkdown(data);
    expect(report, contains('result: **FAIL**'));
    expect(report, contains('LearningScreen/empty: missing case'));
  });

  test(
    'debug reports budget overruns as review rather than a production pass',
    () {
      final report = buildScreensPerformanceMarkdown(
        _data(_case(misses: 6), strict: false),
      );
      expect(report, contains('CAPTURED (debug smoke)'));
      expect(report, contains('REVIEW (debug)'));
      expect(report, contains('do not establish production performance'));
    },
  );

  test(
    'profile report preserves entry and scrolling metrics and fails either phase',
    () {
      final c = _case()
        ..['scroll_exercised'] = true
        ..['scroll'] = _metrics(misses: 6);
      final report = buildScreensPerformanceMarkdown(_data(c));
      expect(report, contains('result: **FAIL**'));
      expect(report, contains('scroll: build misses > 5%'));
      expect(report, contains('| 100 / 100 | FAIL |'));
    },
  );
}
