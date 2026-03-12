import 'package:flutter/material.dart';
import 'package:study/constants/index.dart';
import 'package:study/generated/colors.gen.dart';

class BottomSheetDialogIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: UiSize.bottomSheetTopIconWidth,
      height: UiSize.bottomSheetTopIconHeight,
      child: Card(
        shadowColor: Colors.transparent,
        color: ColorName.bottomSheetTopIconColor,
      ),
    );
  }
}
