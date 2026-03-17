import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/bloc/auth_animation_cubit.dart';
import 'package:study/features/auth/bloc/login/login_bloc.dart';
import 'package:study/features/auth/presentation/widgets/auth_animations.dart';
import 'package:study/features/auth/presentation/widgets/auth_button.dart';
import 'package:study/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:study/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:study/features/auth/presentation/widgets/login_bear.dart';
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
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _animCubit = AuthAnimationCubit();
  final _bearKey = GlobalKey<AuthBearState>();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _animCubit.startEntrance();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _animCubit.close();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<LoginBloc>().add(
      LoginSubmitted(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigator = NavigationService.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocProvider.value(
      value: _animCubit,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            final anim = context.read<AuthAnimationCubit>();
            switch (state) {
              case LoginInProgress():
                anim.submit();
              case LoginSuccess(:final response):
                anim.succeed();
                _bearKey.currentState?.triggerSuccess();
                Future.delayed(const Duration(milliseconds: 800), () {
                  if (!mounted) return;
                  context.read<AuthBloc>().add(AuthLoggedIn(response));
                  navigator.pushAndRemoveAll(Routes.app);
                });
              case LoginNeedRole():
                anim.entranceComplete();
                navigator.navigateTo(Routes.selectRole, state);
              case LoginNeedOrg():
                anim.entranceComplete();
                navigator.navigateTo(Routes.selectOrg, state);
              case LoginFailure(:final message):
                anim.fail();
                _bearKey.currentState?.triggerFail();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              case LoginInitial():
                break;
            }
          },
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, 40),
                      child: AuthBear(
                        key: _bearKey,
                        emailFocus: _emailFocus,
                        passwordFocusNodes: [_passwordFocus],
                        emailController: _emailCtrl,
                      ),
                    ),
                    AuthFormCard(
                      child: Form(
                        key: _formKey,
                        child: StaggeredColumn(
                          animate: false,
                          spacing: 16,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Đăng nhập',
                                  style: tt.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Chào mừng bạn quay lại',
                                  style: tt.bodyLarge?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            AuthTextField(
                              controller: _emailCtrl,
                              focusNode: _emailFocus,
                              label: 'Email',
                              hint: 'Nhập email của bạn',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                AuthTextField(
                                  controller: _passwordCtrl,
                                  focusNode: _passwordFocus,
                                  label: 'Mật khẩu',
                                  hint: 'Nhập mật khẩu',
                                  textInputAction: TextInputAction.done,
                                  isObscured: _obscure,
                                  onToggleObscure: () {
                                    setState(() => _obscure = !_obscure);
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
                                TextButton(
                                  onPressed: () => navigator.navigateTo(
                                    Routes.forgotPassword,
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Quên mật khẩu?',
                                    style: TextStyle(
                                      color: cs.primary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            BlocBuilder<LoginBloc, LoginState>(
                              builder: (context, loginState) {
                                return BlocBuilder<
                                  AuthAnimationCubit,
                                  AuthAnimationState
                                >(
                                  builder: (context, animState) {
                                    return AuthButton(
                                      label: 'Đăng nhập',
                                      isLoading: loginState is LoginInProgress,
                                      isSuccess:
                                          animState.status ==
                                          AuthScreenAnimStatus.success,
                                      onPressed: _onSubmit,
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Chưa có tài khoản? ',
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      navigator.navigateTo(Routes.register),
                                  child: Text(
                                    'Đăng ký',
                                    style: TextStyle(
                                      color: cs.primary,
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
