import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study/theme/theme.dart';

/// Thẻ Đáp án Xúc giác Tinh xảo (Tactile Option Card)
/// Phong cách Refined Academic Minimalism - Loại bỏ viền 2px thô và shadow bệt
class AnswerOption extends StatefulWidget {
  const AnswerOption({
    super.key,
    required this.index,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.isMultipleChoice = false,
  });

  final int index;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isMultipleChoice;

  static const _labels = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  State<AnswerOption> createState() => _AnswerOptionState();
}

class _AnswerOptionState extends State<AnswerOption> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Subtle Surface Colors
    final Color cardBg;
    final Color borderColor;
    final double borderWidth;

    if (widget.isSelected) {
      cardBg = isDark
          ? const Color(0xFF1E3A8A).withValues(alpha: 0.2)
          : const Color(0xFFF8FAFF); // 3% Blue Tint
      borderColor = const Color(0xFF2563EB); // Academic Royal Blue
      borderWidth = 1.2;
    } else {
      cardBg = isDark ? cs.surfaceContainerLowest : Colors.white;
      borderColor = cs.slate200.withValues(alpha: 0.8); // Hairline 0.8px
      borderWidth = 0.8;
    }

    final letterBg = widget.isSelected
        ? const Color(0xFF2563EB)
        : (isDark ? cs.slate800 : cs.slate100);
    final letterColor = widget.isSelected
        ? Colors.white
        : (isDark ? cs.slate300 : cs.slate600);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.985 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12), // Bo góc 12px tinh tế
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // Squircle Letter Box 32×32px
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: letterBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    AnswerOption._labels[widget.index % AnswerOption._labels.length],
                    style: tt.labelLarge?.copyWith(
                      color: letterColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Option Content Text
                Expanded(
                  child: Text(
                    widget.text,
                    style: tt.bodyMedium?.copyWith(
                      fontSize: 14.5,
                      fontWeight: widget.isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: cs.slate900,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Trailing Modern Indicator
                if (widget.isSelected)
                  Icon(
                    widget.isMultipleChoice
                        ? Icons.check_box_rounded
                        : Icons.check_circle_rounded,
                    color: const Color(0xFF2563EB),
                    size: 20,
                  )
                else
                  Icon(
                    widget.isMultipleChoice
                        ? Icons.check_box_outline_blank_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: cs.slate300,
                    size: 19,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
