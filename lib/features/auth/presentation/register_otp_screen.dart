import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/register/register_bloc.dart';
import 'package:study/features/auth/presentation/widgets/auth_button.dart';
import 'package:study/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:study/features/auth/presentation/widgets/auth_gradient_header.dart';
import 'package:study/features/auth/presentation/widgets/otp_boxes.dart';
import 'package:study/routes/router.dart';

class RegisterOtpScreen extends StatefulWidget {
  const RegisterOtpScreen({super.key});

  @override
  State<RegisterOtpScreen> createState() =>
      _RegisterOtpScreenState();
}

class _RegisterOtpScreenState
    extends State<RegisterOtpScreen> {
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

  @override
  Widget build(BuildContext context) {
    final navigator = NavigationService.of(context);
    final cs = Theme.of(context).colorScheme;
    final args =
        ModalRoute.of(context)?.settings.arguments;

    if (args is! Map<String, dynamic>) {
      return const Scaffold(
        body: Center(
          child: Text('Dữ liệu không hợp lệ'),
        ),
      );
    }

    final email = args['email'] as String;

    return Scaffold(
      body: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          switch (state) {
            case RegisterSuccess():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Đăng ký thành công! Vui lòng đăng nhập.',
                  ),
                ),
              );
              navigator.pushAndRemoveAll(Routes.login);
            case RegisterOTPSent():
              _startCountdown();
              _otpKey.currentState?.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã gửi lại OTP'),
                ),
              );
            case RegisterFailure(:final message):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            case RegisterInitial():
            case RegisterInProgress():
              break;
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              AuthGradientHeader(
                title: 'Xác thực OTP',
                subtitle:
                    'Mã xác thực đã gửi đến $email',
                showBackButton: true,
              ),
              AuthFormCard(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
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
                      BlocBuilder<RegisterBloc,
                          RegisterState>(
                        builder: (context, state) {
                          return AuthButton(
                            label: 'Xác nhận OTP',
                            isLoading: state
                                is RegisterInProgress,
                            onPressed: () {
                              context
                                  .read<RegisterBloc>()
                                  .add(
                                    RegisterOTPSubmitted(
                                      email: email,
                                      otp: _otp,
                                    ),
                                  );
                            },
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
                              color:
                                  cs.onSurfaceVariant,
                            ),
                          ),
                          GestureDetector(
                            onTap: _countdown > 0
                                ? null
                                : () {
                                    context
                                        .read<
                                            RegisterBloc>()
                                        .add(
                                          RegisterOTPResent(
                                            email: email,
                                            password: args[
                                                    'password']
                                                as String,
                                            confirmPassword:
                                                args['confirmPassword']
                                                    as String,
                                            userName: args[
                                                    'userName']
                                                as String,
                                            fullName: args[
                                                    'fullName']
                                                as String?,
                                            roleIds: (args['roleIds']
                                                    as List<dynamic>?)
                                                ?.cast<String>(),
                                          ),
                                        );
                                  },
                            child: Text(
                              _countdown > 0
                                  ? 'Gửi lại ($_countdownText)'
                                  : 'Gửi lại OTP',
                              style: TextStyle(
                                color: _countdown > 0
                                    ? cs.onSurfaceVariant
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
