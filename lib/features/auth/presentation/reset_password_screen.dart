import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth_animation_cubit.dart';
import 'package:study/features/auth/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:study/features/auth/presentation/widgets/auth_animations.dart';
import 'package:study/features/auth/presentation/widgets/auth_button.dart';
import 'package:study/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:study/features/auth/presentation/widgets/auth_gradient_header.dart';
import 'package:study/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:study/routes/router.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _animCubit = AuthAnimationCubit();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _animCubit.startEntrance();
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _animCubit.close();
    super.dispose();
  }

  void _onSubmit(String email, String otp) {
    if (!_formKey.currentState!.validate()) return;
    context.read<ForgotPasswordBloc>().add(
      ForgotPasswordResetSubmitted(
        email: email,
        otp: otp,
        newPassword: _passwordCtrl.text,
        confirmPassword: _confirmCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigator = NavigationService.of(context);
    final cs = Theme.of(context).colorScheme;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    final email = args['email'] as String? ?? '';
    final otp = args['otp'] as String? ?? '';

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
              case ForgotPasswordSuccess():
                anim.succeed();
                Future.delayed(const Duration(milliseconds: 400), () {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đặt lại mật khẩu thành công!'),
                    ),
                  );
                  navigator.pushAndRemoveAll(Routes.login);
                });
              case ForgotPasswordFailure(:final message):
                anim.fail();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              case ForgotPasswordInitial():
              case ForgotPasswordOTPSent():
              case ForgotPasswordOTPVerifiedState():
                break;
            }
          },
          child: SafeArea(
            top: false,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: AuthFormCard(
                  child: Form(
                    key: _formKey,
                    child: StaggeredColumn(
                      animate: _animCubit.state.shouldAnimate,
                      spacing: 20,
                      onComplete: _animCubit.entranceComplete,
                      children: [
                        const AuthHeader(
                          icon: Icons.lock_reset_rounded,
                          title: 'Đặt mật khẩu mới',
                          subtitle: 'Nhập mật khẩu mới cho tài khoản',
                        ),
                        AuthTextField(
                          controller: _passwordCtrl,
                          label: 'Mật khẩu mới',
                          textInputAction: TextInputAction.next,
                          isObscured: _obscurePassword,
                          onToggleObscure: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Vui lòng nhập mật khẩu';
                            }
                            if (v.length < 8) return 'Tối thiểu 8 ký tự';
                            return null;
                          },
                        ),
                        AuthTextField(
                          controller: _confirmCtrl,
                          label: 'Xác nhận mật khẩu',
                          textInputAction: TextInputAction.done,
                          isObscured: _obscureConfirm,
                          onToggleObscure: () {
                            setState(() => _obscureConfirm = !_obscureConfirm);
                          },
                          validator: (v) {
                            if (v != _passwordCtrl.text) {
                              return 'Mật khẩu không khớp';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 4),
                        BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                          builder: (context, state) {
                            return BlocBuilder<
                              AuthAnimationCubit,
                              AuthAnimationState
                            >(
                              builder: (context, animState) {
                                return AuthButton(
                                  label: 'Đặt lại mật khẩu',
                                  isLoading: state is ForgotPasswordInProgress,
                                  isSuccess:
                                      animState.status ==
                                      AuthScreenAnimStatus.success,
                                  onPressed: () => _onSubmit(email, otp),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
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
