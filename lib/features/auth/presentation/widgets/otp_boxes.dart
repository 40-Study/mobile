import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study/features/auth/presentation/widgets/auth_animations.dart';

/// 6 OTP boxes with digit fill pulse and completion ripple (always active).
class OtpBoxes extends StatefulWidget {
  const OtpBoxes({super.key, required this.onCompleted, this.length = 6});

  final ValueChanged<String> onCompleted;
  final int length;

  @override
  State<OtpBoxes> createState() => OtpBoxesState();
}

class OtpBoxesState extends State<OtpBoxes> with TickerProviderStateMixin {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final List<AnimationController> _pulseControllers;
  late final List<Animation<double>> _pulseScales;
  late final List<AnimationController> _glowControllers;
  late final List<Animation<double>> _glowOpacities;

  String get otp => _controllers.map((c) => c.text).join();

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    _pulseControllers = List.generate(widget.length, (_) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 150),
      );
    });
    _pulseScales = List.generate(widget.length, (i) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 1),
      ]).animate(
        CurvedAnimation(parent: _pulseControllers[i], curve: Curves.easeOut),
      );
    });

    _glowControllers = List.generate(widget.length, (_) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
    });
    _glowOpacities = List.generate(widget.length, (i) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.2), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.2, end: 0.0), weight: 1),
      ]).animate(
        CurvedAnimation(parent: _glowControllers[i], curve: Curves.easeOut),
      );
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    for (final c in _pulseControllers) {
      c.dispose();
    }
    for (final c in _glowControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length == 1) {
      _pulseControllers[index].forward(from: 0);
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      }
    }

    if (otp.length == widget.length) {
      _triggerCompletionRipple();
      widget.onCompleted(otp);
    }
  }

  void _triggerCompletionRipple() {
    for (var i = 0; i < widget.length; i++) {
      Future.delayed(
        Duration(milliseconds: AuthAnimConst.staggerDelay.inMilliseconds * i),
        () {
          if (mounted) _glowControllers[i].forward(from: 0);
        },
      );
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (event.logicalKey != LogicalKeyboardKey.backspace) return;
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const gap = 8.0;

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalGap = gap * (widget.length - 1);
          final boxWidth = ((constraints.maxWidth - totalGap) / widget.length)
              .floorToDouble();
          final clampedWidth = boxWidth.clamp(36.0, 52.0);

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.length, (i) {
              final hasFill = _controllers[i].text.isNotEmpty;

              return Padding(
                padding: EdgeInsets.only(
                  right: i < widget.length - 1 ? gap : 0,
                ),
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _pulseControllers[i],
                    _glowControllers[i],
                  ]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseControllers[i].isAnimating
                          ? _pulseScales[i].value
                          : 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _glowControllers[i].isAnimating
                              ? [
                                  BoxShadow(
                                    color: cs.primary.withValues(
                                      alpha: _glowOpacities[i].value,
                                    ),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : const [],
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: SizedBox(
                    width: clampedWidth,
                    height: clampedWidth + 8,
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (e) => _onKeyEvent(i, e),
                      child: AnimatedContainer(
                        duration: AuthAnimConst.focusDuration,
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
                                color: hasFill ? cs.primary : cs.outline,
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
                                color: hasFill ? cs.primary : cs.outline,
                              ),
                            ),
                          ),
                          onChanged: (v) => _onChanged(i, v),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
