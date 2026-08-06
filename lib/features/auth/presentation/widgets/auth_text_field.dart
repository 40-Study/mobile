import 'package:flutter/material.dart';
import 'package:study/features/auth/presentation/widgets/auth_animations.dart';
import 'package:study/theme/theme.dart';

/// Text field with focus glow (always active) and error shake (always active).
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.focusNode,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onToggleObscure,
    this.isObscured,
    this.prefixIcon,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final FocusNode? focusNode;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final VoidCallback? onToggleObscure;
  final bool? isObscured;
  final IconData? prefixIcon;
  final bool enabled;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField>
    with SingleTickerProviderStateMixin {
  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;
  bool _isFocused = false;
  bool _hasError = false;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeOffset;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }
    _focusNode.addListener(_onFocusChange);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _shakeOffset =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: 6), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 6, end: -6), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -6, end: 4), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 4, end: -4), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );

    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _internalFocusNode?.dispose();
    _shakeController.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _onTextChanged() {
    if (_hasError) setState(() => _hasError = false);
  }

  String? _wrappedValidator(String? value) {
    final result = widget.validator?.call(value);
    if (result != null && !_hasError) {
      setState(() => _hasError = true);
      _shakeController.forward(from: 0);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: tt.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        AppSpacing.vGap8,
        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                _shakeController.isAnimating ? _shakeOffset.value : 0,
                0,
              ),
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: AuthAnimConst.focusDuration,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.12),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : const [],
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.isObscured ?? widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              enabled: widget.enabled,
              validator: widget.validator != null ? _wrappedValidator : null,
              style: tt.bodyLarge?.copyWith(color: cs.onSurface),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: tt.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(widget.prefixIcon, size: 20)
                    : null,
                suffixIcon: widget.onToggleObscure != null
                    ? IconButton(
                        icon: Icon(
                          (widget.isObscured ?? widget.obscureText)
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: cs.onSurfaceVariant,
                        ),
                        onPressed: widget.onToggleObscure,
                      )
                    : null,
                filled: true,
                fillColor: cs.surfaceContainerLow,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg - 2,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.error),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
