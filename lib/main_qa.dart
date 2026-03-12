import 'package:study/app_runner.dart';
import 'package:study/config/app_config.dart';
import 'package:study/config/build_type.dart';
import 'package:study/config/environment.dart';

void main(List<String> args) {
  Environment.init(
    buildType: BuildType.qa,
    config: AppConfig(
      url: '',
    ),
  );
  run();
}
