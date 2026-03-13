import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/bloc/login/login_bloc.dart';
import 'package:study/features/auth/presentation/widgets/auth_button.dart';
import 'package:study/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:study/features/auth/presentation/widgets/auth_gradient_header.dart';
import 'package:study/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:study/routes/router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<LoginBloc>().add(LoginSubmitted(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final navigator = NavigationService.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          switch (state) {
            case LoginSuccess(:final response):
              context
                  .read<AuthBloc>()
                  .add(AuthLoggedIn(response));
              navigator.pushAndRemoveAll(Routes.app);
            case LoginNeedRole():
              navigator.navigateTo(
                Routes.selectRole,
                state,
              );
            case LoginNeedOrg():
              navigator.navigateTo(
                Routes.selectOrg,
                state,
              );
            case LoginFailure(:final message):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            case LoginInitial():
            case LoginInProgress():
              break;
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AuthGradientHeader(
                title: 'Đăng nhập',
                subtitle:
                    'Chào mừng bạn quay lại',
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
                              TextInputAction.next,
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
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _passwordCtrl,
                          label: 'Mật khẩu',
                          textInputAction:
                              TextInputAction.done,
                          isObscured: _obscure,
                          onToggleObscure: () {
                            setState(
                              () => _obscure = !_obscure,
                            );
                          },
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Vui lòng nhập mật khẩu';
                            }
                            if (v.length < 8) {
                              return 'Tối thiểu 8 ký tự';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment:
                              Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                navigator.navigateTo(
                              Routes.forgotPassword,
                            ),
                            child: Text(
                              'Quên mật khẩu?',
                              style: TextStyle(
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<LoginBloc,
                            LoginState>(
                          builder: (context, state) {
                            return AuthButton(
                              label: 'Đăng nhập',
                              isLoading: state
                                  is LoginInProgress,
                              onPressed: _onSubmit,
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              'Chưa có tài khoản? ',
                              style: TextStyle(
                                color:
                                    cs.onSurfaceVariant,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  navigator.navigateTo(
                                Routes.register,
                              ),
                              child: Text(
                                'Đăng ký',
                                style: TextStyle(
                                  color: cs.primary,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
