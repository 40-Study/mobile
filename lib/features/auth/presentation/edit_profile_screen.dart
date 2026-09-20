import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:study/features/auth/bloc/account/account_cubit.dart';
import 'package:study/features/auth/bloc/account/account_state.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/cached_avatar.dart';

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
  String? _pickedImagePath;

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
      _phoneController.text = _formatPhoneForDisplay(user.phone);
      if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) {
        try {
          _selectedDate = DateTime.parse(user.dateOfBirth!);
          final d = _selectedDate!;
          _dobController.text =
              '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
        } catch (_) {
          _dobController.text = user.dateOfBirth ?? '';
        }
      }
    }
  }

  String _formatPhoneForDisplay(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    if (phone.startsWith('+84')) {
      return '0${phone.substring(3)}';
    }
    return phone;
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // Soft background layer
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Container(color: cs.primary.withValues(alpha: 0.03)),
          ),
          // Decorative circles
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            top: 140,
            left: -70,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: 0.03),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: BlocListener<AccountCubit, AccountState>(
              listener: (context, state) {
                if (state is AccountUpdateSuccess) {
                  context.read<AuthBloc>().add(AuthUserUpdated(state.user));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.saveChanges),
                      backgroundColor: AchievementColors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderMd,
                      ),
                    ),
                  );
                  Navigator.pop(context);
                }
                if (state is AccountFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: cs.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderMd,
                      ),
                    ),
                  );
                }
              },
              child: CustomScrollView(
                slivers: [
                  // AppBar
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    pinned: true,
                    title: Text(l10n.editProfile),
                    actions: [
                      BlocBuilder<AccountCubit, AccountState>(
                        builder: (context, state) {
                          final isUpdating = state is AccountUpdating;
                          return Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.md),
                            child: FilledButton(
                              onPressed: isUpdating ? null : _saveChanges,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.sm,
                                ),
                              ),
                              child: isUpdating
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(l10n.saveChanges),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // Avatar Section
                  SliverToBoxAdapter(
                    child: _AvatarSection(
                      onChangePicture: _pickAndUploadImage,
                      pickedImagePath: _pickedImagePath,
                    ),
                  ),

                  const SliverToBoxAdapter(child: AppSpacing.vGap24),

                  // Form
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Personal Info Card
                            _FormSection(
                              title: l10n.profileTitle,
                              children: [
                                _PremiumTextField(
                                  controller: _nameController,
                                  label: l10n.fullNameLabel,
                                  hint: l10n.fullNameHint,
                                  icon: Icons.person_outline_rounded,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Vui lòng nhập họ tên';
                                    }
                                    if (value.trim().length < 2) {
                                      return 'Họ tên phải có ít nhất 2 ký tự';
                                    }
                                    return null;
                                  },
                                ),
                                AppSpacing.vGap16,
                                _PremiumTextField(
                                  controller: _phoneController,
                                  label: l10n.phoneLabel,
                                  hint: '0912 345 678',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return null; // Phone không bắt buộc
                                    }
                                    final digits = value.replaceAll(RegExp(r'\D'), '');
                                    if (digits.length < 10 || digits.length > 11) {
                                      return 'Số điện thoại phải có 10-11 số';
                                    }
                                    if (!digits.startsWith('0')) {
                                      return 'Số điện thoại phải bắt đầu bằng 0';
                                    }
                                    return null;
                                  },
                                ),
                                AppSpacing.vGap16,
                                _PremiumTextField(
                                  controller: _dobController,
                                  label: l10n.dateOfBirthLabel,
                                  hint: 'DD/MM/YYYY',
                                  icon: Icons.calendar_today_outlined,
                                  readOnly: true,
                                  onTap: _selectDate,
                                ),
                              ],
                            ),

                            AppSpacing.vGap24,

                            // Bio Card
                            _FormSection(
                              title: l10n.bioLabel,
                              children: [
                                _PremiumTextField(
                                  controller: _bioController,
                                  label: l10n.bioLabel,
                                  hint: l10n.bioHint,
                                  icon: Icons.edit_note_rounded,
                                  maxLines: 4,
                                ),
                              ],
                            ),

                            AppSpacing.vGap24,

                            // Email (readonly)
                            _FormSection(
                              title: l10n.emailLabel,
                              children: [
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    var email = '';
                                    if (state is AuthAuthenticated) {
                                      email = state.user.email;
                                    }
                                    return _EmailRow(email: email);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _selectedDate;

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      _selectedDate = date;
      _dobController.text =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  String? _formatDateForApi() {
    if (_selectedDate == null) return null;
    final d = _selectedDate!;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String? _formatPhoneForApi() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return null;
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) {
      return '+84${digits.substring(1)}';
    }
    if (digits.startsWith('84')) {
      return '+$digits';
    }
    return '+84$digits';
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512);
    if (picked == null) return;

    setState(() => _pickedImagePath = picked.path);
    if (!mounted) return;
    await context.read<AccountCubit>().updateAvatar(picked.path);
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AccountCubit>().updateAccount(
          fullName: _nameController.text.trim(),
          phone: _formatPhoneForApi(),
          dateOfBirth: _formatDateForApi(),
        );
  }
}

// ============================================================
// AVATAR SECTION
// ============================================================
class _AvatarSection extends StatelessWidget {
  const _AvatarSection({required this.onChangePicture, this.pickedImagePath});

  final VoidCallback onChangePicture;
  final String? pickedImagePath;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String? avatarUrl;
        var initials = '?';

        if (authState is AuthAuthenticated) {
          avatarUrl = authState.user.avatarUrl;
          final name = authState.user.fullName ?? authState.user.username ?? 'User';
          initials = _getInitials(name);
        }

        return BlocBuilder<AccountCubit, AccountState>(
          builder: (context, accountState) {
            final isUploading = accountState is AccountUpdating;

            return Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.15),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: pickedImagePath != null
                            ? Image.file(
                                File(pickedImagePath!),
                                width: 104,
                                height: 104,
                                fit: BoxFit.cover,
                              )
                            : CachedAvatar(
                                url: avatarUrl,
                                radius: 52,
                                backgroundColor: cs.primaryContainer,
                                placeholder: Text(
                                  initials,
                                  style: tt.headlineLarge?.copyWith(
                                    color: cs.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    // Loading overlay
                    if (isUploading)
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black45,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    // Camera button
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: isUploading ? null : onChangePicture,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.surface, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGap12,
                TextButton(
                  onPressed: isUploading ? null : onChangePicture,
                  child: Text(
                    AppLocalizations.of(context)!.changePhoto,
                    style: tt.labelLarge?.copyWith(
                      color: isUploading ? cs.onSurfaceVariant : cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

// ============================================================
// FORM SECTION
// ============================================================
class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: tt.labelMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        AppSpacing.vGap12,
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: AppRadius.borderXl,
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PREMIUM TEXT FIELD
// ============================================================
class _PremiumTextField extends StatelessWidget {
  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      style: TextStyle(
        color: cs.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(icon, color: cs.primary, size: 22),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        filled: true,
        fillColor: cs.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderLg,
          borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderLg,
          borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderLg,
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderLg,
          borderSide: BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderLg,
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
      ),
    );
  }
}

// ============================================================
// EMAIL ROW
// ============================================================
class _EmailRow extends StatelessWidget {
  const _EmailRow({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(
              Icons.email_outlined,
              color: cs.primary,
              size: 20,
            ),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.emailLabel,
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                AppSpacing.vGap4,
                Text(
                  email,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AchievementColors.green.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderFull,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 14,
                  color: AchievementColors.green,
                ),
                AppSpacing.hGap4,
                Text(
                  l10n.confirm,
                  style: tt.labelSmall?.copyWith(
                    color: AchievementColors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
