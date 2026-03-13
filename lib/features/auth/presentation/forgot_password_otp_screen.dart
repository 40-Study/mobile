import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:study/features/auth/presentation/widgets/auth_button.dart';
import 'package:study/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:study/features/auth/presentation/widgets/auth_gradient_header.dart';
import 'package:study/features/auth/presentation/widgets/otp_boxes.dart';
import 'package:study/routes/router.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  const ForgotPasswordOtpScreen({super.key});

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState
    extends State<ForgotPasswordOtpScreen> {
  final _otpKey = GlobalKey<OtpBoxesState>();
  String _otp = '';
  Timer? _timer;
  int _countdown = 300;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    _countdown = 300;
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (_countdown > 0) {
          setState(() => _countdown--);
        } else {
          _timer?.cancel();
        }
      },
    );
  }

  String get _countdownText {
    final m = _countdown ~/ 60;
    final s = _countdown % 60;
    return '${m.toString().padLeft(2, '0')}'
        ':${s.toString().padLeft(2, '0')}';
  }

  void _onVerify(String email) {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đủ 6 số OTP'),
        ),
      );
      return;
    }
    context
        .read<ForgotPasswordBloc>()
        .add(ForgotPasswordOTPVerified(
          email: email,
          otp: _otp,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final navigator = NavigationService.of(context);
    final cs = Theme.of(context).colorScheme;
    final email = ModalRoute.of(context)
            ?.settings
            .arguments as String? ??
        '';

    return Scaffold(
      body: BlocListener<ForgotPasswordBloc,
          ForgotPasswordState>(
        listener: (context, state) {
          switch (state) {
            case ForgotPasswordOTPVerifiedState():
              navigator.navigateTo(
                Routes.resetPassword,
                {
                  'email': state.email,
                  'otp': state.otp,
                },
              );
            case ForgotPasswordOTPSent():
              _startCountdown();
              _otpKey.currentState?.clear();
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text('Đã gửi lại OTP'),
                ),
              );
            case ForgotPasswordFailure(
                :final message,
              ):
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                SnackBar(content: Text(message)),
              );
            case ForgotPasswordInitial():
            case ForgotPasswordInProgress():
            case ForgotPasswordSuccess():
              break;
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              AuthGradientHeader(
                title: 'Xác thực OTP',
                subtitle:
                    'Mã OTP đã gửi đến $email',
                showBackButton: true,
              ),
              AuthFormCard(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    24, 32, 24, 16,
                  ),
                  child: Column(
                    children: [
                      OtpBoxes(
                        key: _otpKey,
                        onCompleted: (otp) =>
                            _otp = otp,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hết hạn sau $_countdownText',
                        style: TextStyle(
                          fontSize: 13,
                          color: _countdown > 0
                              ? cs.primary
                              : cs.error,
                        ),
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<ForgotPasswordBloc,
                          ForgotPasswordState>(
                        builder: (context, state) {
                          return AuthButton(
                            label: 'Xác thực',
                            isLoading: state
                                is ForgotPasswordInProgress,
                            onPressed: () =>
                                _onVerify(email),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            'Chưa nhận được mã? ',
                            style: TextStyle(
                              color: cs
                                  .onSurfaceVariant,
                            ),
                          ),
                          GestureDetector(
                            onTap: _countdown > 0
                                ? null
                                : () {
                                    context
                                        .read<
                                            ForgotPasswordBloc>()
                                        .add(
                                          ForgotPasswordOTPResent(
                                            email:
                                                email,
                                          ),
                                        );
                                  },
                            child: Text(
                              _countdown > 0
                                  ? 'Gửi lại ($_countdownText)'
                                  : 'Gửi lại OTP',
                              style: TextStyle(
                                color: _countdown > 0
                                    ? cs
                                        .onSurfaceVariant
                                    : cs.primary,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
