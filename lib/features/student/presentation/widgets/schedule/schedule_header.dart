import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/weather/weather.dart';
import 'package:study/theme/app_colors.dart';

class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppLayout.screenMargin,
        AppSpacing.lg,
        AppLayout.screenMargin,
        0,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: cs.gradientPrimary,
              borderRadius: AppRadius.borderMd,
              boxShadow: cs.shadowPrimary,
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: cs.onPrimary,
              size: AppIconSize.lg,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: BlocBuilder<WeatherBackgroundCubit, WeatherBackgroundState>(
              builder: (context, state) {
                return Text(
                  'Lich hoc cua toi',
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.weatherTextColorThemed,
                  ),
                );
              },
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: cs.outline),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: cs.primary,
              size: AppIconSize.md,
            ),
          ),
        ],
      ),
    );
  }
}
