import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/bloc/auth_animation_cubit.dart';
import 'package:study/features/auth/bloc/login/login_bloc.dart';
import 'package:study/features/auth/presentation/utils/validators.dart';
import 'package:study/features/auth/presentation/widgets/auth_animations.dart';
import 'package:study/features/auth/presentation/widgets/auth_button.dart';
import 'package:study/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:study/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:study/features/auth/presentation/widgets/login_bear.dart';
import 'package:study/routes/router.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  // Small delay to let AuthBloc process the event
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (!mounted) return;
                    navigator.pushAndRemoveAll(Routes.app);
                  });
                });
              case LoginNeedsRoleSelection(:final sessionToken, :final roles):
                anim.succeed();
                _bearKey.currentState?.triggerSuccess();
                Future.delayed(const Duration(milliseconds: 600), () {
                  if (!mounted) return;
                  navigator.navigateTo(Routes.loginRolePicker, {
                    'sessionToken': sessionToken,
                    'roles': roles,
                  });
                });
              case LoginNeedsRoleRegistration(:final sessionToken):
                anim.succeed();
                // TODO: Navigate to role registration screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bạn chưa có vai trò, vui lòng đăng ký'),
                  ),
                );
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
                          spacing: 12,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Đăng nhập',
                                  style: tt.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Chào mừng bạn quay lại',
                                  style: tt.bodyMedium?.copyWith(
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
                              validator: AuthValidators.email,
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
                                  validator: AuthValidators.password,
                                ),
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
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Chưa có tài khoản? ',
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      navigator.navigateTo(Routes.selectRole),
                                  child: Text(
                                    'Đăng ký',
                                    style: TextStyle(
                                      color: cs.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // OAuth divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: cs.outlineVariant),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    'hoặc',
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: cs.outlineVariant),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // OAuth buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _OAuthButton(
                                  provider: 'google',
                                  onTap: () => _loginWithOAuth('google'),
                                ),
                                const SizedBox(width: 12),
                                _OAuthButton(
                                  provider: 'facebook',
                                  onTap: () => _loginWithOAuth('facebook'),
                                ),
                                const SizedBox(width: 12),
                                _OAuthButton(
                                  provider: 'github',
                                  onTap: () => _loginWithOAuth('github'),
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

  Future<void> _loginWithOAuth(String provider) async {
    final providerName = _getProviderName(provider);
    final baseUrl = dotenv.get('BASE_URL', fallback: '');

    // Check if running on localhost (dev environment)
    if (baseUrl.contains('127.0.0.1') || baseUrl.contains('localhost')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đăng nhập bằng $providerName chỉ khả dụng trên môi trường production',
          ),
        ),
      );
      return;
    }

    try {
      if (baseUrl.isEmpty) {
        throw Exception('Server chưa được cấu hình');
      }

      // OAuth endpoint: GET /api/auth/oauth/:provider
      final oauthUrl = '$baseUrl/api/auth/oauth/$provider';
      final uri = Uri.parse(oauthUrl);

      // Open URL in browser - backend will redirect to OAuth provider
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Không thể mở trình duyệt');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể đăng nhập bằng $providerName'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  String _getProviderName(String provider) {
    return switch (provider.toLowerCase()) {
      'google' => 'Google',
      'facebook' => 'Facebook',
      'github' => 'GitHub',
      _ => provider,
    };
  }
}

class _OAuthButton extends StatelessWidget {
  const _OAuthButton({
    required this.provider,
    required this.onTap,
  });

  final String provider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Icon(
          _getProviderIcon(provider),
          color: _getProviderColor(provider),
          size: 24,
        ),
      ),
    );
  }

  IconData _getProviderIcon(String provider) {
    return switch (provider.toLowerCase()) {
      'google' => Icons.g_mobiledata,
      'facebook' => Icons.facebook,
      'github' => Icons.code,
      _ => Icons.link,
    };
  }

  Color _getProviderColor(String provider) {
    return switch (provider.toLowerCase()) {
      'google' => const Color(0xFFDB4437),
      'facebook' => const Color(0xFF4267B2),
      'github' => const Color(0xFF333333),
      _ => Colors.grey,
    };
  }
}
