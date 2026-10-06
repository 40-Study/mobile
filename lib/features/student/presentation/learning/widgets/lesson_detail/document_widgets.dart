import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Section nhóm các tài liệu cùng loại
class DocumentSection extends StatelessWidget {
  const DocumentSection({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: cs.onSurface),
            AppSpacing.hGap8,
            Text(title, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        AppSpacing.vGap12,
        ...children,
      ],
    );
  }
}

/// Card hiển thị 1 tài liệu/file
class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.isDownloaded = false,
    this.isLink = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDownloaded;
  final bool isLink;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          AppSpacing.hGap8,
          if (isDownloaded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 14, color: Colors.green),
                  AppSpacing.hGap4,
                  Text(
                    'Đã tải',
                    style: tt.labelSmall?.copyWith(color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )
          else if (isLink)
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Mở'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              ),
            )
          else
            IconButton.outlined(
              onPressed: () {},
              icon: Icon(Icons.download_rounded, size: 20, color: cs.primary),
              style: IconButton.styleFrom(
                side: BorderSide(color: cs.primary.withValues(alpha: 0.5)),
              ),
            ),
        ],
      ),
    );
  }
}
