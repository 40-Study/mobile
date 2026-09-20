import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Avatar với cached network image
class CachedAvatar extends StatelessWidget {
  const CachedAvatar({
    super.key,
    this.url,
    this.radius = 20,
    this.backgroundColor,
    this.placeholder,
    this.name,
  });

  final String? url;
  final double radius;
  final Color? backgroundColor;
  final Widget? placeholder;
  final String? name; // Dùng để hiện initials khi không có avatar

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? cs.surfaceContainerHighest;

    Widget fallback;
    if (placeholder != null) {
      fallback = placeholder!;
    } else if (name != null && name!.isNotEmpty) {
      fallback = Text(
        _getInitials(name!),
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.bold,
          color: cs.primary,
        ),
      );
    } else {
      fallback = Icon(Icons.person, size: radius);
    }

    if (url == null || url!.isEmpty) {
      return CircleAvatar(radius: radius, backgroundColor: bg, child: fallback);
    }

    return CachedNetworkImage(
      imageUrl: url!,
      imageBuilder: (_, img) => CircleAvatar(
        radius: radius,
        backgroundImage: img,
      ),
      placeholder: (_, url) => CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: fallback,
      ),
      errorWidget: (_, url, error) => CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: fallback,
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }
}
