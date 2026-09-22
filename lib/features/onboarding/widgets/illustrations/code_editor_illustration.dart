import 'package:flutter/material.dart';

/// Page 2: Code Editor - "Learn by Doing"
class CodeEditorIllustration extends StatelessWidget {
  const CodeEditorIllustration({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryBlue = colorScheme.primary;

    return SizedBox(
      width: 300,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background faded card
          Positioned(
            top: 0,
            child: Container(
              width: 220,
              height: 160,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _WindowDot(color: Colors.grey[300]!),
                    const SizedBox(width: 6),
                    _WindowDot(color: Colors.grey[300]!),
                    const SizedBox(width: 6),
                    _WindowDot(color: Colors.grey[300]!),
                  ],
                ),
              ),
            ),
          ),

          // Terminal side card
          Positioned(
            left: 0,
            top: 60,
            child: Container(
              width: 56,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.terminal, size: 20, color: primaryBlue),
                  const SizedBox(height: 12),
                  _ColoredLine(color: primaryBlue, width: 32),
                  const SizedBox(height: 6),
                  _ColoredLine(color: colorScheme.tertiary, width: 28),
                  const SizedBox(height: 6),
                  _ColoredLine(color: colorScheme.secondary, width: 24),
                ],
              ),
            ),
          ),

          // Main code editor card
          Positioned(
            right: 0,
            top: 40,
            child: Container(
              width: 220,
              height: 180,
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: 0.35),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Window dots + lightning
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _WindowDot(color: Colors.white.withValues(alpha: 0.5)),
                            const SizedBox(width: 6),
                            _WindowDot(color: Colors.white.withValues(alpha: 0.5)),
                            const SizedBox(width: 6),
                            _WindowDot(color: Colors.white.withValues(alpha: 0.5)),
                          ],
                        ),
                        Icon(
                          Icons.bolt,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Code lines
                    const _CodeLine(width: 60, opacity: 0.6),
                    const SizedBox(height: 8),
                    const _CodeLine(width: 140, opacity: 0.4),
                    const SizedBox(height: 8),
                    const _CodeLine(width: 100, opacity: 0.4),
                    const SizedBox(height: 8),
                    const _CodeLine(width: 120, opacity: 0.4),
                    const Spacer(),
                    // Run button
                    Container(
                      width: double.infinity,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Container(
                            width: 48,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowDot extends StatelessWidget {
  const _WindowDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _ColoredLine extends StatelessWidget {
  const _ColoredLine({required this.color, required this.width});
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _CodeLine extends StatelessWidget {
  const _CodeLine({required this.width, required this.opacity});
  final double width;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: width,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }
}
