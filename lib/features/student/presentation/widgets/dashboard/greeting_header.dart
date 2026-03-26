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

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chao mung tro lai,',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Chao $name!',
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
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
            color: cs.surfaceTintedPrimary,
            borderRadius: AppRadius.borderMd,
            boxShadow: cs.shadowCard,
          ),
          child: Icon(
            Icons.notifications_none_rounded,
            color: cs.primary,
            size: 22,
          ),
        ),
      ],
    );
  }
}
