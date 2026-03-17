import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:study/app/app.dart';
import 'package:study/config/app_config.dart';
import 'package:study/config/environment.dart';
import 'package:study/di/di_container.dart';
import 'package:study/di/di_initializer.dart';

Future<void> run([
  List<DeviceOrientation> orientations = const [
    DeviceOrientation.portraitUp,
  ],
]) async {
  WidgetsFlutterBinding.ensureInitialized();

  final config =
      Environment<AppConfig>.instance().config;
  await dotenv.load(fileName: config.envFileName);

  await SystemChrome.setPreferredOrientations(orientations);

  await initDI(diContainer, 'dev');

  _runApp();
}

void _runApp() {
  runApp(const App());
}
