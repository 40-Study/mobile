import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/features/auth/bloc/auth_animation_cubit.dart';
import 'package:study/features/auth/bloc/register/register_bloc.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/utils/role_utils.dart';
import 'package:study/features/auth/presentation/utils/validators.dart';
import 'package:study/features/auth/presentation/widgets/auth_animations.dart';
import 'package:study/features/auth/presentation/widgets/auth_button.dart';
import 'package:study/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:study/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:study/features/auth/presentation/widgets/login_bear.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/routes/router.dart';
import 'package:study/theme/theme.dart';

class RegisterFormScreen extends StatefulWidget {
  const RegisterFormScreen({super.key});

  @override
  State<RegisterFormScreen> createState() => _RegisterFormScreenState();
}

class _RegisterFormScreenState extends State<RegisterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _userNameCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  late final RegisterBloc _registerBloc;
  final _animCubit = AuthAnimationCubit();
  final _bearKey = GlobalKey<AuthBearState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  RoleModel? _selectedRole;

  @override
  void initState() {
    super.initState();
    _registerBloc = RegisterBloc(
      authRepository: context.read<AuthRepository>(),
    );
    _animCubit.startEntrance();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get role from navigation arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && _selectedRole == null) {
      _selectedRole = args['role'] as RoleModel?;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _userNameCtrl.dispose();
    _fullNameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _registerBloc.close();
    _animCubit.close();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng quay lại chọn vai trò')),
      );
      return;
    }

    _registerBloc.add(
      RegisterSubmitted(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        confirmPassword: _confirmCtrl.text,
        userName: _userNameCtrl.text.trim(),
        fullName: _fullNameCtrl.text.trim().isNotEmpty
            ? _fullNameCtrl.text.trim()
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigator = NavigationService.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    if (_selectedRole == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.errorRequired),
              AppSpacing.vGap16,
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
      );
    }

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
              case RegisterOTPSent():
                anim.entranceComplete();
                navigator.navigateTo(Routes.registerOtp, {
                  'email': _emailCtrl.text.trim(),
                  'password': _passwordCtrl.text,
                  'confirmPassword': _confirmCtrl.text,
                  'userName': _userNameCtrl.text.trim(),
                  'fullName': _fullNameCtrl.text.trim(),
                });
              case RegisterFailure(:final message):
                anim.fail();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              case RegisterInitial():
              case RegisterSuccess():
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
                        emailController: _emailCtrl,
                      ),
                    ),
                    AuthFormCard(
                      child: Form(
                        key: _formKey,
                        child: StaggeredColumn(
                          animate: _animCubit.state.shouldAnimate,
                          spacing: 16,
                          onComplete: _animCubit.entranceComplete,
                          children: [
                            Column(
                              children: [
                                Text(
                                  l10n.registerTitle,
                                  style: tt.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: AppSpacing.xs + 2),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.xs + 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    RoleUtils.getLabel(_selectedRole!.name),
                                    style: TextStyle(
                                      color: cs.onPrimaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            AuthTextField(
                              controller: _emailCtrl,
                              label: l10n.emailLabel,
                              hint: l10n.emailHint,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: AuthValidators.email,
                            ),
                            AuthTextField(
                              controller: _userNameCtrl,
                              label: l10n.usernameLabel,
                              textInputAction: TextInputAction.next,
                              validator: AuthValidators.username,
                            ),
                            AuthTextField(
                              controller: _fullNameCtrl,
                              label: l10n.fullNameLabel,
                              textInputAction: TextInputAction.next,
                            ),
                            AuthTextField(
                              controller: _passwordCtrl,
                              focusNode: _passwordFocus,
                              label: l10n.passwordLabel,
                              hint: l10n.passwordHint,
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
                            BlocBuilder<RegisterBloc, RegisterState>(
                              builder: (context, state) {
                                return AuthButton(
                                  label: l10n.registerButton,
                                  isLoading: state is RegisterInProgress,
                                  onPressed: _onSubmit,
                                );
                              },
                            ),
                            AppSpacing.vGap4,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${l10n.alreadyHaveAccount} ',
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      navigator.pushAndRemoveAll(Routes.login),
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
