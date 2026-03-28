import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/weather/weather.dart';

void main() {
  group('WeatherMapper', () {
    const mapper = WeatherMapper();

    group('toDisplayData', () {
      test('should map Clear condition to sunny', () {
        final weather = WeatherModel(
          condition: 'Clear',
          temperature: 28.0,
          humidity: 60,
          sunriseTimestamp:
              DateTime(2024, 1, 1, 6, 0).millisecondsSinceEpoch ~/ 1000,
          sunsetTimestamp:
              DateTime(2024, 1, 1, 18, 0).millisecondsSinceEpoch ~/ 1000,
          cityName: 'Hanoi',
        );

        final result = mapper.toDisplayData(weather);

        expect(result.condition, WeatherCondition.sunny);
        expect(result.cityName, 'Hanoi');
        expect(result.temperature, 28.0);
      });

      test('should map Rain condition to rainy', () {
        final weather = WeatherModel(
          condition: 'Rain',
          temperature: 22.0,
          humidity: 80,
          sunriseTimestamp:
              DateTime(2024, 1, 1, 6, 0).millisecondsSinceEpoch ~/ 1000,
          sunsetTimestamp:
              DateTime(2024, 1, 1, 18, 0).millisecondsSinceEpoch ~/ 1000,
          cityName: 'HCMC',
        );

        final result = mapper.toDisplayData(weather);

        expect(result.condition, WeatherCondition.rainy);
      });

      test('should return null cityName when empty', () {
        final weather = WeatherModel(
          condition: 'Clear',
          temperature: 25.0,
          humidity: 50,
          sunriseTimestamp:
              DateTime(2024, 1, 1, 6, 0).millisecondsSinceEpoch ~/ 1000,
          sunsetTimestamp:
              DateTime(2024, 1, 1, 18, 0).millisecondsSinceEpoch ~/ 1000,
          cityName: '',
        );

        final result = mapper.toDisplayData(weather);

        expect(result.cityName, isNull);
      });
    });
  });

  group('WeatherCondition', () {
    test('should map all known conditions correctly', () {
      expect(
        WeatherCondition.fromApiCondition('Clear'),
        WeatherCondition.sunny,
      );
      expect(
        WeatherCondition.fromApiCondition('Rain'),
        WeatherCondition.rainy,
      );
      expect(
        WeatherCondition.fromApiCondition('Drizzle'),
        WeatherCondition.rainy,
      );
      expect(
        WeatherCondition.fromApiCondition('Snow'),
        WeatherCondition.snowy,
      );
      expect(
        WeatherCondition.fromApiCondition('Fog'),
        WeatherCondition.foggy,
      );
      expect(
        WeatherCondition.fromApiCondition('Mist'),
        WeatherCondition.foggy,
      );
      expect(
        WeatherCondition.fromApiCondition('Clouds'),
        WeatherCondition.cloudy,
      );
    });

    test('should return defaultNeutral for unknown conditions', () {
      expect(
        WeatherCondition.fromApiCondition('Unknown'),
        WeatherCondition.defaultNeutral,
      );
      expect(
        WeatherCondition.fromApiCondition(''),
        WeatherCondition.defaultNeutral,
      );
    });
  });

  group('TimeOfDayType', () {
    test('should return dawn around sunrise time', () {
      final sunrise = DateTime(2024, 1, 1, 6, 0);
      final sunset = DateTime(2024, 1, 1, 18, 0);
      final now = DateTime(2024, 1, 1, 6, 30); // 30 min after sunrise

      final result = TimeOfDayType.calculate(
        now: now,
        sunrise: sunrise,
        sunset: sunset,
      );

      expect(result, TimeOfDayType.dawn);
    });

    test('should return day during midday', () {
      final sunrise = DateTime(2024, 1, 1, 6, 0);
      final sunset = DateTime(2024, 1, 1, 18, 0);
      final now = DateTime(2024, 1, 1, 12, 0); // noon

      final result = TimeOfDayType.calculate(
        now: now,
        sunrise: sunrise,
        sunset: sunset,
      );

      expect(result, TimeOfDayType.day);
    });

    test('should return dusk around sunset time', () {
      final sunrise = DateTime(2024, 1, 1, 6, 0);
      final sunset = DateTime(2024, 1, 1, 18, 0);
      final now = DateTime(2024, 1, 1, 17, 30); // 30 min before sunset

      final result = TimeOfDayType.calculate(
        now: now,
        sunrise: sunrise,
        sunset: sunset,
      );

      expect(result, TimeOfDayType.dusk);
    });

    test('should return night late at night', () {
      final sunrise = DateTime(2024, 1, 1, 6, 0);
      final sunset = DateTime(2024, 1, 1, 18, 0);
      final now = DateTime(2024, 1, 1, 22, 0); // 10 PM

      final result = TimeOfDayType.calculate(
        now: now,
        sunrise: sunrise,
        sunset: sunset,
      );

      expect(result, TimeOfDayType.night);
    });
  });
}
