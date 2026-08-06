import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/features/auth/bloc/auth_animation_cubit.dart';
import 'package:study/features/auth/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:study/features/auth/presentation/utils/validators.dart';
import 'package:study/features/auth/presentation/widgets/auth_animations.dart';
import 'package:study/features/auth/presentation/widgets/auth_button.dart';
import 'package:study/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:study/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:study/features/auth/presentation/widgets/login_bear.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/routes/router.dart';
import 'package:study/theme/theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  late final ForgotPasswordBloc _forgotPasswordBloc;
  final _animCubit = AuthAnimationCubit();
  final _bearKey = GlobalKey<AuthBearState>();

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
    _emailCtrl.dispose();
    _emailFocus.dispose();
    _forgotPasswordBloc.close();
    _animCubit.close();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    _forgotPasswordBloc.add(
      ForgotPasswordSubmitted(email: _emailCtrl.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigator = NavigationService.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

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
                padding: EdgeInsets.only(bottom: AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, 40),
                      child: AuthBear(
                        key: _bearKey,
                        emailFocus: _emailFocus,
                        emailController: _emailCtrl,
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
                                  l10n.forgotPasswordTitle,
                                  style: tt.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: AppSpacing.xs + 2),
                                Text(
                                  l10n.forgotPasswordSubtitle,
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
                              label: l10n.emailLabel,
                              hint: l10n.emailHint,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              validator: AuthValidators.email,
                            ),
                            AppSpacing.vGap4,
                            BlocBuilder<
                              ForgotPasswordBloc,
                              ForgotPasswordState
                            >(
                              builder: (context, state) {
                                return AuthButton(
                                  label: l10n.sendResetCode,
                                  isLoading: state is ForgotPasswordInProgress,
                                  onPressed: _onSubmit,
                                );
                              },
                            ),
                            AppSpacing.vGap4,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${l10n.cancel} ',
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Text(
                                    l10n.login,
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
