import 'package:flutter/material.dart';

class LinkedAccountItem extends StatelessWidget {
  const LinkedAccountItem({
    super.key,
    required this.provider,
    required this.email,
    required this.isLinked,
    required this.isLoading,
    required this.onTap,
  });

  final String provider;
  final String? email;
  final bool isLinked;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      onTap: isLoading ? null : onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _getProviderColor(provider).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          _getProviderIcon(provider),
          color: _getProviderColor(provider),
          size: 24,
        ),
      ),
      title: Text(
        _getProviderName(provider),
        style: tt.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: cs.onSurface,
        ),
      ),
      subtitle: Text(
        isLinked ? (email ?? 'Đã liên kết') : 'Chưa liên kết',
        style: tt.bodySmall?.copyWith(
          color: isLinked ? cs.primary : cs.onSurfaceVariant,
        ),
      ),
      trailing: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isLinked ? cs.errorContainer : cs.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isLinked ? 'Hủy' : 'Liên kết',
                style: tt.labelSmall?.copyWith(
                  color: isLinked ? cs.onErrorContainer : cs.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }

  String _getProviderName(String provider) {
    return switch (provider.toLowerCase()) {
      'google' => 'Google',
      'facebook' => 'Facebook',
      'github' => 'GitHub',
      _ => provider,
    };
  }

  IconData _getProviderIcon(String provider) {
    return switch (provider.toLowerCase()) {
      'google' => Icons.g_mobiledata,
      'facebook' => Icons.facebook,
      'github' => Icons.code,
      _ => Icons.link,
    };
  }

  Color _getProviderColor(String provider) {
    return switch (provider.toLowerCase()) {
      'google' => const Color(0xFFDB4437),
      'facebook' => const Color(0xFF4267B2),
      'github' => const Color(0xFF333333),
      _ => Colors.grey,
    };
  }
}
