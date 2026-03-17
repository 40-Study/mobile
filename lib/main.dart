import 'package:study/app_runner.dart';
import 'package:study/config/app_config.dart';
import 'package:study/config/build_type.dart';
import 'package:study/config/environment.dart';

void main(List<String> args) {
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');

  final (buildType, envFile) = switch (env) {
    'prod' => (BuildType.release, '.env.prod'),
    'qa' => (BuildType.qa, '.env.qa'),
    _ => (BuildType.debug, '.env.dev'),
  };

  Environment.init(
    buildType: buildType,
    config: AppConfig(envFileName: envFile),
  );
  run();
}
