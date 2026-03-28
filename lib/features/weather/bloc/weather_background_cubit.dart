import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:study/features/weather/bloc/weather_display_data.dart';
import 'package:study/features/weather/bloc/weather_mapper.dart';
import 'package:study/features/weather/data/models/models.dart';
import 'package:study/features/weather/data/repository/weather_repository.dart';
import 'package:study/features/weather/data/weather_storage.dart';

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
