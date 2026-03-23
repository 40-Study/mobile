import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth_animation_cubit.dart';
import 'package:study/features/auth/bloc/register/register_bloc.dart';
import 'package:study/features/auth/presentation/utils/otp_countdown_mixin.dart';
import 'package:study/features/auth/presentation/widgets/auth_animations.dart';
import 'package:study/features/auth/presentation/widgets/auth_button.dart';
import 'package:study/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:study/features/auth/presentation/widgets/login_bear.dart';
import 'package:study/features/auth/presentation/widgets/otp_boxes.dart';
import 'package:study/routes/router.dart';

class RegisterOtpScreen extends StatefulWidget {
  const RegisterOtpScreen({super.key});

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen>
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

  @override
  Widget build(BuildContext context) {
    final navigator = NavigationService.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
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
                startCountdown();
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
                                'Mã xác thực đã gửi đến $email',
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
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: isCountdownActive
                                    ? null
                                    : () {
                                        context.read<RegisterBloc>().add(
                                          RegisterOTPResent(
                                            email: email,
                                            password:
                                                args['password'] as String,
                                            confirmPassword:
                                                args['confirmPassword']
                                                    as String,
                                            userName:
                                                args['userName'] as String,
                                            roleId: args['roleId'] as String,
                                            fullName:
                                                args['fullName'] as String?,
                                          ),
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
