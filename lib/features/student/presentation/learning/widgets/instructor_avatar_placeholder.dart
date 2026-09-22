import 'package:flutter/material.dart';

class InstructorAvatarPlaceholder extends StatelessWidget {
  const InstructorAvatarPlaceholder({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      color: cs.primaryContainer,
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'T',
        style: tt.displaySmall?.copyWith(color: cs.onPrimaryContainer),
      ),
    );
  }
}
