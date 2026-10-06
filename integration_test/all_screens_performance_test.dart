import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:study/features/student/presentation/search/search_screen.dart';

import '../test/support/screen_fixtures.dart';
import '../test_driver/screens_performance_report.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final cases = <({Widget screen, String density, int count})>[];
  const filter = String.fromEnvironment('PERFORMANCE_SCREEN');
  for (final count in [0, 1, 100]) {
    for (final screen in createScreenFixtures(itemCount: count)) {
      final name = screen.runtimeType.toString();
      if (filter.isNotEmpty && name != filter) continue;
      if (count > 0 && !variableDataScreens.contains(name)) continue;
      cases.add((
        screen: screen,
        density: variableDataScreens.contains(name)
            ? {0: 'empty', 1: 'sparse', 100: 'large'}[count]!
            : 'fixed',
        count: count,
      ));
    }
  }
  final expectedKeys = [
    for (final c in cases) '${c.screen.runtimeType}/${c.density}',
  ];
  binding.reportData = {
    'screen_suite': {
      'mode': kDebugMode
          ? 'debug'
          : kProfileMode
          ? 'profile'
          : 'release',
      'strict': !kDebugMode,
      'platform': Platform.operatingSystem,
      'device': const String.fromEnvironment(
        'PERFORMANCE_DEVICE',
        defaultValue: 'unspecified',
      ),
      'expected_cases': expectedKeys,
      'screen_count': cases
          .map((c) => c.screen.runtimeType.toString())
          .toSet()
          .length,
      'data_source': 'in-memory repositories; no backend/network latency',
      'animations_enabled': true,
    },
    'screen_cases': <String, dynamic>{},
  };
  setUpAll(() async {
    final font = FontLoader('Roboto')
      ..addFont(rootBundle.load('google_fonts/Roboto-Medium.ttf'));
    await font.load();
  });
  tearDown(() async => GetIt.instance.reset());

  for (final c in cases) {
    final key = '${c.screen.runtimeType}/${c.density}';
    testWidgets('performance $key', (tester) async {
      await setUpScreenFixtures(itemCount: c.count);
      final errors = <String>[];
      final result = <String, dynamic>{
        'screen': c.screen.runtimeType.toString(),
        'density': c.density,
        'items': c.count,
        'errors': errors,
        'scroll_exercised': false,
      };
      (binding.reportData!['screen_cases'] as Map)[key] = result;
      binding.reportData!['screen_suite']['logical_size'] =
          (tester.view.physicalSize / tester.view.devicePixelRatio).toString();
      try {
        // Providers mount first; only the actual screen route transition is measured.
        await pumpScreenFixture(
          tester,
          c.screen,
          size: null,
          disableAnimations: false,
          deferScreen: true,
          pumpCount: 1,
          pumpDuration: const Duration(milliseconds: 16),
        );
        final navigator = tester.state<NavigatorState>(
          find.byType(Navigator).first,
        );
        await binding.watchPerformance(
          () => mockNetworkImagesFor(() async {
            unawaited(navigator.pushNamed('/fixture'));
            await _frames(tester, errors, 40);
            expect(find.byType(c.screen.runtimeType), findsWidgets);
            expect(find.byType(Scaffold), findsWidgets);
          }),
          reportKey: 'entry_$key',
        );
        result['entry'] = binding.reportData!['entry_$key'];
        _takeErrors(tester, errors);

        if (c.screen is SearchScreen && c.count > 0) {
          await tester.enterText(find.byType(TextField).first, 'Toán');
          await _frames(tester, errors, 20);
          FocusManager.instance.primaryFocus?.unfocus();
          await _frames(tester, errors, 20);
        }
        final scrollables = tester
            .stateList<ScrollableState>(find.byType(Scrollable))
            .where(
              (s) =>
                  s.position.hasContentDimensions &&
                  s.position.maxScrollExtent > 0 &&
                  find.byWidget(s.widget).hitTestable().evaluate().isNotEmpty,
            )
            .toList();
        if (scrollables.isNotEmpty) {
          result['scroll_exercised'] = true;
          await binding.watchPerformance(
            () => mockNetworkImagesFor(() async {
              // Exercise each visible scrolling surface, including horizontal pages.
              for (final scrollable in scrollables) {
                if (!scrollable.mounted) continue;
                final position = scrollable.position;
                final horizontal =
                    axisDirectionToAxis(position.axisDirection) ==
                    Axis.horizontal;
                final distance = position.viewportDimension * 0.7;
                final finder = find.byWidget(scrollable.widget);
                if (finder.hitTestable().evaluate().isEmpty) continue;
                await tester.timedDrag(
                  finder,
                  horizontal ? Offset(-distance, 0) : Offset(0, -distance),
                  const Duration(milliseconds: 500),
                  frequency: 60,
                );
                await _frames(tester, errors, 20);
                if (!scrollable.mounted) continue;
                final returnFinder = find.byWidget(scrollable.widget);
                if (returnFinder.hitTestable().evaluate().isEmpty) continue;
                await tester.timedDrag(
                  returnFinder,
                  horizontal ? Offset(distance, 0) : Offset(0, distance),
                  const Duration(milliseconds: 500),
                  frequency: 60,
                );
                await _frames(tester, errors, 20);
              }
            }),
            reportKey: 'scroll_$key',
          );
          result['scroll'] = binding.reportData!['scroll_$key'];
        }
      } catch (error) {
        errors.add(error.toString());
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        _takeErrors(tester, errors);
      }
      final issues = screenCaptureIssues(result, strict: !kDebugMode);
      tester.printToConsole(
        '[screen performance] $key: ${issues.isEmpty ? 'captured' : issues.join('; ')}',
      );
      expect(issues, isEmpty, reason: key);
    }, timeout: const Timeout(Duration(minutes: 3)));
  }
}

Future<void> _frames(
  WidgetTester tester,
  List<String> errors,
  int count,
) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16));
    _takeErrors(tester, errors);
  }
}

void _takeErrors(WidgetTester tester, List<String> errors) {
  Object? error;
  while ((error = tester.takeException()) != null) {
    final message = error.toString();
    if (!errors.contains(message)) errors.add(message);
  }
}
