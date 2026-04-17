import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/theme/app_colors.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final textColor = cs.onSurface;
    final subtitleColor = cs.onSurface.withValues(alpha: 0.6);

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
            color: cs.surfaceContainerLowest,
            borderRadius: AppRadius.borderMd,
            boxShadow: cs.shadowCard,
          ),
          child: Icon(
            Icons.notifications_none_rounded,
            color: cs.onSurface,
            size: 22,
          ),
        ),
      ],
    );
  }
}
