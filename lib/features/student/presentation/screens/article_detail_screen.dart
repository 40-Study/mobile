import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/mock/mock_article_data.dart';
import 'package:study/theme/app_colors.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({
    super.key,
    required this.title,
    required this.tag,
    required this.tagColor,
    required this.gradient,
    required this.icon,
  });

  final String title;
  final String tag;
  final Color tagColor;
  final List<Color> gradient;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, cs, tt),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(
                  AppLayout.screenMargin),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _AuthorRow(cs: cs, tt: tt),
                  const SizedBox(height: AppSpacing.xxl),
                  Divider(color: cs.outline),
                  const SizedBox(height: AppSpacing.xxl),
                  _ArticleBody(cs: cs, tt: tt),
                  const SizedBox(height: AppSpacing.lg),
                  _TagChips(cs: cs, tt: tt),
                  const SizedBox(
                      height: AppSpacing.xxxl),
                  _EngagementRow(cs: cs, tt: tt),
                  const SizedBox(
                      height: AppSpacing.massive),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: cs.surface,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color:
                  Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
                Icons.bookmark_border_rounded,
                color: Colors.white,
                size: 20),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color:
                  Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share_outlined,
                color: Colors.white, size: 20),
          ),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -30,
                child: Icon(icon,
                    size: 200,
                    color: Colors.white
                        .withValues(alpha: 0.06)),
              ),
              Positioned(
                bottom: 30,
                left: AppLayout.screenMargin,
                right: AppLayout.screenMargin,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: tagColor,
                        borderRadius:
                            AppRadius.borderSm,
                      ),
                      child: Text(
                        tag,
                        style:
                            tt.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: AppSpacing.sm),
                    Text(
                      title.replaceAll('\n', ' '),
                      style:
                          tt.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({
    required this.cs,
    required this.tt,
  });
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: cs.surfaceTintedPrimary,
          child: Icon(Icons.person_rounded,
              size: AppIconSize.lg, color: cs.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text('Nguyen Minh Tuan',
                  style: tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700)),
              Text('15/03/2024 • 8 phut doc',
                  style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArticleBody extends StatelessWidget {
  const _ArticleBody({
    required this.cs,
    required this.tt,
  });
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: mockParagraphs
          .map((p) => Padding(
                padding: const EdgeInsets.only(
                    bottom: AppSpacing.xl),
                child: p.startsWith('## ')
                    ? Text(
                        p.substring(3),
                        style:
                            tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      )
                    : Text(
                        p,
                        style:
                            tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.7,
                        ),
                      ),
              ))
          .toList(),
    );
  }
}

class _TagChips extends StatelessWidget {
  const _TagChips({
    required this.cs,
    required this.tt,
  });
  final ColorScheme cs;
  final TextTheme tt;

  static const _tags = [
    'AI',
    'Giao duc',
    'Cong nghe',
    'EdTech',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _tags
          .map((t) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest,
                  borderRadius: AppRadius.borderXxl,
                  border:
                      Border.all(color: cs.outline),
                ),
                child: Text(
                  '#$t',
                  style: tt.labelMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _EngagementRow extends StatelessWidget {
  const _EngagementRow({
    required this.cs,
    required this.tt,
  });
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppLayout.cardPaddingCompact,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly,
        children: [
          _EngagementButton(
            icon: Icons.favorite_border_rounded,
            label: '245',
            color: cs.error,
          ),
          _EngagementButton(
            icon:
                Icons.chat_bubble_outline_rounded,
            label: '32',
            color: cs.primary,
          ),
          _EngagementButton(
            icon: Icons.bookmark_border_rounded,
            label: 'Luu',
            color: cs.tertiary,
          ),
          _EngagementButton(
            icon: Icons.share_outlined,
            label: 'Chia se',
            color: cs.secondary,
          ),
        ],
      ),
    );
  }
}

class _EngagementButton extends StatelessWidget {
  const _EngagementButton({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {},
      child: Row(
        children: [
          Icon(icon, size: AppIconSize.md, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: tt.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
