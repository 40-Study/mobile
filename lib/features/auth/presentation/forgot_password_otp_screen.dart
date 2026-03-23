import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth_animation_cubit.dart';
import 'package:study/features/auth/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:study/features/auth/presentation/utils/otp_countdown_mixin.dart';
import 'package:study/features/auth/presentation/widgets/auth_animations.dart';
import 'package:study/features/auth/presentation/widgets/auth_button.dart';
import 'package:study/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:study/features/auth/presentation/widgets/login_bear.dart';
import 'package:study/features/auth/presentation/widgets/otp_boxes.dart';
import 'package:study/routes/router.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  const ForgotPasswordOtpScreen({super.key});

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen>
    with OtpCountdownMixin {
  final _otpKey = GlobalKey<OtpBoxesState>();
  final _animCubit = AuthAnimationCubit();
  final _bearKey = GlobalKey<AuthBearState>();
  String _otp = '';

  @override
  void initState() {
    super.initState();
    _animCubit.startEntrance();
    startCountdown();
  }

  @override
  void dispose() {
    _animCubit.close();
    super.dispose();
  }

  void _onVerify(String email) {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ 6 số OTP')),
      );
      return;
    }
    context.read<ForgotPasswordBloc>().add(
      ForgotPasswordOTPVerified(email: email, otp: _otp),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigator = NavigationService.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';

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
        body: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
          listener: (context, state) {
            final anim = context.read<AuthAnimationCubit>();
            switch (state) {
              case ForgotPasswordInProgress():
                anim.submit();
              case ForgotPasswordOTPVerifiedState():
                anim.entranceComplete();
                navigator.navigateTo(Routes.resetPassword, {
                  'email': state.email,
                  'otp': state.otp,
                });
              case ForgotPasswordOTPSent():
                anim.entranceComplete();
                startCountdown();
                _otpKey.currentState?.clear();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Đã gửi lại OTP')));
              case ForgotPasswordFailure(:final message):
                anim.fail();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              case ForgotPasswordInitial():
              case ForgotPasswordSuccess():
                break;
            }
          },
          child: SafeArea(
            top: false,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, 40),
                      child: AuthBear(key: _bearKey),
                    ),
                    AuthFormCard(
                      child: StaggeredColumn(
                        animate: _animCubit.state.shouldAnimate,
                        spacing: 20,
                        onComplete: _animCubit.entranceComplete,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Xác thực OTP',
                                style: tt.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Mã OTP đã gửi đến $email',
                                style: tt.bodyLarge?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          OtpBoxes(
                            key: _otpKey,
                            onCompleted: (otp) => _otp = otp,
                          ),
                          Center(
                            child: Text(
                              'Hết hạn sau $countdownText',
                              style: TextStyle(
                                fontSize: 14,
                                color: isCountdownActive ? cs.primary : cs.error,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                            builder: (context, state) {
                              return AuthButton(
                                label: 'Xác thực',
                                isLoading: state is ForgotPasswordInProgress,
                                onPressed: () => _onVerify(email),
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
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: isCountdownActive
                                    ? null
                                    : () {
                                        context.read<ForgotPasswordBloc>().add(
                                          ForgotPasswordOTPResent(email: email),
                                        );
                                      },
                                child: Text(
                                  isCountdownActive
                                      ? 'Gửi lại ($countdownText)'
                                      : 'Gửi lại OTP',
                                  style: TextStyle(
                                    color: isCountdownActive
                                        ? cs.onSurfaceVariant
                                        : cs.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
