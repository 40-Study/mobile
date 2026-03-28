import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/weather/weather.dart';
import 'package:study/theme/app_colors.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<WeatherBackgroundCubit, WeatherBackgroundState>(
      builder: (context, state) {
        final textColor = context.weatherTextColorThemed;
        final subtitleColor = context.weatherTextColorThemedSecondary;

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chao mung tro lai,',
                    style: tt.bodyLarge?.copyWith(
                      color: subtitleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Chao $name!',
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: AppIconSize.avatar,
              height: AppIconSize.avatar,
              decoration: BoxDecoration(
                color: context.weatherIconBackgroundColor,
                borderRadius: AppRadius.borderMd,
                boxShadow: cs.shadowCard,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: context.weatherIconColor,
                size: 22,
              ),
            ),
          ],
        );
      },
    );
  }
}
