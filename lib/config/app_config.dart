import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App config loaded from .env file.
class AppConfig {
  AppConfig({required this.envFileName});

  final String envFileName;

  String get url => dotenv.get('BASE_URL', fallback: '');
}
