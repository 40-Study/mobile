import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class ObjectiveItem extends StatelessWidget {
  const ObjectiveItem({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      width: (MediaQuery.of(context).size.width - AppSpacing.screenPadding * 2 - 8) / 2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, color: cs.primary, size: 18),
          AppSpacing.hGap8,
          Expanded(
            child: Text(
              text,
              style: tt.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
