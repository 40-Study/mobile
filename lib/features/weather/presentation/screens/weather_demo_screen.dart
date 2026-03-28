import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/weather/bloc/weather_background_cubit.dart';
import 'package:study/features/weather/data/models/models.dart';
import 'package:study/features/weather/presentation/widgets/city_picker_sheet.dart';
import 'package:study/features/weather/presentation/widgets/weather_background.dart';

/// Demo screen to preview all weather backgrounds
class WeatherDemoScreen extends StatefulWidget {
  const WeatherDemoScreen({super.key});

  @override
  State<WeatherDemoScreen> createState() => _WeatherDemoScreenState();
}

class _WeatherDemoScreenState extends State<WeatherDemoScreen> {
  double _currentHour = 12.0;
  WeatherCondition _condition = WeatherCondition.sunny;

  bool _isAutoPlaying = false;
  Timer? _autoPlayTimer;

  final double _sunriseHour = 6.0;
  final double _sunsetHour = 18.0;

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  TimeOfDayType get _timeOfDay {
    final hour = _currentHour;
    final sunrise = _sunriseHour;
    final sunset = _sunsetHour;

    if (hour >= sunrise - 0.5 && hour < sunrise + 1) {
      return TimeOfDayType.dawn;
    }
    if (hour >= sunrise + 1 && hour < sunset - 1) {
      return TimeOfDayType.day;
    }
    if (hour >= sunset - 1 && hour < sunset + 0.5) {
      return TimeOfDayType.dusk;
    }
    return TimeOfDayType.night;
  }

  String get _timeString {
    final hours = _currentHour.floor();
    final minutes = ((_currentHour - hours) * 60).round();
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}';
  }

  void _toggleAutoPlay() {
    setState(() {
      _isAutoPlaying = !_isAutoPlaying;
    });

    if (_isAutoPlaying) {
      _autoPlayTimer = Timer.periodic(
        const Duration(milliseconds: 50),
        (timer) {
          setState(() {
            _currentHour += 0.05;
            if (_currentHour >= 24) {
              _currentHour = 0;
            }
          });
        },
      );
    } else {
      _autoPlayTimer?.cancel();
    }
  }

  void _openCityPicker(BuildContext context) {
    final cubit = context.read<WeatherBackgroundCubit>();
    CityPickerSheet.show(
      context,
      selectedCity: cubit.selectedCity,
      onCitySelected: (city) {
        cubit.selectCity(city);
      },
      onUseGPS: () {
        cubit.useGPS();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Weather background
          Positioned.fill(
            child: WeatherBackground(
              condition: _condition,
              timeOfDay: _timeOfDay,
              transitionDuration: const Duration(milliseconds: 300),
            ),
          ),

          // Controls overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildControls(),
          ),

          // Info display
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: _buildInfoDisplay(),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Location picker button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.location_on, color: Colors.white),
              onPressed: () => _openCityPicker(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDisplay() {
    return Column(
      children: [
        Text(
          _timeString,
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w200,
            color: Colors.white,
            shadows: [
              Shadow(color: Colors.black26, blurRadius: 10),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_condition.name.toUpperCase()} • ${_timeOfDay.name.toUpperCase()}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Weather condition selector
          _buildWeatherSelector(),
          const SizedBox(height: 20),

          // Time markers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeMarker('00:00', 0),
              _buildTimeMarker('06:00', 6),
              _buildTimeMarker('12:00', 12),
              _buildTimeMarker('18:00', 18),
              _buildTimeMarker('24:00', 24),
            ],
          ),
          const SizedBox(height: 8),

          // Time slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: Colors.white24,
              trackHeight: 4,
            ),
            child: Slider(
              value: _currentHour,
              min: 0,
              max: 24,
              onChanged: (value) {
                setState(() {
                  _currentHour = value;
                  if (_isAutoPlaying) {
                    _toggleAutoPlay();
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          // Auto-play button
          FilledButton.icon(
            onPressed: _toggleAutoPlay,
            icon: Icon(_isAutoPlaying ? Icons.pause : Icons.play_arrow),
            label: Text(_isAutoPlaying ? 'Pause' : 'Auto Play'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: WeatherCondition.values
            .where((c) => c != WeatherCondition.defaultNeutral)
            .map((condition) => _buildWeatherChip(condition))
            .toList(),
      ),
    );
  }

  Widget _buildWeatherChip(WeatherCondition condition) {
    final isSelected = _condition == condition;
    final icon = switch (condition) {
      WeatherCondition.sunny => Icons.wb_sunny_rounded,
      WeatherCondition.rainy => Icons.water_drop_rounded,
      WeatherCondition.snowy => Icons.ac_unit_rounded,
      WeatherCondition.cloudy => Icons.cloud_rounded,
      WeatherCondition.defaultNeutral => Icons.help_outline,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(condition.name),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _condition = condition);
          }
        },
        backgroundColor: Colors.white24,
        selectedColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.black87 : Colors.white,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildTimeMarker(String label, double hour) {
    final isActive = (_currentHour - hour).abs() < 1;
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        color: isActive ? Colors.white : Colors.white54,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
