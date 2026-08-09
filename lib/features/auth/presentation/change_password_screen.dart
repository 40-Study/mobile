import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/security/security_cubit.dart';
import 'package:study/features/auth/bloc/security/security_state.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late final SecurityCubit _cubit;
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _revokeOthers = false;

  @override
  void initState() {
    super.initState();
    _cubit = SecurityCubit(authRepository: context.read<AuthRepository>());
  }

  @override
  void dispose() {
    _cubit.close();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: cs.surfaceContainerLowest,
        appBar: AppBar(
          backgroundColor: cs.surfaceContainerLowest,
          title: Text(l10n.changePasswordTitle),
        ),
        body: BlocConsumer<SecurityCubit, SecurityState>(
          listener: (context, state) {
            if (state is SecurityPasswordChanged) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.changePasswordButton),
                  backgroundColor: cs.primary,
                ),
              );
              Navigator.pop(context);
            }
            if (state is SecurityFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: cs.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is SecurityChangingPassword;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Info card
                          Container(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: cs.primary),
                                AppSpacing.hGap12,
                                Expanded(
                                  child: Text(
                                    'Nên sử dụng mật khẩu mạnh mà bạn không '
                                    'dùng ở nơi khác',
                                    style: tt.bodySmall?.copyWith(
                                      color: cs.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppSpacing.vGap24,

                          // Old password
                          _buildLabel(l10n.currentPasswordLabel),
                          AppSpacing.vGap8,
                          _buildPasswordField(
                            controller: _oldPasswordController,
                            hint: l10n.passwordHint,
                            obscure: _obscureOld,
                            onToggle: () =>
                                setState(() => _obscureOld = !_obscureOld),
                            enabled: !isLoading,
                          ),
                          SizedBox(height: AppSpacing.xl - 4),

                          // New password
                          _buildLabel(l10n.newPasswordLabel),
                          AppSpacing.vGap8,
                          _buildPasswordField(
                            controller: _newPasswordController,
                            hint: l10n.newPasswordHint,
                            obscure: _obscureNew,
                            onToggle: () =>
                                setState(() => _obscureNew = !_obscureNew),
                            enabled: !isLoading,
                            validator: (value) {
                              if (value == null || value.length < 8) {
                                return l10n.errorPasswordTooShort;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.xl - 4),

                          // Confirm password
                          _buildLabel(l10n.confirmPasswordLabel),
                          AppSpacing.vGap8,
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            hint: l10n.confirmPasswordHint,
                            obscure: _obscureConfirm,
                            onToggle: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                            enabled: !isLoading,
                            validator: (value) {
                              if (value != _newPasswordController.text) {
                                return l10n.errorPasswordMismatch;
                              }
                              return null;
                            },
                          ),
                          AppSpacing.vGap16,

                          // Revoke others checkbox
                          CheckboxListTile(
                            value: _revokeOthers,
                            onChanged: isLoading
                                ? null
                                : (value) =>
                                      setState(() => _revokeOthers = value!),
                            title: Text(
                              'Đăng xuất khỏi các thiết bị khác',
                              style: tt.bodyMedium,
                            ),
                            subtitle: Text(
                              'Tất cả các phiên đăng nhập khác sẽ bị đăng xuất',
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Save button
                Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLoading ? null : _changePassword,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderMd,
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.onPrimary,
                              ),
                            )
                          : Text(
                              l10n.changePasswordButton,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: cs.onSurface,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: cs.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg - 2,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: cs.onSurfaceVariant,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  void _changePassword() {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_oldPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorRequired)),
      );
      return;
    }

    _cubit.changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
      deviceInfo: DeviceInfoModel.generate(),
      revokeOthers: _revokeOthers,
    );
  }
}
