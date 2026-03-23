import 'dart:async';

import 'package:flutter/material.dart';

/// Mixin that provides OTP countdown functionality.
///
/// Usage:
/// ```dart
/// class _MyScreenState extends State<MyScreen> with OtpCountdownMixin {
///   @override
///   void initState() {
///     super.initState();
///     startCountdown();
///   }
/// }
/// ```
mixin OtpCountdownMixin<T extends StatefulWidget> on State<T> {
  Timer? _otpTimer;
  int _otpCountdown = 300; // 5 minutes default

  /// Current countdown value in seconds.
  int get countdown => _otpCountdown;

  /// Whether countdown is still active (not expired).
  bool get isCountdownActive => _otpCountdown > 0;

  /// Formatted countdown string (MM:SS).
  String get countdownText {
    final minutes = _otpCountdown ~/ 60;
    final seconds = _otpCountdown % 60;
    return '${minutes.toString().padLeft(2, '0')}'
        ':${seconds.toString().padLeft(2, '0')}';
  }

  /// Starts or restarts the countdown.
  void startCountdown([int seconds = 300]) {
    _otpTimer?.cancel();
    _otpCountdown = seconds;

    _otpTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_otpCountdown > 0) {
        setState(() => _otpCountdown--);
      } else {
        _otpTimer?.cancel();
      }
    });
  }

  /// Stops the countdown.
  void stopCountdown() {
    _otpTimer?.cancel();
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    super.dispose();
  }
}
