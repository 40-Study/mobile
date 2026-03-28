import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/weather/weather.dart';

class DashboardSectionRow extends StatelessWidget {
  const DashboardSectionRow({
    super.key,
    required this.title,
    this.action,
    this.actionColor,
    this.onActionTap,
  });

  final String title;
  final String? action;
  final Color? actionColor;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<WeatherBackgroundCubit, WeatherBackgroundState>(
      builder: (context, state) {
        final textColor = context.weatherTextColorThemed;

        return Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: onActionTap,
                child: Text(
                  action!,
                  style: tt.bodyLarge?.copyWith(
                    color: actionColor ?? cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
