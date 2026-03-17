import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class AuthBear extends StatefulWidget {
  const AuthBear({
    super.key,
    this.emailFocus,
    this.passwordFocusNodes = const [],
    this.emailController,
    this.size = 300,
  });

  final FocusNode? emailFocus;
  final List<FocusNode> passwordFocusNodes;
  final TextEditingController? emailController;
  final double size;

  @override
  State<AuthBear> createState() => AuthBearState();
}

class AuthBearState extends State<AuthBear> {
  Artboard? _artboard;
  StateMachineController? _ctrl;
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMINumber? _numLook;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  void triggerSuccess() => _trigSuccess?.fire();
  void triggerFail() => _trigFail?.fire();
  void setHandsUp(bool value) => _isHandsUp?.value = value;
  void setChecking(bool value) => _isChecking?.value = value;

  @override
  void initState() {
    super.initState();
    _loadRive();
    widget.emailFocus?.addListener(_onEmailFocusChange);
    for (final fn in widget.passwordFocusNodes) {
      fn.addListener(_onPasswordFocusChange);
    }
    widget.emailController?.addListener(_onEmailTextChange);
  }

  Future<void> _loadRive() async {
    final data = await rootBundle.load('assets/rive/teddy_login.riv');
    final file = RiveFile.import(data);
    final artboard = file.mainArtboard;

    // The first Shape is typically the artboard background rectangle.
    var bgCleared = false;
    artboard.forEachComponent((child) {
      if (!bgCleared && child is Shape && child.fills.isNotEmpty) {
        child.fills.first.paint.color = const Color(0x00000000);
        bgCleared = true;
      }
    });

    _ctrl = StateMachineController.fromArtboard(artboard, 'Login Machine');
    if (_ctrl != null) {
      artboard.addController(_ctrl!);
      _isChecking = _ctrl!.getBoolInput('isChecking');
      _isHandsUp = _ctrl!.getBoolInput('isHandsUp');
      _numLook = _ctrl!.getNumberInput('numLook');
      _trigSuccess = _ctrl!.getTriggerInput('trigSuccess');
      _trigFail = _ctrl!.getTriggerInput('trigFail');
    }

    if (mounted) setState(() => _artboard = artboard);
  }

  @override
  void dispose() {
    widget.emailFocus?.removeListener(_onEmailFocusChange);
    for (final fn in widget.passwordFocusNodes) {
      fn.removeListener(_onPasswordFocusChange);
    }
    widget.emailController?.removeListener(_onEmailTextChange);
    _ctrl?.dispose();
    super.dispose();
  }

  void _onEmailFocusChange() {
    final focused = widget.emailFocus?.hasFocus ?? false;
    _isChecking?.value = focused;
    if (focused) {
      _isHandsUp?.value = false;
      _onEmailTextChange();
    }
  }

  void _onPasswordFocusChange() {
    final anyFocused = widget.passwordFocusNodes.any((fn) => fn.hasFocus);
    _isHandsUp?.value = anyFocused;
    if (anyFocused) {
      _isChecking?.value = false;
    }
  }

  void _onEmailTextChange() {
    if (!(widget.emailFocus?.hasFocus ?? false)) return;
    final len = widget.emailController?.text.length ?? 0;
    _numLook?.value = len.toDouble().clamp(0, 30);
  }

  @override
  Widget build(BuildContext context) {
    if (_artboard == null) {
      return SizedBox(height: widget.size * 0.8);
    }

    return RepaintBoundary(
      child: SizedBox(
        height: widget.size * 0.8,
        width: widget.size,
        child: ClipRect(
          child: OverflowBox(
            maxHeight: widget.size,
            maxWidth: widget.size,
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: widget.size,
              width: widget.size,
              child: Rive(artboard: _artboard!, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
