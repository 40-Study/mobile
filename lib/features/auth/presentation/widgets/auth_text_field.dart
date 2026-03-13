import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: tt.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscured ?? obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          enabled: enabled,
          validator: validator,
          style: tt.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: tt.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant
                  .withValues(alpha: 0.5),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20)
                : null,
            suffixIcon: onToggleObscure != null
                ? IconButton(
                    icon: Icon(
                      (isObscured ?? obscureText)
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: cs.onSurfaceVariant,
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
            filled: true,
            fillColor: cs.surfaceContainerLow,
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: cs.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: cs.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: cs.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: cs.error,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
