import 'package:flutter/material.dart';

class InstructorVerticalDivider extends StatelessWidget {
  const InstructorVerticalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 1,
      height: 40,
      color: cs.outlineVariant.withValues(alpha: 0.5),
    );
  }
}
