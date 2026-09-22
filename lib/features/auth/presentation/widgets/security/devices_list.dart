import 'package:flutter/material.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/widgets/security/device_item.dart';
import 'package:study/l10n/app_localizations.dart';

class DevicesList extends StatelessWidget {
  const DevicesList({
    super.key,
    required this.devices,
    required this.isLoading,
    required this.onRefresh,
  });

  final List<DeviceModel> devices;
  final bool isLoading;
  final VoidCallback onRefresh;

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

    if (devices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.devices, size: 48, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noDevices,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.reload),
            ),
          ],
        ),
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
        children: devices.asMap().entries.map((entry) {
          final index = entry.key;
          final device = entry.value;
          return Column(
            children: [
              DeviceItem(device: device),
              if (index < devices.length - 1)
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
