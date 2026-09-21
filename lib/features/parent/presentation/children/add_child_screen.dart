import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Add/Link Child - liên kết hồ sơ con bằng mã
/// Theo deliverable: nhập mã liên kết do trung tâm cung cấp
class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
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
        child: Padding(
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
                    Icons.link_rounded,
                    color: cs.primary,
                    size: 36,
                  ),
                ),

                // Title
                Text(
                  'Nhập mã liên kết',
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                AppSpacing.vGap8,
                Text(
                  'Nhập mã liên kết do trung tâm cung cấp để liên kết hồ sơ con với tài khoản của bạn.',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),

                AppSpacing.vGap24,

                // Code input
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'Mã liên kết',
                    hintText: 'VD: ABC123XYZ',
                    prefixIcon: const Icon(Icons.vpn_key_outlined),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.borderMd,
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mã liên kết';
                    }
                    if (value.trim().length < 6) {
                      return 'Mã liên kết phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
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
                      : const Text('Xác nhận liên kết'),
                ),

                AppSpacing.vGap16,

                // Help link
                TextButton(
                  onPressed: _showHelpDialog,
                  child: Text(
                    'Không có mã? Liên hệ hỗ trợ',
                    style: tt.bodyMedium?.copyWith(color: cs.primary),
                  ),
                ),

                const Spacer(),

                // Note
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: cs.onSurfaceVariant,
                      ),
                      AppSpacing.hGap12,
                      Expanded(
                        child: Text(
                          'Mã liên kết thường được trung tâm cung cấp khi đăng ký học hoặc trong thông tin học viên.',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
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

    // TODO: Call API to link child
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isLoading = false);

    // TODO: Handle response
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng đang phát triển')),
    );
  }

  void _showHelpDialog() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AppSpacing.vGap24,
            Icon(
              Icons.support_agent_rounded,
              size: 48,
              color: cs.primary,
            ),
            AppSpacing.vGap16,
            Text(
              'Liên hệ hỗ trợ',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            AppSpacing.vGap8,
            Text(
              'Nếu bạn không có mã liên kết, vui lòng liên hệ trung tâm để được hỗ trợ.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap24,
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Navigate to help/support
                },
                icon: const Icon(Icons.chat_outlined),
                label: const Text('Liên hệ hỗ trợ'),
              ),
            ),
            AppSpacing.vGap12,
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ),
            AppSpacing.vGap16,
          ],
        ),
      ),
    );
  }
}
