import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:study/config/environment.dart';

/// App config loaded from .env file.
class AppConfig {
  AppConfig({required this.envFileName});

  final String envFileName;

  String get url => dotenv.get('BASE_URL', fallback: '');

  bool get forceShowOnboarding {
    if (Environment<AppConfig>.instance().isRelease) {
      return false;
    }

    return dotenv
            .get('FORCE_SHOW_ONBOARDING', fallback: 'false')
            .toLowerCase() ==
        'true';
  }
}
