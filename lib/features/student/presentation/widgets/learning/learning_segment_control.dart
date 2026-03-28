import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/weather/weather.dart';

class LearningSegmentControl extends StatelessWidget {
  const LearningSegmentControl({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const _labels = ['Khoa hoc', 'Lich hoc', 'Bai tap can lam'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<WeatherBackgroundCubit, WeatherBackgroundState>(
      builder: (context, state) {
        final isDark = context.isWeatherBackgroundDark;
        final containerColor = isDark
            ? Colors.black.withValues(alpha: 0.3)
            : cs.surfaceContainerLow;
        final selectedBgColor = isDark
            ? Colors.white.withValues(alpha: 0.2)
            : cs.surfaceContainerLowest;
        final textColor = context.weatherTextColorThemed;
        final textColorSecondary = context.weatherTextColorThemedSecondary;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.screenMargin,
          ),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: AppRadius.borderXxl,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : cs.outline,
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / _labels.length;

                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      left: currentIndex * itemWidth,
                      top: 0,
                      bottom: 0,
                      width: itemWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedBgColor,
                          borderRadius: AppRadius.borderXxl,
                          boxShadow: [
                            BoxShadow(
                              color: cs.shadow.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(_labels.length, (i) {
                        final isSelected = currentIndex == i;
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onChanged(i),
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: (tt.bodyMedium ?? const TextStyle())
                                    .copyWith(
                                  color: isSelected
                                      ? textColor
                                      : textColorSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                                child: Text(
                                  _labels[i],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
