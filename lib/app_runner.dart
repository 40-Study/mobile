import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:study/app/app.dart';
import 'package:study/di/di_container.dart';
import 'package:study/di/di_initializer.dart';

Future<void> run([
  List<DeviceOrientation> orientations = const [
    DeviceOrientation.portraitUp,
  ],
]) async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(orientations);

  await initDI(diContainer, 'dev');

  _runApp();
}

void _runApp() {
  runApp(const App());
}
