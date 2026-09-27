String buildPerformanceMarkdown(
  Map<String, dynamic>? data, {
  DateTime? generatedAt,
}) {
  final generated = (generatedAt ?? DateTime.now()).toUtc().toIso8601String();
  final startup = _map(data?['startup']);
  final strict = startup?['strict'] == true;
  final mode = startup?['mode']?.toString() ?? 'unknown';
  final duration = _integer(startup?['duration_millis']);
  final limit = _integer(startup?['limit_millis']);
  final startupPassed = duration != null && limit != null && duration < limit;

  final routes =
      (data?.entries ?? const <MapEntry<String, dynamic>>[])
          .where((entry) => entry.key.startsWith('auth_'))
          .map((entry) => MapEntry(entry.key, _map(entry.value)))
          .where((entry) => entry.value != null)
          .toList()
        ..sort((a, b) => a.key.compareTo(b.key));

  final routeResults = routes.map((entry) {
    final metrics = entry.value!;
    final frames = _integer(metrics['frame_count']) ?? 0;
    final buildMisses =
        _integer(metrics['missed_frame_build_budget_count']) ?? frames;
    final rasterMisses =
        _integer(metrics['missed_frame_rasterizer_budget_count']) ?? frames;
    final p90Build = _number(
      metrics['90th_percentile_frame_build_time_millis'],
    );
    final p90Raster = _number(
      metrics['90th_percentile_frame_rasterizer_time_millis'],
    );
    final allowedMisses = (frames * 0.05).ceil();
    final passed =
        frames >= 15 &&
        (!strict ||
            (buildMisses <= allowedMisses &&
                rasterMisses <= allowedMisses &&
                p90Build != null &&
                p90Build <= 16 &&
                p90Raster != null &&
                p90Raster <= 16));

    return _RouteResult(
      name: entry.key.replaceFirst('auth_', '').replaceAll('_', ' '),
      frames: frames,
      averageBuild: _number(metrics['average_frame_build_time_millis']),
      p90Build: p90Build,
      buildMisses: buildMisses,
      averageRaster: _number(metrics['average_frame_rasterizer_time_millis']),
      p90Raster: p90Raster,
      rasterMisses: rasterMisses,
      passed: passed,
    );
  }).toList();

  final passed =
      startupPassed &&
      routeResults.isNotEmpty &&
      routeResults.every((result) => result.passed);
  final result = passed ? (strict ? 'PASS' : 'PASS (smoke)') : 'FAIL';
  final buffer = StringBuffer()
    ..writeln('# Mobile Performance Report')
    ..writeln()
    ..writeln('- Generated: `$generated`')
    ..writeln('- Mode: `$mode`')
    ..writeln('- Result: **$result**')
    ..writeln()
    ..writeln('## Startup')
    ..writeln()
    ..writeln('| Duration | Limit | Status |')
    ..writeln('| ---: | ---: | :---: |')
    ..writeln(
      '| ${_milliseconds(duration)} | ${_milliseconds(limit)} | '
      '${startupPassed ? 'PASS' : 'FAIL'} |',
    )
    ..writeln()
    ..writeln('## Route frame timings')
    ..writeln()
    ..writeln(
      '| Route | Frames | Avg build | P90 build | Build misses | '
      'Avg raster | P90 raster | Raster misses | Status |',
    )
    ..writeln(
      '| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | :---: |',
    );

  for (final route in routeResults) {
    buffer.writeln(
      '| ${route.name} | ${route.frames} '
      '| ${_milliseconds(route.averageBuild)} '
      '| ${_milliseconds(route.p90Build)} | ${route.buildMisses} '
      '| ${_milliseconds(route.averageRaster)} '
      '| ${_milliseconds(route.p90Raster)} | ${route.rasterMisses} '
      '| ${route.passed ? 'PASS' : 'FAIL'} |',
    );
  }

  buffer
    ..writeln()
    ..writeln('## Enforced thresholds')
    ..writeln()
    ..writeln('- Startup: `< ${limit ?? 0} ms`')
    ..writeln('- Captured frames per transition: `>= 15`')
    ..writeln('- P90 build/raster time in profile or release: `<= 16 ms`')
    ..writeln('- Missed build/raster budgets in profile or release: `<= 5%`');

  if (!strict) {
    buffer
      ..writeln()
      ..writeln(
        '> Debug is a smoke run. Use `make performance_test DEVICE=<id>` '
        'on a physical device to enforce frame-time budgets.',
      );
  }

  return buffer.toString();
}

Map<String, dynamic>? _map(Object? value) {
  if (value is! Map) return null;
  return Map<String, dynamic>.from(value);
}

int? _integer(Object? value) => value is num ? value.toInt() : null;

num? _number(Object? value) => value is num ? value : null;

String _milliseconds(num? value) =>
    value == null ? 'n/a' : '${value.toStringAsFixed(2)} ms';

class _RouteResult {
  const _RouteResult({
    required this.name,
    required this.frames,
    required this.averageBuild,
    required this.p90Build,
    required this.buildMisses,
    required this.averageRaster,
    required this.p90Raster,
    required this.rasterMisses,
    required this.passed,
  });

  final String name;
  final int frames;
  final num? averageBuild;
  final num? p90Build;
  final int buildMisses;
  final num? averageRaster;
  final num? p90Raster;
  final int rasterMisses;
  final bool passed;
}
