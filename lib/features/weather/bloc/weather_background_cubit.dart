import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:study/features/weather/bloc/weather_display_data.dart';
import 'package:study/features/weather/bloc/weather_mapper.dart';
import 'package:study/features/weather/data/models/models.dart';
import 'package:study/features/weather/data/repository/weather_repository.dart';
import 'package:study/features/weather/data/weather_storage.dart';
import 'package:study/features/weather/presentation/utils/weather_gradients.dart';

part 'weather_background_state.dart';

class WeatherBackgroundCubit extends Cubit<WeatherBackgroundState> {
  WeatherBackgroundCubit({
    required WeatherRepository repository,
    required WeatherStorage storage,
    WeatherMapper? mapper,
  })  : _repository = repository,
        _storage = storage,
        _mapper = mapper ?? const WeatherMapper(),
        super(const WeatherBackgroundInitial());

  final WeatherRepository _repository;
  final WeatherStorage _storage;
  final WeatherMapper _mapper;

  /// Debug overrides (null = use real/default values)
  TimeOfDayType? _debugTimeOverride;
  WeatherCondition? _debugConditionOverride;

  TimeOfDayType? get debugTimeOverride => _debugTimeOverride;
  WeatherCondition? get debugConditionOverride => _debugConditionOverride;

  /// Set debug time override
  void setDebugTime(TimeOfDayType? time) {
    _debugTimeOverride = time;
    _reemitWithDebugOverrides();
  }

  /// Set debug condition override
  void setDebugCondition(WeatherCondition? condition) {
    _debugConditionOverride = condition;
    _reemitWithDebugOverrides();
  }

  /// Cycle through time of day for testing
  void cycleDebugTime() {
    final times = TimeOfDayType.values;
    if (_debugTimeOverride == null) {
      _debugTimeOverride = times.first;
    } else {
      final currentIndex = times.indexOf(_debugTimeOverride!);
      final nextIndex = (currentIndex + 1) % times.length;
      _debugTimeOverride = times[nextIndex];
    }
    _reemitWithDebugOverrides();
  }

  /// Cycle through weather conditions for testing
  void cycleDebugCondition() {
    // Only cycle through main conditions (exclude defaultNeutral)
    const conditions = [
      WeatherCondition.sunny,
      WeatherCondition.cloudy,
      WeatherCondition.rainy,
      WeatherCondition.snowy,
    ];
    if (_debugConditionOverride == null) {
      _debugConditionOverride = conditions.first;
    } else {
      final currentIndex = conditions.indexOf(_debugConditionOverride!);
      final nextIndex = (currentIndex + 1) % conditions.length;
      _debugConditionOverride = conditions[nextIndex];
    }
    _reemitWithDebugOverrides();
  }

  void _reemitWithDebugOverrides() {
    final current = state;
    if (current is WeatherBackgroundLoaded) {
      emit(WeatherBackgroundLoaded(
        debugTimeOverride: _debugTimeOverride,
        debugConditionOverride: _debugConditionOverride,
        displayData: current.displayData,
        isFromCache: current.isFromCache,
      ));
    } else if (current is WeatherBackgroundFailure) {
      emit(WeatherBackgroundFailure(
        debugTimeOverride: _debugTimeOverride,
        debugConditionOverride: _debugConditionOverride,
        message: current.message,
        fallbackData: current.fallbackData,
      ));
    } else {
      emit(WeatherBackgroundInitial(
        debugTimeOverride: _debugTimeOverride,
        debugConditionOverride: _debugConditionOverride,
      ));
    }
  }

  /// Load weather on app start (uses cache first)
  Future<void> load() async {
    final previousData = _currentDisplayData;

    emit(WeatherBackgroundLoading(
      previousCondition: previousData?.condition,
      previousTimeOfDay: previousData?.timeOfDay,
    ));

    try {
      final result = await _repository.getWeather();
      final displayData = _mapper.toDisplayData(result.weather);

      emit(WeatherBackgroundLoaded(
        displayData: displayData,
        isFromCache: result.isFromCache,
      ));
    } catch (e) {
      emit(WeatherBackgroundFailure(
        message: e.toString(),
        fallbackData: previousData ?? WeatherDisplayData.defaultData(),
      ));
    }
  }

  /// Force refresh (skip cache)
  Future<void> refresh() async {
    final previousData = _currentDisplayData;

    emit(WeatherBackgroundLoading(
      previousCondition: previousData?.condition,
      previousTimeOfDay: previousData?.timeOfDay,
    ));

    try {
      final result = await _repository.getWeather(forceRefresh: true);
      final displayData = _mapper.toDisplayData(result.weather);

      emit(WeatherBackgroundLoaded(
        displayData: displayData,
        isFromCache: false,
      ));
    } catch (e) {
      emit(WeatherBackgroundFailure(
        message: e.toString(),
        fallbackData: previousData ?? WeatherDisplayData.defaultData(),
      ));
    }
  }

  WeatherDisplayData? get _currentDisplayData {
    final s = state;
    if (s is WeatherBackgroundLoaded) return s.displayData;
    if (s is WeatherBackgroundFailure) return s.fallbackData;
    return null;
  }

  /// Get currently selected city (null = using GPS)
  CityModel? get selectedCity => _storage.getSelectedCity();

  /// Select a city manually
  Future<void> selectCity(CityModel city) async {
    await _storage.saveSelectedCity(city);
    await refresh();
  }

  /// Clear selected city and use GPS
  Future<void> useGPS() async {
    await _storage.clearSelectedCity();
    await _storage.clearLocation();
    await refresh();
  }
}
