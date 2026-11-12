import 'dart:async';
import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

/// Quiz Header tinh giản, Monospace Timer Capsule & Hairline Progress Bar
class QuizHeader extends StatefulWidget {
  const QuizHeader({
    super.key,
    required this.title,
    required this.duration,
    required this.totalQuestions,
    required this.onTimeUp,
    this.currentIndex = 0,
    this.answeredCount = 0,
    this.onOpenPalette,
  });

  final String title;
  final int duration;
  final int totalQuestions;
  final VoidCallback onTimeUp;
  final int currentIndex;
  final int answeredCount;
  final VoidCallback? onOpenPalette;

  @override
  State<QuizHeader> createState() => _QuizHeaderState();
}

class _QuizHeaderState extends State<QuizHeader> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.duration * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        widget.onTimeUp();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get _isCriticalTime => _remainingSeconds <= 30;
  bool get _isWarningTime => _remainingSeconds <= 120;

  Color _timerColor(ColorScheme cs) {
    if (_isCriticalTime) return const Color(0xFFDC2626);
    if (_isWarningTime) return const Color(0xFFD97706);
    return cs.slate700;
  }

  Color _timerBgColor(ColorScheme cs) {
    if (_isCriticalTime) return const Color(0xFFFEF2F2);
    if (_isWarningTime) return const Color(0xFFFFFBEB);
    return cs.slate100;
  }

  IconData get _timerIcon {
    if (_isCriticalTime) return Icons.alarm_on_rounded;
    if (_isWarningTime) return Icons.hourglass_bottom_rounded;
    return Icons.timer_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final timerColor = _timerColor(cs);
    final timerBg = _timerBgColor(cs);

    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 10, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _showExitDialog(context),
                icon: const Icon(Icons.close_rounded, size: 22),
                tooltip: 'Thoát',
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: cs.slate900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Câu ${widget.currentIndex + 1}/${widget.totalQuestions} • Đã làm ${widget.answeredCount}/${widget.totalQuestions}',
                      style: tt.bodySmall?.copyWith(
                        color: cs.slate500,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Monospace Timer Capsule
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: timerBg,
                  borderRadius: BorderRadius.circular(6), // Squircle bo nhẹ 6px
                  border: Border.all(
                    color: timerColor.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_timerIcon, size: 14, color: timerColor),
                    const SizedBox(width: 4),
                    Text(
                      _formattedTime,
                      style: tt.labelMedium?.copyWith(
                        color: timerColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),

              if (widget.onOpenPalette != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: widget.onOpenPalette,
                  icon: const Icon(Icons.grid_view_rounded, size: 19),
                  tooltip: 'Ma trận câu hỏi',
                  color: cs.slate600,
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),

          // Hairline Slim Progress Bar (2.5px)
          ClipRRect(
            borderRadius: BorderRadius.circular(1.5),
            child: LinearProgressIndicator(
              value: widget.totalQuestions > 0
                  ? widget.answeredCount / widget.totalQuestions
                  : 0.0,
              minHeight: 2.5,
              backgroundColor: cs.slate200.withValues(alpha: 0.6),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
            const SizedBox(width: 8),
            Text(l10n.quizExitTitle, style: const TextStyle(fontSize: 16.5)),
          ],
        ),
        content: Text(l10n.quizExitContent, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.quizContinue),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: Text(l10n.quizExit),
          ),
        ],
      ),
    );
  }
}
