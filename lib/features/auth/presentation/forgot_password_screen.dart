import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:study/features/auth/presentation/widgets/auth_button.dart';
import 'package:study/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:study/features/auth/presentation/widgets/auth_gradient_header.dart';
import 'package:study/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:study/routes/router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ForgotPasswordBloc>().add(
          ForgotPasswordSubmitted(
            email: _emailCtrl.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final navigator = NavigationService.of(context);

    return Scaffold(
      body: BlocListener<ForgotPasswordBloc,
          ForgotPasswordState>(
        listener: (context, state) {
          switch (state) {
            case ForgotPasswordOTPSent():
              navigator.navigateTo(
                Routes.forgotPasswordOtp,
                _emailCtrl.text.trim(),
              );
            case ForgotPasswordFailure(:final message):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            case ForgotPasswordInitial():
            case ForgotPasswordInProgress():
            case ForgotPasswordOTPVerifiedState():
            case ForgotPasswordSuccess():
              break;
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AuthGradientHeader(
                title: 'Quên mật khẩu',
                subtitle:
                    'Nhập email để nhận mã xác thực',
                showBackButton: true,
              ),
              AuthFormCard(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24, 32, 24, 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        AuthTextField(
                          controller: _emailCtrl,
                          label: 'Email',
                          hint: 'you@example.com',
                          keyboardType:
                              TextInputType.emailAddress,
                          textInputAction:
                              TextInputAction.done,
                          validator: (v) {
                            if (v == null ||
                                v.trim().isEmpty) {
                              return 'Vui lòng nhập email';
                            }
                            if (!v.contains('@')) {
                              return 'Email không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<ForgotPasswordBloc,
                            ForgotPasswordState>(
                          builder: (context, state) {
                            return AuthButton(
                              label: 'Gửi OTP',
                              isLoading: state
                                  is ForgotPasswordInProgress,
                              onPressed: _onSubmit,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
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
