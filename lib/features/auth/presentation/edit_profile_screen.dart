import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/account/account_cubit.dart';
import 'package:study/features/auth/bloc/account/account_state.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late final TextEditingController _dobController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _dobController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _populateFields();
    });
  }

  void _populateFields() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      _nameController.text = user.fullName ?? user.username ?? '';
      _phoneController.text = user.phone ?? '';
      _dobController.text = user.dateOfBirth ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cs.surfaceContainerLowest,
        title: Text(l10n.editProfile),
        actions: [
          BlocBuilder<AccountCubit, AccountState>(
            builder: (context, state) {
              final isUpdating = state is AccountUpdating;
              return TextButton(
                onPressed: isUpdating ? null : _saveChanges,
                child: isUpdating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        l10n.saveChanges,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<AccountCubit, AccountState>(
        listener: (context, state) {
          if (state is AccountUpdateSuccess) {
            context.read<AuthBloc>().add(AuthUserUpdated(state.user));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.saveChanges),
                backgroundColor: cs.tertiary,
              ),
            );
            Navigator.pop(context);
          }
          if (state is AccountFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Section
                Center(
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      String? avatarUrl;
                      String initials = '?';

                      if (state is AuthAuthenticated) {
                        avatarUrl = state.user.avatarUrl;
                        final name = state.user.fullName ?? state.user.username ?? 'User';
                        initials = _getInitials(name);
                      }

                      return Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: cs.primaryContainer,
                                backgroundImage: avatarUrl != null
                                    ? NetworkImage(avatarUrl)
                                    : null,
                                child: avatarUrl == null
                                    ? Text(
                                        initials,
                                        style: tt.headlineMedium?.copyWith(
                                          color: cs.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: cs.surface,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.vGap12,
                          TextButton(
                            onPressed: () {},
                            child: Text(l10n.editProfile),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                AppSpacing.vGap24,

                // Form Fields
                _buildSectionTitle(l10n.profileTitle),
                AppSpacing.vGap16,

                _buildTextField(
                  controller: _nameController,
                  label: l10n.fullNameLabel,
                  hint: l10n.fullNameHint,
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.errorRequired;
                    }
                    return null;
                  },
                ),
                AppSpacing.vGap16,

                _buildTextField(
                  controller: _phoneController,
                  label: l10n.phoneLabel,
                  hint: l10n.phoneLabel,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                AppSpacing.vGap16,

                _buildTextField(
                  controller: _dobController,
                  label: l10n.dateOfBirthLabel,
                  hint: 'DD/MM/YYYY',
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: _selectDate,
                ),
                AppSpacing.vGap24,

                _buildSectionTitle(l10n.bioLabel),
                AppSpacing.vGap16,

                _buildTextField(
                  controller: _bioController,
                  label: l10n.bioLabel,
                  hint: l10n.bioLabel,
                  icon: Icons.edit_note,
                  maxLines: 4,
                ),
                AppSpacing.vGap32,

                // Email (readonly)
                _buildSectionTitle(l10n.emailLabel),
                AppSpacing.vGap16,

                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    String email = '';
                    if (state is AuthAuthenticated) {
                      email = state.user.email;
                    }
                    return _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: l10n.emailLabel,
                      value: email,
                      trailing: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: cs.tertiary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.confirm,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.tertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                AppSpacing.vGap32,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Text(
      title.toUpperCase(),
      style: tt.labelMedium?.copyWith(
        color: cs.onSurfaceVariant,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: cs.onSurfaceVariant),
        filled: true,
        fillColor: cs.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.onSurfaceVariant),
          AppSpacing.hGap16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                AppSpacing.vGap4,
                Text(
                  value,
                  style: tt.bodyLarge?.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      _dobController.text =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AccountCubit>().updateAccount(
          username: _nameController.text.trim(),
          phone: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          dateOfBirth: _dobController.text.trim().isNotEmpty
              ? _dobController.text.trim()
              : null,
        );
  }
}
