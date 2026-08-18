import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/durations.dart';
import 'package:study/features/auth/bloc/auth_animation_cubit.dart';
import 'package:study/features/auth/bloc/register/register_bloc.dart';
import 'package:study/features/auth/presentation/utils/otp_countdown_mixin.dart';
import 'package:study/features/auth/presentation/widgets/auth_animated_submit_button.dart';
import 'package:study/features/auth/presentation/widgets/auth_animations.dart';
import 'package:study/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:study/features/auth/presentation/widgets/login_bear.dart';
import 'package:study/features/auth/presentation/widgets/otp_boxes.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/routes/router.dart';
import 'package:study/theme/theme.dart';

class RegisterOtpScreen extends StatefulWidget {
  const RegisterOtpScreen({super.key});

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen>
    with OtpCountdownMixin {
  final _otpKey = GlobalKey<OtpBoxesState>();
  late final RegisterBloc _registerBloc;
  final _animCubit = AuthAnimationCubit();
  final _bearKey = GlobalKey<AuthBearState>();
  String _otp = '';

  @override
  void initState() {
    super.initState();
    _registerBloc = RegisterBloc(
      authRepository: context.read<AuthRepository>(),
    );
    _animCubit.startEntrance();
    startCountdown();
  }

  @override
  void dispose() {
    _registerBloc.close();
    _animCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigator = NavigationService.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is! Map<String, dynamic>) {
      return Scaffold(body: Center(child: Text(l10n.errorUnknown)));
    }

    final email = args['email'] as String;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _registerBloc),
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
        body: BlocListener<RegisterBloc, RegisterState>(
          listener: (context, state) {
            final anim = context.read<AuthAnimationCubit>();
            switch (state) {
              case RegisterInProgress():
                anim.submit();
              case RegisterSuccess():
                anim.succeed();
                Future.delayed(AppDurations.authRegisterSuccess, () {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.registerButton),
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
                ).showSnackBar(SnackBar(content: Text(l10n.resendOtp)));
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
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
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
                                l10n.otpTitle,
                                style: tt.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.xs + 2),
                              Text(
                                l10n.otpSubtitle(email),
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
                                color: isCountdownActive
                                    ? cs.primary
                                    : cs.error,
                              ),
                            ),
                          ),
                          AppSpacing.vGap4,
                          AuthAnimatedSubmitButton<RegisterBloc, RegisterState>(
                            label: l10n.verifyButton,
                            isLoading: (state) => state is RegisterInProgress,
                            onPressed: () {
                              context.read<RegisterBloc>().add(
                                RegisterOTPSubmitted(email: email, otp: _otp),
                              );
                            },
                          ),
                          AppSpacing.vGap4,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${l10n.resendOtp}? ',
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
                                            fullName:
                                                args['fullName'] as String?,
                                          ),
                                        );
                                      },
                                child: Text(
                                  isCountdownActive
                                      ? l10n.resendOtpIn(countdownText)
                                      : l10n.resendOtp,
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
