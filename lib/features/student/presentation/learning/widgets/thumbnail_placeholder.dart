import 'package:flutter/material.dart';

class ThumbnailPlaceholder extends StatelessWidget {
  const ThumbnailPlaceholder({super.key, required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cs.primaryContainer,
      child: Icon(Icons.auto_stories_outlined, color: cs.onPrimaryContainer, size: 32),
    );
  }
}
