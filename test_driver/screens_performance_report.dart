// Shared by the on-device gate and the host report so missing or invalid
// captures cannot be shown as a passing measurement.
List<String> screenCaptureIssues(
  Map<String, dynamic> result, {
  required bool strict,
}) {
  final issues = <String>[];
  final errors = result['errors'];
  if (errors is List) issues.addAll(errors.map((e) => 'UI: $e'));
  for (final phase in [
    'entry',
    if (result['scroll_exercised'] == true) 'scroll',
  ]) {
    final raw = result[phase];
    if (raw is! Map) {
      issues.add('$phase: missing capture');
      continue;
    }
    final metrics = Map<String, dynamic>.from(raw);
    final frames = metrics['frame_count'];
    if (frames is! int || frames < 15)
      issues.add('$phase: fewer than 15 frames');
    for (final metric in [
      '90th_percentile_frame_build_time_millis',
      '90th_percentile_frame_rasterizer_time_millis',
      'worst_frame_build_time_millis',
      'worst_frame_rasterizer_time_millis',
      'missed_frame_build_budget_count',
      'missed_frame_rasterizer_budget_count',
    ]) {
      final value = metrics[metric];
      if (value is! num || !value.isFinite || value < 0) {
        issues.add('$phase: missing/invalid $metric');
      }
    }
    if (!strict || frames is! int || frames <= 0) continue;
    for (final component in ['build', 'rasterizer']) {
      final p90 = metrics['90th_percentile_frame_${component}_time_millis'];
      final misses = metrics['missed_frame_${component}_budget_count'];
      if (p90 is num && p90 > 16) issues.add('$phase: $component P90 > 16 ms');
      if (misses is num && misses / frames > 0.05) {
        issues.add('$phase: $component misses > 5%');
      }
    }
  }
  return issues;
}

String buildScreensPerformanceMarkdown(
  Map<String, dynamic>? data, {
  DateTime? generatedAt,
}) {
  final meta = data?['screen_suite'] is Map
      ? data!['screen_suite'] as Map
      : <String, dynamic>{};
  final rawCases = data?['screen_cases'] is Map
      ? data!['screen_cases'] as Map
      : <String, dynamic>{};
  final expected = (meta['expected_cases'] as List? ?? []).cast<String>();
  final strict = meta['strict'] == true;
  final captures = {
    for (final entry in rawCases.entries)
      entry.key.toString(): Map<String, dynamic>.from(entry.value as Map),
  };
  final missing = expected.where((key) => !captures.containsKey(key)).toList();
  final failed = captures.entries
      .where((e) => screenCaptureIssues(e.value, strict: strict).isNotEmpty)
      .toList();
  final overBudget = captures.entries
      .where(
        (e) =>
            screenCaptureIssues(e.value, strict: false).isEmpty &&
            screenCaptureIssues(e.value, strict: true).isNotEmpty,
      )
      .toList();
  final complete =
      expected.isNotEmpty &&
      missing.isEmpty &&
      captures.length == expected.length;
  final passed = complete && failed.isEmpty;
  final ordered = captures.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  final ranked = captures.entries.toList()
    ..sort((a, b) => _worst(b.value).compareTo(_worst(a.value)));
  final buffer = StringBuffer()
    ..writeln('# All Mobile Screens Performance Report')
    ..writeln()
    ..writeln(
      '- Generated: `${(generatedAt ?? DateTime.now()).toUtc().toIso8601String()}`',
    )
    ..writeln(
      '- Device: `${meta['device'] ?? 'unknown'}`; platform: `${meta['platform'] ?? 'unknown'}`; logical size: `${meta['logical_size'] ?? 'unknown'}`',
    )
    ..writeln(
      '- Mode: `${meta['mode'] ?? 'unknown'}`; result: **${passed ? (strict ? 'PASS' : 'CAPTURED (debug smoke)') : 'FAIL'}**',
    )
    ..writeln(
      '- Screen inventory: ${meta['screen_count'] ?? 0}; captured cases: ${captures.length}/${expected.length}; failures: ${failed.length}; missing: ${missing.length}',
    )
    ..writeln(
      '- Cases exceeding the 60 Hz budgets${strict ? '' : ' (informational in debug)'}: ${overBudget.length + (strict ? failed.length : 0)}',
    )
    ..writeln()
    ..writeln('## Scope')
    ..writeln()
    ..writeln(
      'Real Flutter FrameTiming measurements while opening each fixture through an animated route and scrolling visible surfaces in both directions. Sparse = 1 item; large = 100 items per injected list. Family size is capped at 5 children, profiles at 3 and trend charts at 12 points. Fixed forms/demo screens are measured once. Font, app theme and native Rive animations are enabled.',
    )
    ..writeln()
    ..writeln(
      'Data comes from in-memory repositories; providers mount before the route measurement. These cases measure UI work rather than backend latency, full app cold startup, video playback, OAuth, image picking or large network image decoding. The device viewport, light theme, Vietnamese locale and default text size are used.',
    )
    ..writeln()
    ..writeln(
      strict
          ? 'The profile/release gate requires at least 15 samples per measured phase, P90 build and raster <= 16 ms, and missed build/raster budgets <= 5% for each phase.'
          : '**Debug simulator results identify suspect screens; they do not establish production performance.** Run `make performance_screens DEVICE=<physical-id> PROFILE=1` for strict measurements.',
    )
    ..writeln()
    ..writeln('## Highest observed build/raster spikes')
    ..writeln()
    ..writeln('| Screen / data | Worst frame |')
    ..writeln('| --- | ---: |');
  for (final e in ranked.take(10)) {
    buffer.writeln('| ${e.key} | ${_ms(_worst(e.value))} |');
  }
  buffer
    ..writeln()
    ..writeln('## All screen measurements')
    ..writeln()
    ..writeln(
      '| Screen | Data | Entry P90 build/raster | Scroll P90 build/raster | Worst build/raster | Misses build/raster | Frames entry/scroll | Status |',
    )
    ..writeln('| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |');
  for (final e in ordered) {
    final c = e.value;
    final entry = c['entry'] is Map ? c['entry'] as Map : <String, dynamic>{};
    final scroll = c['scroll'] is Map
        ? c['scroll'] as Map
        : <String, dynamic>{};
    final phases = [entry, if (c['scroll_exercised'] == true) scroll];
    final issues = screenCaptureIssues(c, strict: strict);
    final budgets = screenCaptureIssues(c, strict: true);
    final status = issues.isNotEmpty
        ? 'FAIL'
        : !strict && budgets.isNotEmpty
        ? 'REVIEW (debug)'
        : strict
        ? 'PASS'
        : 'CAPTURED';
    buffer.writeln(
      '| ${c['screen']} | ${c['density']} | ${_p90(entry)} | ${c['scroll_exercised'] == true ? _p90(scroll) : 'n/a'} '
      '| ${_ms(_maxMetric(phases, 'worst_frame_build_time_millis'))} / ${_ms(_maxMetric(phases, 'worst_frame_rasterizer_time_millis'))} '
      '| ${_sum(phases, 'missed_frame_build_budget_count')} / ${_sum(phases, 'missed_frame_rasterizer_budget_count')} '
      '| ${entry['frame_count'] ?? 0} / ${scroll['frame_count'] ?? 'n/a'} | $status |',
    );
  }
  final findings = captures.entries.where(
    (e) => screenCaptureIssues(e.value, strict: true).isNotEmpty,
  );
  if (missing.isNotEmpty || findings.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('## Findings')
      ..writeln();
    for (final key in missing) {
      buffer.writeln('- $key: missing case');
    }
    for (final e in findings) {
      buffer.writeln(
        '- ${e.key}: ${screenCaptureIssues(e.value, strict: true).map((s) => s.replaceAll('\n', ' ')).join('; ')}',
      );
    }
  }
  return buffer.toString();
}

String _p90(Map<dynamic, dynamic> metrics) =>
    '${_ms(metrics['90th_percentile_frame_build_time_millis'])} / ${_ms(metrics['90th_percentile_frame_rasterizer_time_millis'])}';
String _ms(Object? v) => v is num ? '${v.toStringAsFixed(2)} ms' : 'n/a';
num _worst(Map<String, dynamic> c) {
  final phases = [
    if (c['entry'] is Map) c['entry'] as Map,
    if (c['scroll'] is Map) c['scroll'] as Map,
  ];
  final build = _maxMetric(phases, 'worst_frame_build_time_millis');
  final raster = _maxMetric(phases, 'worst_frame_rasterizer_time_millis');
  return build > raster ? build : raster;
}

num _maxMetric(List<Map<dynamic, dynamic>> phases, String key) =>
    phases.fold<num>(
      0,
      (max, m) => m[key] is num && (m[key] as num) > max ? m[key] as num : max,
    );
num _sum(List<Map<dynamic, dynamic>> phases, String key) =>
    phases.fold<num>(0, (sum, m) => sum + (m[key] is num ? m[key] as num : 0));
