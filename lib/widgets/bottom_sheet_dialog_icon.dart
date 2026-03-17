import 'package:flutter/material.dart';
import 'package:study/constants/index.dart';

class BottomSheetDialogIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: UiSize.bottomSheetTopIconWidth,
      height: UiSize.bottomSheetTopIconHeight,
      child: Card(shadowColor: Colors.transparent, color: cs.outlineVariant),
    );
  }
}
