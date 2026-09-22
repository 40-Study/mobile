import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/cached_avatar.dart';

class InstructorReviewItem extends StatelessWidget {
  const InstructorReviewItem({
    super.key,
    required this.name,
    this.avatar,
    required this.isVerified,
    required this.date,
    required this.rating,
    required this.content,
  });

  final String name;
  final String? avatar;
  final bool isVerified;
  final String date;
  final int rating;
  final String content;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CachedAvatar(
                url: avatar,
                radius: 20,
                backgroundColor: cs.primaryContainer,
                name: name,
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.verified_rounded, size: 14, color: cs.primary),
                        ],
                      ],
                    ),
                    Text(
                      date,
                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_vert_rounded, color: cs.onSurfaceVariant),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          AppSpacing.vGap8,
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 16,
                color: Colors.amber,
              ),
            ),
          ),
          AppSpacing.vGap8,
          Text(
            content,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
