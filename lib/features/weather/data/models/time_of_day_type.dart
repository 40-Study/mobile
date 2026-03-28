/// Time of day types calculated from sunrise/sunset
enum TimeOfDayType {
  dawn, // Sunrise - 30min → Sunrise + 1h
  day, // Sunrise + 1h → Sunset - 1h
  dusk, // Sunset - 1h → Sunset + 30min
  night; // Sunset + 30min → Sunrise - 30min

  /// Calculate from sunrise/sunset (NO hardcoded hours)
  static TimeOfDayType calculate({
    required DateTime now,
    required DateTime sunrise,
    required DateTime sunset,
  }) {
    final dawnStart = sunrise.subtract(const Duration(minutes: 30));
    final dawnEnd = sunrise.add(const Duration(hours: 1));
    final duskStart = sunset.subtract(const Duration(hours: 1));
    final duskEnd = sunset.add(const Duration(minutes: 30));

    if (_isInRange(now, dawnStart, dawnEnd)) {
      return TimeOfDayType.dawn;
    } else if (_isInRange(now, dawnEnd, duskStart)) {
      return TimeOfDayType.day;
    } else if (_isInRange(now, duskStart, duskEnd)) {
      return TimeOfDayType.dusk;
    } else {
      return TimeOfDayType.night;
    }
  }

  static bool _isInRange(DateTime time, DateTime start, DateTime end) {
    return time.isAfter(start) && time.isBefore(end);
  }
}
