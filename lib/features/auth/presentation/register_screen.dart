import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth_animation_cubit.dart';
import 'package:study/features/auth/bloc/register/register_bloc.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/widgets/auth_animations.dart';
import 'package:study/features/auth/presentation/widgets/auth_button.dart';
import 'package:study/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:study/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:study/features/auth/presentation/widgets/login_bear.dart';
import 'package:study/routes/router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

IconData _roleIcon(String roleName) {
  switch (roleName.toUpperCase()) {
    case 'STUDENT':
      return Icons.school_outlined;
    case 'TEACHER':
      return Icons.person_outlined;
    case 'PARENT':
      return Icons.family_restroom;
    case 'ORG_OWNER':
      return Icons.business_outlined;
    default:
      return Icons.badge_outlined;
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _userNameCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  final _animCubit = AuthAnimationCubit();
  final _bearKey = GlobalKey<AuthBearState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  final Set<String> _selectedRoleIds = {};
  List<RoleModel> _roles = [];

  @override
  void initState() {
    super.initState();
    _animCubit.startEntrance();
    context.read<RegisterBloc>().add(const RegisterRolesRequested());
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
    _animCubit.close();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoleIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 vai trò')),
      );
      return;
    }
    context.read<RegisterBloc>().add(
      RegisterSubmitted(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        confirmPassword: _confirmCtrl.text,
        userName: _userNameCtrl.text.trim(),
        fullName: _fullNameCtrl.text.trim().isNotEmpty
            ? _fullNameCtrl.text.trim()
            : null,
        roleIds: _selectedRoleIds.toList(),
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
              case RegisterRolesLoaded(:final roles):
                setState(() => _roles = roles);
              case RegisterRolesFailure(:final message):
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Không tải được vai trò: $message')),
                );
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
                  'roleIds': _selectedRoleIds.toList(),
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
                padding: const EdgeInsets.only(bottom: 16),
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
                          spacing: 18,
                          onComplete: _animCubit.entranceComplete,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Đăng ký tài khoản',
                                  style: tt.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Điền thông tin của bạn',
                                  style: tt.bodyLarge?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            AuthTextField(
                              controller: _emailCtrl,
                              label: 'Email',
                              hint: 'example@email.com',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Vui lòng nhập email';
                                }
                                if (!v.contains('@'))
                                  return 'Email không hợp lệ';
                                return null;
                              },
                            ),
                            AuthTextField(
                              controller: _userNameCtrl,
                              label: 'Tên đăng nhập',
                              textInputAction: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Vui lòng nhập tên đăng nhập';
                                }
                                if (v.trim().length < 3) {
                                  return 'Tối thiểu 3 ký tự';
                                }
                                return null;
                              },
                            ),
                            AuthTextField(
                              controller: _fullNameCtrl,
                              label: 'Họ tên (tuỳ chọn)',
                              textInputAction: TextInputAction.next,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vai trò',
                                  style: tt.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (_roles.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _roles.map((role) {
                                      final selected = _selectedRoleIds
                                          .contains(role.id);
                                      return FilterChip(
                                        avatar: Icon(
                                          _roleIcon(role.name),
                                          size: 18,
                                          color: selected
                                              ? cs.onPrimary
                                              : cs.primary,
                                        ),
                                        label: Text(role.name),
                                        selected: selected,
                                        selectedColor: cs.primary,
                                        checkmarkColor: cs.onPrimary,
                                        labelStyle: TextStyle(
                                          color: selected
                                              ? cs.onPrimary
                                              : cs.onSurface,
                                          fontWeight: selected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                        side: BorderSide(
                                          color: selected
                                              ? cs.primary
                                              : cs.outline,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        onSelected: (v) {
                                          setState(() {
                                            if (v) {
                                              _selectedRoleIds.add(role.id);
                                            } else {
                                              _selectedRoleIds.remove(role.id);
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                            AuthTextField(
                              controller: _passwordCtrl,
                              focusNode: _passwordFocus,
                              label: 'Mật khẩu',
                              hint: 'Tạo mật khẩu',
                              textInputAction: TextInputAction.next,
                              isObscured: _obscurePassword,
                              onToggleObscure: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu';
                                }
                                if (v.length < 8) return 'Tối thiểu 8 ký tự';
                                return null;
                              },
                            ),
                            AuthTextField(
                              controller: _confirmCtrl,
                              focusNode: _confirmFocus,
                              label: 'Xác nhận mật khẩu',
                              textInputAction: TextInputAction.done,
                              isObscured: _obscureConfirm,
                              onToggleObscure: () {
                                setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                );
                              },
                              validator: (v) {
                                if (v != _passwordCtrl.text) {
                                  return 'Mật khẩu không khớp';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 4),
                            BlocBuilder<RegisterBloc, RegisterState>(
                              builder: (context, state) {
                                return AuthButton(
                                  label: 'Tiếp tục',
                                  isLoading: state is RegisterInProgress,
                                  onPressed: _onSubmit,
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Đã có tài khoản? ',
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Text(
                                    'Đăng nhập',
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
