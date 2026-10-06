import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

import 'performance_report.dart';
import 'screens_performance_report.dart';

Future<void> main() => integrationDriver(
  timeout: const Duration(minutes: 30),
  responseDataCallback: (data) async {
    final allScreens = data?.containsKey('screen_suite') == true;
    final filename = allScreens
        ? 'screens_performance_report'
        : 'performance_report';
    await writeResponseData(data, testOutputFilename: filename);

    final output = File('$testOutputsDirectory/$filename.md');
    await output.parent.create(recursive: true);
    await output.writeAsString(
      allScreens
          ? buildScreensPerformanceMarkdown(data)
          : buildPerformanceMarkdown(data),
    );
    stdout.writeln('Performance report: ${output.absolute.path}');
  },
  writeResponseOnFailure: true,
);
