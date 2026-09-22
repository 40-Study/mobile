import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:study/features/auth/bloc/account/account_cubit.dart';
import 'package:study/features/auth/bloc/account/account_state.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/presentation/widgets/widgets.dart';
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
  late final TextEditingController _dobController;
  String? _pickedImagePath;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _dobController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _populateFields());
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
        } catch (_) {}
      }
    }
  }

  String _formatPhoneForDisplay(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    if (phone.startsWith('+84')) return '0${phone.substring(3)}';
    return phone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(l10n.editProfile),
        centerTitle: true,
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
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
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
                content: const Text('Cập nhật thành công'),
                backgroundColor: AchievementColors.green,
                behavior: SnackBarBehavior.floating,
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
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar
                EditProfileAvatar(
                  pickedImagePath: _pickedImagePath,
                  onPickImage: _pickAndUploadImage,
                ),
                const SizedBox(height: 32),

                // Form fields
                EditProfileTextField(
                  controller: _nameController,
                  label: l10n.fullNameLabel,
                  icon: Icons.person_outline_rounded,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập họ tên';
                    if (v.trim().length < 2) return 'Họ tên ít nhất 2 ký tự';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                EditProfileTextField(
                  controller: _phoneController,
                  label: l10n.phoneLabel,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final digits = v.replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 10 || digits.length > 11) {
                      return 'Số điện thoại 10-11 số';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                EditProfileTextField(
                  controller: _dobController,
                  label: l10n.dateOfBirthLabel,
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: _selectDate,
                  suffixIcon: Icons.chevron_right_rounded,
                ),
                const SizedBox(height: 24),

                // Email (readonly)
                const EditProfileEmailField(),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
    if (digits.startsWith('0')) return '+84${digits.substring(1)}';
    if (digits.startsWith('84')) return '+$digits';
    return '+84$digits';
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Chụp ảnh'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Chọn từ thư viện'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;

    final picked = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
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
