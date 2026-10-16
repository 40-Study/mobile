import 'dart:async';

import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

/// Quiz header với timer, Slim progress bar, và exit dialog
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
    return cs.primary;
  }

  Color _timerBgColor(ColorScheme cs) {
    if (_isCriticalTime) return const Color(0xFFFEE2E2);
    if (_isWarningTime) return const Color(0xFFFEF3C7);
    return cs.primary.withValues(alpha: 0.1);
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
      padding: const EdgeInsets.fromLTRB(4, 6, 8, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _showExitDialog(context),
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Thoát',
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Câu ${widget.currentIndex + 1}/${widget.totalQuestions} • Đã làm ${widget.answeredCount}/${widget.totalQuestions}',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Timer pill
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: timerBg,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: timerColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_timerIcon, size: 15, color: timerColor),
                    const SizedBox(width: 5),
                    Text(
                      _formattedTime,
                      style: tt.labelMedium?.copyWith(
                        color: timerColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.onOpenPalette != null) ...[
                const SizedBox(width: 2),
                IconButton(
                  onPressed: widget.onOpenPalette,
                  icon: const Icon(Icons.grid_view_rounded, size: 20),
                  tooltip: 'Ma trận câu hỏi',
                  color: cs.onSurfaceVariant,
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: widget.totalQuestions > 0
                  ? widget.answeredCount / widget.totalQuestions
                  : 0.0,
              minHeight: 3.5,
              backgroundColor: cs.outlineVariant.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
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
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            AppSpacing.hGap8,
            Text(l10n.quizExitTitle),
          ],
        ),
        content: Text(l10n.quizExitContent),
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
