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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _animCubit = AuthAnimationCubit();

  @override
  void initState() {
    super.initState();
    _animCubit.startEntrance();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _animCubit.close();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ForgotPasswordBloc>().add(
      ForgotPasswordSubmitted(email: _emailCtrl.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigator = NavigationService.of(context);
    final cs = Theme.of(context).colorScheme;

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
              case ForgotPasswordOTPSent():
                anim.entranceComplete();
                navigator.navigateTo(
                  Routes.forgotPasswordOtp,
                  _emailCtrl.text.trim(),
                );
              case ForgotPasswordFailure(:final message):
                anim.fail();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              case ForgotPasswordInitial():
              case ForgotPasswordOTPVerifiedState():
              case ForgotPasswordSuccess():
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
                          icon: Icons.lock_outline_rounded,
                          title: 'Quên mật khẩu?',
                          subtitle: 'Nhập email của bạn để nhận mã xác thực',
                        ),
                        AuthTextField(
                          controller: _emailCtrl,
                          label: 'Email',
                          hint: 'Nhập email của bạn',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Vui lòng nhập email';
                            }
                            if (!v.contains('@')) {
                              return 'Email không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 4),
                        BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                          builder: (context, state) {
                            return AuthButton(
                              label: 'Gửi mã xác thực',
                              isLoading: state is ForgotPasswordInProgress,
                              onPressed: _onSubmit,
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Quay lại ',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  color: cs.primary,
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
      ),
    );
  }
}
