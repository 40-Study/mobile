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

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
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
  int _currentStep = 0;
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
    _pageController.dispose();
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

  void _goToStep2() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = 1);
  }

  void _goToStep1() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = 0);
  }

  void _onSubmit() {
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
            onPressed: () {
              if (_currentStep == 1) {
                _goToStep1();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: _StepIndicator(currentStep: _currentStep),
          centerTitle: true,
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
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [_buildStep1(cs, tt), _buildStep2(cs, tt)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(ColorScheme cs, TextTheme tt) {
    return Center(
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
                emailController: _emailCtrl,
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
                        if (!v.contains('@')) return 'Email không hợp lệ';
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
                    AuthTextField(
                      controller: _passwordCtrl,
                      focusNode: _passwordFocus,
                      label: 'Mật khẩu',
                      hint: 'Tạo mật khẩu',
                      textInputAction: TextInputAction.next,
                      isObscured: _obscurePassword,
                      onToggleObscure: () {
                        setState(() => _obscurePassword = !_obscurePassword);
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
                        setState(() => _obscureConfirm = !_obscureConfirm);
                      },
                      validator: (v) {
                        if (v != _passwordCtrl.text) {
                          return 'Mật khẩu không khớp';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 4),
                    AuthButton(label: 'Tiếp tục', onPressed: _goToStep2),
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
    );
  }

  Widget _buildStep2(ColorScheme cs, TextTheme tt) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: const Offset(0, 40),
              child: const AuthBear(size: 300),
            ),
            AuthFormCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Chọn vai trò',
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bạn có thể chọn nhiều vai trò',
                    style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_roles.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    ..._roles.map((role) {
                      final selected = _selectedRoleIds.contains(role.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RoleTile(
                          icon: _roleIcon(role.name),
                          label: _roleLabel(role.name),
                          selected: selected,
                          onTap: () {
                            setState(() {
                              if (selected) {
                                _selectedRoleIds.remove(role.id);
                              } else {
                                _selectedRoleIds.add(role.id);
                              }
                            });
                          },
                        ),
                      );
                    }),
                  const SizedBox(height: 8),
                  BlocBuilder<RegisterBloc, RegisterState>(
                    builder: (context, state) {
                      return AuthButton(
                        label: 'Đăng ký',
                        isLoading: state is RegisterInProgress,
                        onPressed: _onSubmit,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _goToStep1,
                    child: Text(
                      'Quay lại chỉnh sửa thông tin',
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step indicator
// ---------------------------------------------------------------------------

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final progress = (currentStep + 1) / 2;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Bước ${currentStep + 1}/2',
          style: tt.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: progress),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: cs.outlineVariant.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation(cs.primary),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Role tile (multi-select card style)
// ---------------------------------------------------------------------------

IconData _roleIcon(String roleName) {
  switch (roleName.toUpperCase()) {
    case 'STUDENT':
      return Icons.school_outlined;
    case 'TEACHER':
      return Icons.person_outlined;
    case 'PARENT':
      return Icons.family_restroom_outlined;
    case 'ORG_OWNER':
      return Icons.business_outlined;
    default:
      return Icons.badge_outlined;
  }
}

String _roleLabel(String roleName) {
  switch (roleName.toUpperCase()) {
    case 'STUDENT':
      return 'Học sinh';
    case 'TEACHER':
      return 'Giáo viên';
    case 'PARENT':
      return 'Phụ huynh';
    case 'ORG_OWNER':
      return 'Chủ tổ chức';
    default:
      return roleName;
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? cs.primary.withValues(alpha: 0.08)
          : cs.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? cs.primary : cs.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (selected ? cs.primary : cs.onSurface).withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: selected ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? cs.primary : cs.onSurface,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: selected
                    ? Icon(
                        Icons.check_circle_rounded,
                        key: const ValueKey('checked'),
                        color: cs.primary,
                        size: 24,
                      )
                    : Icon(
                        Icons.radio_button_unchecked,
                        key: const ValueKey('unchecked'),
                        color: cs.outlineVariant,
                        size: 24,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
