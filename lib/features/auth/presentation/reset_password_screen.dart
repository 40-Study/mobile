import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth_animation_cubit.dart';
import 'package:study/features/auth/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:study/features/auth/presentation/utils/validators.dart';
import 'package:study/features/auth/presentation/widgets/auth_animated_submit_button.dart';
import 'package:study/features/auth/presentation/widgets/auth_animations.dart';
import 'package:study/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:study/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:study/features/auth/presentation/widgets/login_bear.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/routes/router.dart';
import 'package:study/theme/theme.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  late final ForgotPasswordBloc _forgotPasswordBloc;
  final _animCubit = AuthAnimationCubit();
  final _bearKey = GlobalKey<AuthBearState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _forgotPasswordBloc = ForgotPasswordBloc(
      authRepository: context.read<AuthRepository>(),
    );
    _animCubit.startEntrance();
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _forgotPasswordBloc.close();
    _animCubit.close();
    super.dispose();
  }

  void _onSubmit(String email, String otp) {
    if (!_formKey.currentState!.validate()) return;
    _forgotPasswordBloc.add(
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
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    final email = args['email'] as String? ?? '';
    final otp = args['otp'] as String? ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _forgotPasswordBloc),
        BlocProvider.value(value: _animCubit),
      ],
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
                    SnackBar(
                      content: Text(l10n.resetPasswordButton),
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
                padding: EdgeInsets.only(bottom: AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, 40),
                      child: AuthBear(
                        key: _bearKey,
                        passwordFocusNodes: [_passwordFocus, _confirmFocus],
                      ),
                    ),
                    AuthFormCard(
                      child: Form(
                        key: _formKey,
                        child: StaggeredColumn(
                          animate: _animCubit.state.shouldAnimate,
                          spacing: 20,
                          onComplete: _animCubit.entranceComplete,
                          children: [
                            Column(
                              children: [
                                Text(
                                  l10n.resetPasswordTitle,
                                  style: tt.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: AppSpacing.xs + 2),
                                Text(
                                  l10n.newPasswordHint,
                                  style: tt.bodyLarge?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            AuthTextField(
                              controller: _passwordCtrl,
                              focusNode: _passwordFocus,
                              label: l10n.newPasswordLabel,
                              textInputAction: TextInputAction.next,
                              isObscured: _obscurePassword,
                              onToggleObscure: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                              validator: AuthValidators.password,
                            ),
                            AuthTextField(
                              controller: _confirmCtrl,
                              focusNode: _confirmFocus,
                              label: l10n.confirmPasswordLabel,
                              textInputAction: TextInputAction.done,
                              isObscured: _obscureConfirm,
                              onToggleObscure: () {
                                setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                );
                              },
                              validator: AuthValidators.confirmPassword(
                                _passwordCtrl.text,
                              ),
                            ),
                            AppSpacing.vGap4,
                            AuthAnimatedSubmitButton<
                              ForgotPasswordBloc,
                              ForgotPasswordState
                            >(
                              label: l10n.resetPasswordButton,
                              isLoading: (state) =>
                                  state is ForgotPasswordInProgress,
                              onPressed: () => _onSubmit(email, otp),
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
