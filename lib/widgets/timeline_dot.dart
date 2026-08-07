import 'package:flutter/material.dart';

class TimelineDot extends StatelessWidget {
  const TimelineDot({
    super.key,
    this.isActive = false,
    this.size = 12,
    this.activeColor,
    this.inactiveColor,
  });

  final bool isActive;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final active = activeColor ?? cs.primary;
    final inactive = inactiveColor ?? cs.outline;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? active : Colors.transparent,
        border: Border.all(
          color: isActive ? active : inactive,
          width: 2,
        ),
      ),
    );
  }
}
