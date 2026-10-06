import 'package:flutter/material.dart';

class BottomSheetDialogIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: 42,
      height: 15,
      child: Card(shadowColor: Colors.transparent, color: cs.outlineVariant),
    );
  }
}
