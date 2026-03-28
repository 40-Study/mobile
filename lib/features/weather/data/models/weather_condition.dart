/// Weather condition types mapped from API
enum WeatherCondition {
  sunny,
  rainy,
  snowy,
  cloudy,
  defaultNeutral;

  /// Map from OpenWeatherMap API condition string
  static WeatherCondition fromApiCondition(String condition) {
    return switch (condition.toLowerCase()) {
      'clear' => WeatherCondition.sunny,
      'rain' || 'drizzle' || 'thunderstorm' => WeatherCondition.rainy,
      'snow' => WeatherCondition.snowy,
      'clouds' ||
      'mist' ||
      'fog' ||
      'haze' ||
      'smoke' ||
      'dust' ||
      'sand' ||
      'ash' =>
        WeatherCondition.cloudy,
      _ => WeatherCondition.defaultNeutral,
    };
  }
}
