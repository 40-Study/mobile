import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:talker/talker.dart';

@module
abstract class DIAppModule {
  @lazySingleton
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  @lazySingleton
  Talker provideLogger() => Talker();
}
