import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

import 'performance_report.dart';

Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    await writeResponseData(data, testOutputFilename: 'performance_report');

    final output = File('$testOutputsDirectory/performance_report.md');
    await output.parent.create(recursive: true);
    await output.writeAsString(buildPerformanceMarkdown(data));
    stdout.writeln('Performance report: ${output.absolute.path}');
  },
  writeResponseOnFailure: true,
);
