import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth_animation_cubit.dart';
import 'package:study/features/auth/bloc/register/register_bloc.dart';
import 'package:study/features/auth/presentation/widgets/auth_animations.dart';
import 'package:study/features/auth/presentation/widgets/auth_button.dart';
import 'package:study/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:study/features/auth/presentation/widgets/auth_gradient_header.dart';
import 'package:study/features/auth/presentation/widgets/otp_boxes.dart';
import 'package:study/routes/router.dart';

class RegisterOtpScreen extends StatefulWidget {
  const RegisterOtpScreen({super.key});

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  final _otpKey = GlobalKey<OtpBoxesState>();
  final _animCubit = AuthAnimationCubit();
  String _otp = '';
  Timer? _timer;
  int _countdown = 300;

  @override
  void initState() {
    super.initState();
    _animCubit.startEntrance();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animCubit.close();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    _countdown = 300;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        _timer?.cancel();
      }
    });
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
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is! Map<String, dynamic>) {
      return const Scaffold(body: Center(child: Text('Dữ liệu không hợp lệ')));
    }

    final email = args['email'] as String;

    return BlocProvider.value(
      value: _animCubit,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocListener<RegisterBloc, RegisterState>(
          listener: (context, state) {
            final anim = context.read<AuthAnimationCubit>();
            switch (state) {
              case RegisterInProgress():
                anim.submit();
              case RegisterSuccess():
                anim.succeed();
                Future.delayed(const Duration(milliseconds: 400), () {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
                    ),
                  );
                  navigator.pushAndRemoveAll(Routes.login);
                });
              case RegisterOTPSent():
                anim.entranceComplete();
                _startCountdown();
                _otpKey.currentState?.clear();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Đã gửi lại OTP')));
              case RegisterFailure(:final message):
                anim.fail();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              case RegisterInitial():
              case RegisterRolesLoaded():
              case RegisterRolesFailure():
                break;
            }
          },
          child: SafeArea(
            top: false,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: AuthFormCard(
                  child: StaggeredColumn(
                    animate: _animCubit.state.shouldAnimate,
                    spacing: 20,
                    onComplete: _animCubit.entranceComplete,
                    children: [
                      AuthHeader(
                        icon: Icons.email_outlined,
                        title: 'Xác thực OTP',
                        subtitle: 'Mã xác thực đã gửi đến $email',
                      ),
                      OtpBoxes(key: _otpKey, onCompleted: (otp) => _otp = otp),
                      Center(
                        child: Text(
                          'Hết hạn sau $_countdownText',
                          style: TextStyle(
                            fontSize: 13,
                            color: _countdown > 0 ? cs.primary : cs.error,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      BlocBuilder<RegisterBloc, RegisterState>(
                        builder: (context, state) {
                          return BlocBuilder<
                            AuthAnimationCubit,
                            AuthAnimationState
                          >(
                            builder: (context, animState) {
                              return AuthButton(
                                label: 'Xác nhận OTP',
                                isLoading: state is RegisterInProgress,
                                isSuccess:
                                    animState.status ==
                                    AuthScreenAnimStatus.success,
                                onPressed: () {
                                  context.read<RegisterBloc>().add(
                                    RegisterOTPSubmitted(
                                      email: email,
                                      otp: _otp,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Chưa nhận được mã? ',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: _countdown > 0
                                ? null
                                : () {
                                    context.read<RegisterBloc>().add(
                                      RegisterOTPResent(
                                        email: email,
                                        password: args['password'] as String,
                                        confirmPassword:
                                            args['confirmPassword'] as String,
                                        userName: args['userName'] as String,
                                        fullName: args['fullName'] as String?,
                                        roleIds:
                                            (args['roleIds'] as List<dynamic>?)
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
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
