import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/weather/weather.dart';

class LocationHeader extends StatelessWidget {
  const LocationHeader({
    super.key,
    this.onLocationTap,
    this.onWeatherTap,
  });

  final VoidCallback? onLocationTap;
  final VoidCallback? onWeatherTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cubit = context.watch<WeatherBackgroundCubit>();
    final state = cubit.state;

    final cityName = cubit.selectedCity?.name ?? 'Chon thanh pho';
    final isLoading = state is WeatherBackgroundLoading;

    // Use extension for adaptive colors
    final isDark = context.isWeatherBackgroundDark;
    final textColor = context.weatherTextColorThemed;
    final subtitleColor = context.weatherTextColorThemedSecondary;
    final iconColor = context.weatherIconColor;
    final iconBgColor = context.weatherIconBackgroundColor;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onLocationTap,
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: iconColor,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vi tri hien tai',
                        style: tt.bodyMedium?.copyWith(
                          color: subtitleColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              cityName,
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: subtitleColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isLoading)
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: textColor,
            ),
          )
        else ...[
          // Debug button to cycle weather condition
          GestureDetector(
            onTap: () => cubit.cycleDebugCondition(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: AppRadius.borderSm,
              ),
              child: Text(
                _getConditionLabel(state.condition),
                style: tt.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          // Debug button to cycle time of day
          GestureDetector(
            onTap: () => cubit.cycleDebugTime(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: AppRadius.borderSm,
              ),
              child: Text(
                _getTimeLabel(state.timeOfDay),
                style: tt.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            width: AppIconSize.avatar,
            height: AppIconSize.avatar,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: iconColor,
              size: 22,
            ),
          ),
        ],
      ],
    );
  }

  IconData _getWeatherIcon(WeatherCondition condition) {
    return switch (condition) {
      WeatherCondition.sunny => Icons.wb_sunny,
      WeatherCondition.cloudy => Icons.cloud,
      WeatherCondition.rainy => Icons.water_drop,
      WeatherCondition.snowy => Icons.ac_unit,
      WeatherCondition.defaultNeutral => Icons.wb_cloudy,
    };
  }

  String _getTimeLabel(TimeOfDayType time) {
    return switch (time) {
      TimeOfDayType.dawn => '🌅',
      TimeOfDayType.day => '☀️',
      TimeOfDayType.dusk => '🌆',
      TimeOfDayType.night => '🌙',
    };
  }

  String _getConditionLabel(WeatherCondition condition) {
    return switch (condition) {
      WeatherCondition.sunny => '☀️',
      WeatherCondition.cloudy => '☁️',
      WeatherCondition.rainy => '🌧️',
      WeatherCondition.snowy => '❄️',
      WeatherCondition.defaultNeutral => '🌤️',
    };
  }
}
