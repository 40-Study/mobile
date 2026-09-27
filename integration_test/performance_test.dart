import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:study/features/auth/presentation/forgot_password_screen.dart';
import 'package:study/features/auth/presentation/register_form_screen.dart';
import 'package:study/features/onboarding/onboarding_screen.dart';
import 'package:study/main.dart' as app;
import 'package:study/routes/router.dart';

const _startupTimeout = Duration(seconds: 15);
const _pumpStep = Duration(milliseconds: 50);
const _transitionDuration = Duration(milliseconds: 500);
const _frameInterval = Duration(milliseconds: 16);
const _minimumTransitionFrames = 15;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'startup and auth route performance',
    (tester) async {
      final startup = Stopwatch()..start();

      await app.main(const []);
      await _pumpUntilFound(
        tester,
        find.byType(OnboardingScreen),
        timeout: _startupTimeout,
        description: 'OnboardingScreen after app startup',
      );

      startup.stop();
      final startupLimit = kDebugMode
          ? const Duration(seconds: 15)
          : const Duration(seconds: 5);
      final mode = kDebugMode
          ? 'debug'
          : kProfileMode
          ? 'profile'
          : 'release';
      expect(
        startup.elapsed,
        lessThan(startupLimit),
        reason: 'Startup exceeded $startupLimit',
      );
      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['startup'] = <String, dynamic>{
        'duration_millis': startup.elapsedMilliseconds,
        'limit_millis': startupLimit.inMilliseconds,
        'mode': mode,
        'strict': !kDebugMode,
      };
      tester.printToConsole(
        '[performance] startup=${startup.elapsedMilliseconds}ms '
        'mode=$mode',
      );

      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );

      final routes = <_MeasuredRoute>[
        const _MeasuredRoute(
          name: 'register_form',
          route: Routes.registerForm,
          ready: RegisterFormScreen,
        ),
        const _MeasuredRoute(
          name: 'forgot_password',
          route: Routes.forgotPassword,
          ready: ForgotPasswordScreen,
        ),
      ];

      for (final route in routes) {
        final reportKey = 'auth_${route.name}';

        await binding.watchPerformance(() async {
          unawaited(navigator.pushNamed(route.route));
          await _pumpFrames(tester, _transitionDuration);
          expect(
            find.byType(route.ready),
            findsOneWidget,
            reason: '${route.ready} was not shown for ${route.route}',
          );
        }, reportKey: reportKey);

        final summary = _readPerformanceSummary(binding, reportKey);
        _expectValidFrameSummary(summary, reportKey);
        tester.printToConsole('[performance] $reportKey=$summary');

        navigator.pop();
        await _pumpFrames(tester, _transitionDuration);
        expect(find.byType(OnboardingScreen), findsOneWidget);
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

Future<void> _pumpFrames(WidgetTester tester, Duration duration) async {
  final frames = (duration.inMicroseconds / _frameInterval.inMicroseconds)
      .ceil();
  for (var index = 0; index < frames; index++) {
    await tester.pump(_frameInterval);
  }
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  required Duration timeout,
  required String description,
}) async {
  final stopwatch = Stopwatch()..start();

  while (finder.evaluate().isEmpty) {
    if (stopwatch.elapsed >= timeout) {
      throw TestFailure('Timed out waiting for $description after $timeout');
    }
    await tester.pump(_pumpStep);
  }
}

Map<String, dynamic> _readPerformanceSummary(
  IntegrationTestWidgetsFlutterBinding binding,
  String reportKey,
) {
  final raw = binding.reportData?[reportKey];
  if (raw is! Map) {
    throw TestFailure('Missing FrameTiming report for $reportKey');
  }
  return Map<String, dynamic>.from(raw);
}

void _expectValidFrameSummary(Map<String, dynamic> summary, String reportKey) {
  final frameCount = summary['frame_count'];
  expect(
    frameCount,
    isA<int>().having(
      (value) => value,
      'frame count',
      greaterThanOrEqualTo(_minimumTransitionFrames),
    ),
    reason: '$reportKey did not capture enough real FrameTiming samples',
  );

  if (kDebugMode) return;

  final frames = frameCount as int;
  final missedBuild = summary['missed_frame_build_budget_count'] as int;
  final missedRaster = summary['missed_frame_rasterizer_budget_count'] as int;
  final p90Build = summary['90th_percentile_frame_build_time_millis'] as num;
  final p90Raster =
      summary['90th_percentile_frame_rasterizer_time_millis'] as num;
  final allowedMisses = (frames * 0.05).ceil();

  expect(
    missedBuild,
    lessThanOrEqualTo(allowedMisses),
    reason: '$reportKey missed too many build-frame budgets',
  );
  expect(
    missedRaster,
    lessThanOrEqualTo(allowedMisses),
    reason: '$reportKey missed too many raster-frame budgets',
  );
  expect(
    p90Build,
    lessThanOrEqualTo(16),
    reason: '$reportKey p90 build time exceeded the 60 Hz frame budget',
  );
  expect(
    p90Raster,
    lessThanOrEqualTo(16),
    reason: '$reportKey p90 raster time exceeded the 60 Hz frame budget',
  );
}

class _MeasuredRoute {
  const _MeasuredRoute({
    required this.name,
    required this.route,
    required this.ready,
  });

  final String name;
  final String route;
  final Type ready;
}
