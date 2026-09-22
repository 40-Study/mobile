import 'package:flutter/material.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/l10n/app_localizations.dart';

class DeviceItem extends StatelessWidget {
  const DeviceItem({super.key, required this.device});

  final DeviceModel device;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: device.isCurrent
                  ? cs.primaryContainer
                  : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getDeviceIcon(device.os ?? ''),
              color: device.isCurrent ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        device.deviceName ??
                            AppLocalizations.of(context)!.unknownDevice,
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (device.isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.thisDevice,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _buildDeviceInfo(),
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(String os) {
    final osLower = os.toLowerCase();
    if (osLower.contains('ios') || osLower.contains('iphone')) {
      return Icons.phone_iphone;
    }
    if (osLower.contains('android')) {
      return Icons.phone_android;
    }
    if (osLower.contains('windows')) {
      return Icons.desktop_windows;
    }
    if (osLower.contains('mac')) {
      return Icons.laptop_mac;
    }
    if (osLower.contains('ipad')) {
      return Icons.tablet_mac;
    }
    return Icons.devices;
  }

  String _buildDeviceInfo() {
    final parts = <String>[];
    if (device.os != null && device.os!.isNotEmpty) {
      parts.add(device.os!);
    }
    if (device.loggedInAt != null) {
      parts.add(_formatTime(device.loggedInAt!));
    }
    return parts.isNotEmpty ? parts.join(' • ') : 'Không có thông tin';
  }

  String _formatTime(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';

    return '${date.day}/${date.month}/${date.year}';
  }
}
