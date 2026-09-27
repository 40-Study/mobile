import 'package:study/app_runner.dart';
import 'package:study/config/app_config.dart';
import 'package:study/config/build_type.dart';
import 'package:study/config/environment.dart';

Future<void> main(List<String> args) async {
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
  await run();
}
