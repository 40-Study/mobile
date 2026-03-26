import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/mock/mock_explore_data.dart';
import 'package:study/features/student/presentation/screens/article_detail_screen.dart';

class ExploreArticleCard extends StatelessWidget {
  const ExploreArticleCard({
    super.key,
    required this.article,
  });
  final MockArticle article;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ArticleDetailScreen(
            title: article.title,
            tag: article.tag,
            tagColor: article.tagColor,
            gradient: article.gradient,
            icon: article.icon,
          ),
        ),
      ),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: AppRadius.borderXl,
          gradient: LinearGradient(
            colors: article.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: article.gradient.last
                  .withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Icon(
                article.icon,
                size: 100,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Padding(
              padding: AppLayout.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: article.tagColor,
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Text(
                      article.tag,
                      style: tt.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    article.title,
                    style: tt.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
