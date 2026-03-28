import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/weather/weather.dart';
import 'package:study/theme/app_colors.dart';

class ScheduleFilterChips extends StatelessWidget {
  const ScheduleFilterChips({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final allFilters = ['all', ...filters];

    return BlocBuilder<WeatherBackgroundCubit, WeatherBackgroundState>(
      builder: (context, state) {
        final isDark = context.isWeatherBackgroundDark;
        final textColor = context.weatherTextColorThemed;
        final unselectedBg = isDark
            ? Colors.black.withValues(alpha: 0.3)
            : cs.surfaceContainerLowest;
        final borderColor = isDark
            ? Colors.white.withValues(alpha: 0.2)
            : cs.outline;

        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.screenMargin,
            ),
            itemCount: allFilters.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final filter = allFilters[index];
              final isSelected = selected == filter;
              final label = filter == 'all'
                  ? 'Tat ca khoa hoc'
                  : _shortenName(filter);

              return GestureDetector(
                onTap: () => onSelected(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? cs.primary : unselectedBg,
                    borderRadius: AppRadius.borderXxl,
                    border: isSelected ? null : Border.all(color: borderColor),
                    boxShadow: isSelected ? cs.shadowPrimary : null,
                  ),
                  child: Text(
                    label,
                    style: tt.labelMedium?.copyWith(
                      color: isSelected ? cs.onPrimary : textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _shortenName(String name) {
    if (name.length <= 18) return name;
    final words = name.split(' ');
    if (words.length > 3) {
      return '${words.take(3).join(' ')}...';
    }
    return name;
  }
}
