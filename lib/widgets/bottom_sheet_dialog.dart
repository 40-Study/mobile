import 'package:flutter/material.dart';
import 'package:study/index.dart';

const kDialogContentPadding = EdgeInsets.symmetric(
  horizontal: AppSpacing.dialogContentPadding,
);

Future<T?> showBottomSheetDialog<T>({
  required BuildContext context,
  required List<Widget> children,
  EdgeInsets padding = kDialogContentPadding,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: true,
    barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.54),
    enableDrag: true,
    builder: (context) =>
        _RoundDialog.bottom(children: children, padding: padding),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppRadius.dialogCorner),
        topRight: Radius.circular(AppRadius.dialogCorner),
      ),
    ),
  );
}

class _RoundDialog extends StatelessWidget {
  factory _RoundDialog.bottom({
    Key? key,
    required List<Widget> children,
    EdgeInsets? padding,
  }) {
    return _RoundDialog._(key: key, children: children, padding: padding);
  }

  const _RoundDialog._({super.key, required this.children, this.padding});

  final List<Widget> children;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 32),
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: Separator.spaceChildren(
            space: AppSpacing.xl, // 24
            children: [
              BottomSheetDialogIcon(),
              Flexible(
                child: SingleChildScrollView(
                  padding: padding,
                  child: ListBody(children: children),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
