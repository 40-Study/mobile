import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/weather/weather.dart';

class ExploreSectionHeader extends StatelessWidget {
  const ExploreSectionHeader({
    super.key,
    required this.title,
    required this.onViewAll,
  });
  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<WeatherBackgroundCubit, WeatherBackgroundState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.weatherTextColorThemed,
                ),
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'Tat ca',
                style: tt.bodyMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
