import 'package:flutter/material.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/widgets/security/linked_account_item.dart';

class LinkedAccountsList extends StatelessWidget {
  const LinkedAccountsList({
    super.key,
    required this.linkedAccounts,
    required this.isLoading,
    required this.unlinkingProvider,
    required this.onUnlink,
    required this.onLink,
  });

  final List<LinkedAccountModel> linkedAccounts;
  final bool isLoading;
  final String? unlinkingProvider;
  final void Function(String provider) onUnlink;
  final void Function(String provider) onLink;

  // Supported OAuth providers
  static const _providers = ['google', 'facebook', 'github'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _providers.asMap().entries.map((entry) {
          final index = entry.key;
          final provider = entry.value;
          final linkedAccount = linkedAccounts
              .cast<LinkedAccountModel?>()
              .firstWhere(
                (a) => a?.provider.toLowerCase() == provider,
                orElse: () => null,
              );
          final isLinked = linkedAccount != null;
          final isUnlinking = unlinkingProvider == provider;

          return Column(
            children: [
              LinkedAccountItem(
                provider: provider,
                email: linkedAccount?.email,
                isLinked: isLinked,
                isLoading: isUnlinking,
                onTap: () => isLinked ? onUnlink(provider) : onLink(provider),
              ),
              if (index < _providers.length - 1)
                Divider(
                  height: 1,
                  indent: 72,
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
