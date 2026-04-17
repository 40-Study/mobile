import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/discussion/discussion_cubit.dart';
import 'package:study/features/student/bloc/discussion/discussion_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/features/student/presentation/screens/discussion_detail_screen.dart';
import 'package:study/features/student/presentation/screens/create_discussion_screen.dart';
import 'package:study/index.dart';
import 'package:study/widgets/simple_gradient_background.dart';

// Custom colors for forum
class _ForumColors {
  static const Color programming = Color(0xFF6366F1); // Indigo
  static const Color design = Color(0xFFEC4899); // Pink
  static const Color learningTips = Color(0xFFF59E0B); // Amber
  static const Color project = Color(0xFF10B981); // Emerald
  static const Color other = Color(0xFF6B7280); // Gray
  static const Color hot = Color(0xFFEF4444); // Red
  static const Color upvote = Color(0xFF3B82F6); // Blue
  static const Color comment = Color(0xFF8B5CF6); // Violet
}

class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiscussionListCubit(
        repository: context.read<StudentRepository>(),
      )..loadDiscussions(),
      child: const _ForumScreenContent(),
    );
  }
}

class _ForumScreenContent extends StatelessWidget {
  const _ForumScreenContent();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SimpleGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Dien dan'),
          actions: [
            IconButton(
              onPressed: () => _showSortOptions(context),
              icon: const Icon(Icons.tune),
            ),
          ],
        ),
        body: BlocBuilder<DiscussionListCubit, DiscussionState>(
          builder: (context, state) {
            return switch (state) {
              DiscussionInitial() ||
              DiscussionLoading() =>
                const Center(child: CircularProgressIndicator()),
              DiscussionListLoaded() => _buildContent(context, state),
              DiscussionDetailLoaded() => const SizedBox.shrink(),
              DiscussionError(:final message) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: cs.error),
                      const SizedBox(height: AppSpacing.md),
                      Text(message),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton(
                        onPressed: () =>
                            context.read<DiscussionListCubit>().loadDiscussions(),
                        child: const Text('Thu lai'),
                      ),
                    ],
                  ),
                ),
            };
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _createPost(context),
          icon: const Icon(Icons.edit),
          label: const Text('Dang bai'),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DiscussionListLoaded state) {
    return Stack(
      children: [
        // Background decorations
        Positioned(
          top: -60,
          right: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _ForumColors.programming.withOpacity(0.08),
                  _ForumColors.programming.withOpacity(0.02),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 150,
          left: -60,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _ForumColors.design.withOpacity(0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 250,
          right: -30,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _ForumColors.learningTips.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Decorative icons
        Positioned(
          top: 100,
          left: 20,
          child: Transform.rotate(
            angle: -0.2,
            child: Icon(
              Icons.chat_bubble_outline,
              size: 24,
              color: _ForumColors.programming.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          bottom: 300,
          right: 25,
          child: Transform.rotate(
            angle: 0.15,
            child: Icon(
              Icons.code,
              size: 28,
              color: _ForumColors.comment.withOpacity(0.05),
            ),
          ),
        ),

        // Main content
        Column(
          children: [
            // Category filter
            _CategoryFilter(
              selectedCategory: state.selectedCategory,
              onCategoryChanged: (category) {
                context.read<DiscussionListCubit>().filterByCategory(category);
              },
            ),

            // Posts list
            Expanded(
              child: state.discussions.isEmpty
                  ? _buildEmptyState(context)
                  : RefreshIndicator(
                      onRefresh: () => context.read<DiscussionListCubit>().refresh(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: state.discussions.length +
                            (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.discussions.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(AppSpacing.md),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final discussion = state.discussions[index];
                          return _DiscussionCard(
                            discussion: discussion,
                            onTap: () => _openDiscussion(context, discussion),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.forum_outlined, size: 64, color: cs.outline),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Chua co bai viet nao',
            style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Hay la nguoi dau tien dang bai!',
            style: tt.bodyMedium?.copyWith(color: cs.outline),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Moi nhat'),
              onTap: () {
                Navigator.of(ctx).pop();
                context.read<DiscussionListCubit>().sortBy('recent');
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Pho bien'),
              onTap: () {
                Navigator.of(ctx).pop();
                context.read<DiscussionListCubit>().sortBy('popular');
              },
            ),
            ListTile(
              leading: const Icon(Icons.thumb_up),
              title: const Text('Vote cao nhat'),
              onTap: () {
                Navigator.of(ctx).pop();
                context.read<DiscussionListCubit>().sortBy('most_voted');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _createPost(BuildContext context) async {
    final result = await Navigator.of(context).push<ForumPostModel>(
      MaterialPageRoute(
        builder: (_) => RepositoryProvider.value(
          value: context.read<StudentRepository>(),
          child: const CreateDiscussionScreen(),
        ),
      ),
    );

    if (result != null && context.mounted) {
      context.read<DiscussionListCubit>().refresh();
    }
  }

  void _openDiscussion(BuildContext context, ForumPostModel discussion) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RepositoryProvider.value(
          value: context.read<StudentRepository>(),
          child: DiscussionDetailScreen(slug: discussion.slug),
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final DiscussionCategory? selectedCategory;
  final ValueChanged<DiscussionCategory?> onCategoryChanged;

  Color _getCategoryColor(DiscussionCategory? category) {
    if (category == null) return const Color(0xFF6B7280);
    switch (category) {
      case DiscussionCategory.programming:
        return _ForumColors.programming;
      case DiscussionCategory.design:
        return _ForumColors.design;
      case DiscussionCategory.learningTips:
        return _ForumColors.learningTips;
      case DiscussionCategory.project:
        return _ForumColors.project;
      case DiscussionCategory.other:
        return _ForumColors.other;
    }
  }

  IconData _getCategoryIcon(DiscussionCategory? category) {
    if (category == null) return Icons.apps;
    switch (category) {
      case DiscussionCategory.programming:
        return Icons.code;
      case DiscussionCategory.design:
        return Icons.palette;
      case DiscussionCategory.learningTips:
        return Icons.lightbulb;
      case DiscussionCategory.project:
        return Icons.folder;
      case DiscussionCategory.other:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _CategoryChip(
            icon: Icons.apps,
            label: 'Tat ca',
            color: const Color(0xFF6B7280),
            isSelected: selectedCategory == null,
            onTap: () => onCategoryChanged(null),
          ),
          const SizedBox(width: AppSpacing.sm),
          ...DiscussionCategory.values
              .where((c) => c != DiscussionCategory.other)
              .map((category) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: _CategoryChip(
                      icon: _getCategoryIcon(category),
                      label: category.displayName,
                      color: _getCategoryColor(category),
                      isSelected: selectedCategory == category,
                      onTap: () => onCategoryChanged(category),
                    ),
                  )),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color : color.withOpacity(0.1),
      borderRadius: AppRadius.borderSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderSm,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscussionCard extends StatelessWidget {
  const _DiscussionCard({
    required this.discussion,
    required this.onTap,
  });

  final ForumPostModel discussion;
  final VoidCallback onTap;

  Color _getCategoryColor(DiscussionCategory category) {
    switch (category) {
      case DiscussionCategory.programming:
        return _ForumColors.programming;
      case DiscussionCategory.design:
        return _ForumColors.design;
      case DiscussionCategory.learningTips:
        return _ForumColors.learningTips;
      case DiscussionCategory.project:
        return _ForumColors.project;
      case DiscussionCategory.other:
        return _ForumColors.other;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final categoryColor = _getCategoryColor(discussion.category);
    final isHot = discussion.upvoteCount > 5;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.borderSm,
        border: Border.all(
          color: isHot
              ? _ForumColors.hot.withOpacity(0.3)
              : cs.outline.withOpacity(0.1),
          width: isHot ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderSm,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Avatar with colored ring
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: categoryColor, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: categoryColor.withOpacity(0.1),
                        backgroundImage: discussion.authorAvatarUrl != null
                            ? NetworkImage(discussion.authorAvatarUrl!)
                            : null,
                        child: discussion.authorAvatarUrl == null
                            ? Text(
                                discussion.authorName.isNotEmpty
                                    ? discussion.authorName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: categoryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            discussion.authorName,
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            discussion.timeAgo,
                            style: tt.bodySmall?.copyWith(
                              color: cs.outline,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Category + Hot badge
                    Row(
                      children: [
                        if (isHot)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEF4444), Color(0xFFF97316)],
                              ),
                              borderRadius: AppRadius.borderXs,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.local_fire_department,
                                    size: 10, color: Colors.white),
                                SizedBox(width: 2),
                                Text(
                                  'HOT',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: AppRadius.borderSm,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoryIcon(discussion.category),
                                size: 12,
                                color: categoryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                discussion.category.displayName,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: categoryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Title
                Text(
                  discussion.title,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppSpacing.xs),

                // Content preview
                Text(
                  discussion.content,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppSpacing.md),

                // Stats row
                Row(
                  children: [
                    _StatButton(
                      icon: discussion.userVote == VoteType.upvote
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                      value: discussion.upvoteCount,
                      color: _ForumColors.upvote,
                      isActive: discussion.userVote == VoteType.upvote,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _StatButton(
                      icon: Icons.chat_bubble_outline,
                      value: discussion.replyCount,
                      color: _ForumColors.comment,
                      isActive: false,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: cs.outline,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(DiscussionCategory category) {
    switch (category) {
      case DiscussionCategory.programming:
        return Icons.code;
      case DiscussionCategory.design:
        return Icons.palette;
      case DiscussionCategory.learningTips:
        return Icons.lightbulb;
      case DiscussionCategory.project:
        return Icons.folder;
      case DiscussionCategory.other:
        return Icons.more_horiz;
    }
  }
}

class _StatButton extends StatelessWidget {
  const _StatButton({
    required this.icon,
    required this.value,
    required this.color,
    required this.isActive,
  });

  final IconData icon;
  final int value;
  final Color color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.15) : Colors.transparent,
        borderRadius: AppRadius.borderSm,
        border: Border.all(
          color: isActive ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive ? color : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? color : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
