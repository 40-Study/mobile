import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:study/config/build_type.dart';
import 'package:talker_bloc_logger/talker_bloc_logger_observer.dart';

/// Environment config by build type.
class Environment<T> implements Listenable {
  Environment._(this._currentBuildType, T config)
      : _config = ValueNotifier<T>(config),
        _listeners = [];

  factory Environment.instance() => _instance as Environment<T>;

  static Environment<dynamic>? _instance;

  final BuildType _currentBuildType;
  final List<VoidCallback> _listeners;

  T get config => _config.value;

  set config(T c) {
    _config.value = c;
    _notifyListeners();
  }

  bool get isDebug => _currentBuildType == BuildType.debug;
  bool get isRelease => _currentBuildType == BuildType.release;
  BuildType get buildType => _currentBuildType;

  ValueNotifier<T> _config;

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Call once at app startup.
  static void init<T>({
    required BuildType buildType,
    required T config,
  }) {
    _instance ??= Environment<T>._(buildType, config);
    Bloc.observer = TalkerBlocObserver();
  }
}
