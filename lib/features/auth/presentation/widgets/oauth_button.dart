import 'package:flutter/material.dart';

/// OAuth provider button (Google, Facebook, GitHub)
class OAuthButton extends StatelessWidget {
  const OAuthButton({super.key, required this.provider, required this.onTap});

  final String provider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Icon(
          _getProviderIcon(provider),
          color: _getProviderColor(provider),
          size: 24,
        ),
      ),
    );
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
