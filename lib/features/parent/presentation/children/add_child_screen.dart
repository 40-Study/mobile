import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/parent/repository/parent_home_repository.dart';
import 'package:study/theme/theme.dart';

/// Add/Link Child - liên kết con bằng email học sinh
class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _relationship = 'parent';

  static const _relationships = [
    ('parent', 'Phụ huynh'),
    ('guardian', 'Người giám hộ'),
    ('grandparent', 'Ông/Bà'),
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liên kết hồ sơ con'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Container(
                  width: 72,
                  height: 72,
                  margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.family_restroom_rounded,
                    color: cs.primary,
                    size: 36,
                  ),
                ),

                // Title
                Text(
                  'Gửi yêu cầu liên kết',
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                AppSpacing.vGap8,
                Text(
                  'Nhập email tài khoản học sinh của con để gửi yêu cầu liên kết. Con sẽ nhận được thông báo để xác nhận.',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),

                AppSpacing.vGap24,

                // Email input
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email học sinh',
                    hintText: 'email@example.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value.trim())) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),

                AppSpacing.vGap16,

                // Relationship dropdown
                DropdownButtonFormField<String>(
                  value: _relationship,
                  decoration: InputDecoration(
                    labelText: 'Quan hệ với học sinh',
                    prefixIcon: const Icon(Icons.people_outline),
                    border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                  ),
                  items: _relationships
                      .map((r) => DropdownMenuItem(value: r.$1, child: Text(r.$2)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _relationship = value);
                  },
                ),

                AppSpacing.vGap16,

                // Message input (optional)
                TextFormField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: 'Lời nhắn (không bắt buộc)',
                    hintText: 'VD: Con ơi, ba/mẹ muốn theo dõi tiến độ học tập của con',
                    prefixIcon: const Icon(Icons.message_outlined),
                    border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                  ),
                  maxLines: 2,
                  maxLength: 500,
                ),

                AppSpacing.vGap24,

                // Submit button
                FilledButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Gửi yêu cầu liên kết'),
                ),

                AppSpacing.vGap24,

                // Info note
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: cs.onSurfaceVariant,
                      ),
                      AppSpacing.hGap12,
                      Expanded(
                        child: Text(
                          'Học sinh sẽ nhận được thông báo yêu cầu liên kết. '
                          'Sau khi con xác nhận, bạn sẽ có thể theo dõi tiến độ học tập.',
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = context.read<ParentHomeRepository>();
      await repo.sendLinkRequest(
        studentEmail: _emailController.text.trim(),
        relationship: _relationship,
        message: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi yêu cầu liên kết. Chờ học sinh xác nhận.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      var message = 'Không thể gửi yêu cầu. Vui lòng thử lại.';
      final error = e.toString();
      if (error.contains('not found') || error.contains('404')) {
        message = 'Không tìm thấy tài khoản học sinh với email này.';
      } else if (error.contains('already') || error.contains('409')) {
        message = 'Đã có yêu cầu liên kết hoặc đã liên kết với học sinh này.';
      } else if (error.contains('rate') || error.contains('429')) {
        message = 'Bạn gửi quá nhiều yêu cầu. Vui lòng thử lại sau.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
