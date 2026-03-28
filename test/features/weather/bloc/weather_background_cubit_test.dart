import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/features/weather/weather.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  group('WeatherBackgroundCubit', () {
    late WeatherBackgroundCubit cubit;
    late MockWeatherRepository mockRepository;

    final mockWeather = WeatherModel(
      condition: 'Clear',
      temperature: 28.0,
      humidity: 60,
      sunriseTimestamp: DateTime(2024, 1, 1, 6, 0).millisecondsSinceEpoch ~/ 1000,
      sunsetTimestamp: DateTime(2024, 1, 1, 18, 0).millisecondsSinceEpoch ~/ 1000,
      cityName: 'Hanoi',
    );

    setUp(() {
      mockRepository = MockWeatherRepository();
      cubit = WeatherBackgroundCubit(repository: mockRepository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state should be WeatherBackgroundInitial', () {
      expect(cubit.state, isA<WeatherBackgroundInitial>());
    });

    group('load', () {
      blocTest<WeatherBackgroundCubit, WeatherBackgroundState>(
        'should emit [Loading, Loaded] when repository returns cached data',
        build: () {
          when(() => mockRepository.getWeather()).thenAnswer(
            (_) async => WeatherResult(weather: mockWeather, isFromCache: true),
          );
          return cubit;
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          isA<WeatherBackgroundLoading>(),
          isA<WeatherBackgroundLoaded>()
              .having((s) => s.isFromCache, 'isFromCache', true),
        ],
      );

      blocTest<WeatherBackgroundCubit, WeatherBackgroundState>(
        'should emit [Loading, Loaded] when repository returns fresh data',
        build: () {
          when(() => mockRepository.getWeather()).thenAnswer(
            (_) async =>
                WeatherResult(weather: mockWeather, isFromCache: false),
          );
          return cubit;
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          isA<WeatherBackgroundLoading>(),
          isA<WeatherBackgroundLoaded>()
              .having((s) => s.isFromCache, 'isFromCache', false),
        ],
      );

      blocTest<WeatherBackgroundCubit, WeatherBackgroundState>(
        'should emit [Loading, Failure] when repository throws',
        build: () {
          when(() => mockRepository.getWeather())
              .thenThrow(Exception('Network error'));
          return cubit;
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          isA<WeatherBackgroundLoading>(),
          isA<WeatherBackgroundFailure>()
              .having((s) => s.fallbackData, 'fallbackData', isNotNull),
        ],
      );
    });

    group('refresh', () {
      blocTest<WeatherBackgroundCubit, WeatherBackgroundState>(
        'should call repository with forceRefresh=true',
        build: () {
          when(() => mockRepository.getWeather(forceRefresh: true)).thenAnswer(
            (_) async =>
                WeatherResult(weather: mockWeather, isFromCache: false),
          );
          return cubit;
        },
        act: (cubit) => cubit.refresh(),
        verify: (_) {
          verify(() => mockRepository.getWeather(forceRefresh: true)).called(1);
        },
      );
    });
  });
}
