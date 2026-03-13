import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 6 ô nhập OTP riêng biệt, tự chuyển focus.
class OtpBoxes extends StatefulWidget {
  const OtpBoxes({
    super.key,
    required this.onCompleted,
    this.length = 6,
  });

  final ValueChanged<String> onCompleted;
  final int length;

  @override
  State<OtpBoxes> createState() => OtpBoxesState();
}

class OtpBoxesState extends State<OtpBoxes> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  String get otp =>
      _controllers.map((c) => c.text).join();

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (_) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length == 1 && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (event.logicalKey != LogicalKeyboardKey.backspace) {
      return;
    }
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (i) {
        return Container(
          width: 48,
          height: 56,
          margin: EdgeInsets.only(
            right: i < widget.length - 1 ? 10 : 0,
          ),
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (e) => _onKeyEvent(i, e),
            child: TextField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: cs.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: cs.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: cs.primary,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: cs.outline,
                  ),
                ),
              ),
              onChanged: (v) => _onChanged(i, v),
            ),
          ),
        );
      }),
    );
  }
}
