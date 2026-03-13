import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:study/features/auth/presentation/widgets/auth_button.dart';
import 'package:study/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:study/features/auth/presentation/widgets/auth_gradient_header.dart';
import 'package:study/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:study/routes/router.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
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
    final args = ModalRoute.of(context)
            ?.settings
            .arguments as Map<String, dynamic>? ??
        {};
    final email = args['email'] as String? ?? '';
    final otp = args['otp'] as String? ?? '';

    return Scaffold(
      body: BlocListener<ForgotPasswordBloc,
          ForgotPasswordState>(
        listener: (context, state) {
          switch (state) {
            case ForgotPasswordSuccess():
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'Đặt lại mật khẩu thành công!',
                  ),
                ),
              );
              navigator
                  .pushAndRemoveAll(Routes.login);
            case ForgotPasswordFailure(
                :final message,
              ):
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                SnackBar(content: Text(message)),
              );
            case ForgotPasswordInitial():
            case ForgotPasswordInProgress():
            case ForgotPasswordOTPSent():
            case ForgotPasswordOTPVerifiedState():
              break;
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AuthGradientHeader(
                title: 'Đặt mật khẩu mới',
                subtitle:
                    'Nhập mật khẩu mới cho tài khoản',
                showBackButton: true,
              ),
              AuthFormCard(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    24, 32, 24, 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        AuthTextField(
                          controller: _passwordCtrl,
                          label: 'Mật khẩu mới',
                          textInputAction:
                              TextInputAction.next,
                          isObscured:
                              _obscurePassword,
                          onToggleObscure: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                          validator: (v) {
                            if (v == null ||
                                v.isEmpty) {
                              return 'Vui lòng nhập mật khẩu';
                            }
                            if (v.length < 8) {
                              return 'Tối thiểu 8 ký tự';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _confirmCtrl,
                          label:
                              'Xác nhận mật khẩu',
                          textInputAction:
                              TextInputAction.done,
                          isObscured:
                              _obscureConfirm,
                          onToggleObscure: () {
                            setState(() {
                              _obscureConfirm =
                                  !_obscureConfirm;
                            });
                          },
                          validator: (v) {
                            if (v !=
                                _passwordCtrl
                                    .text) {
                              return 'Mật khẩu không khớp';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<
                            ForgotPasswordBloc,
                            ForgotPasswordState>(
                          builder:
                              (context, state) {
                            return AuthButton(
                              label:
                                  'Đặt lại mật khẩu',
                              isLoading: state
                                  is ForgotPasswordInProgress,
                              onPressed: () =>
                                  _onSubmit(
                                email,
                                otp,
                              ),
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
