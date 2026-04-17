import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/discussion/discussion_cubit.dart';
import 'package:study/features/student/bloc/discussion/discussion_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/index.dart';

class DiscussionDetailScreen extends StatelessWidget {
  const DiscussionDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiscussionDetailCubit(
        repository: context.read<StudentRepository>(),
        slug: slug,
      )..loadDetail(),
      child: const _DiscussionDetailContent(),
    );
  }
}

class _DiscussionDetailContent extends StatefulWidget {
  const _DiscussionDetailContent();

  @override
  State<_DiscussionDetailContent> createState() =>
      _DiscussionDetailContentState();
}

class _DiscussionDetailContentState extends State<_DiscussionDetailContent> {
  final _commentController = TextEditingController();
  String? _replyToId;
  String? _replyToName;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    context.read<DiscussionDetailCubit>().addComment(
          content,
          parentId: _replyToId,
        );
    _commentController.clear();
    setState(() {
      _replyToId = null;
      _replyToName = null;
    });
  }

  void _setReplyTo(String id, String name) {
    setState(() {
      _replyToId = id;
      _replyToName = name;
    });
    // Focus on text field
  }

  void _cancelReply() {
    setState(() {
      _replyToId = null;
      _replyToName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bai viet'),
      ),
      body: BlocBuilder<DiscussionDetailCubit, DiscussionState>(
        builder: (context, state) {
          return switch (state) {
            DiscussionInitial() ||
            DiscussionLoading() =>
              const Center(child: CircularProgressIndicator()),
            DiscussionDetailLoaded() => _buildContent(context, state),
            DiscussionListLoaded() => const SizedBox.shrink(),
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
                          context.read<DiscussionDetailCubit>().loadDetail(),
                      child: const Text('Thu lai'),
                    ),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, DiscussionDetailLoaded state) {
    final discussion = state.discussion;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: cs.primaryContainer,
                      backgroundImage: discussion.authorAvatarUrl != null
                          ? NetworkImage(discussion.authorAvatarUrl!)
                          : null,
                      child: discussion.authorAvatarUrl == null
                          ? Text(
                              discussion.authorName.isNotEmpty
                                  ? discussion.authorName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(color: cs.primary),
                            )
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            discussion.authorName,
                            style: tt.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            discussion.timeAgo,
                            style: tt.bodySmall?.copyWith(color: cs.outline),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        discussion.category.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Title
                Text(
                  discussion.title,
                  style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: AppSpacing.md),

                // Content
                Text(
                  discussion.content,
                  style: tt.bodyLarge?.copyWith(height: 1.6),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Actions
                Row(
                  children: [
                    _VoteButton(
                      icon: Icons.thumb_up,
                      label: '${discussion.upvoteCount}',
                      isActive: discussion.userVote == VoteType.upvote,
                      isLoading: state.isVoting,
                      onTap: () => context
                          .read<DiscussionDetailCubit>()
                          .vote(VoteType.upvote),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _VoteButton(
                      icon: Icons.thumb_down,
                      label: '',
                      isActive: discussion.userVote == VoteType.downvote,
                      isLoading: state.isVoting,
                      onTap: () => context
                          .read<DiscussionDetailCubit>()
                          .vote(VoteType.downvote),
                    ),
                  ],
                ),

                const Divider(height: AppSpacing.xxl),

                // Comments header
                Text(
                  'Binh luan (${discussion.comments.length})',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: AppSpacing.md),

                // Comments
                if (discussion.comments.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Text(
                        'Chua co binh luan nao',
                        style: tt.bodyMedium?.copyWith(color: cs.outline),
                      ),
                    ),
                  )
                else
                  ...discussion.comments.map(
                    (comment) => _CommentCard(
                      comment: comment,
                      onReply: () => _setReplyTo(comment.id, comment.authorName),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Comment input
        _CommentInput(
          controller: _commentController,
          replyToName: _replyToName,
          isSubmitting: state.isCommenting,
          onSubmit: _submitComment,
          onCancelReply: _cancelReply,
        ),
      ],
    );
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isLoading,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: isActive ? cs.primaryContainer : cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isActive ? cs.primary : cs.outline,
                  ),
                )
              else
                Icon(
                  isActive ? icon : IconData(icon.codePoint, fontFamily: 'MaterialIcons'),
                  size: 18,
                  color: isActive ? cs.primary : cs.outline,
                ),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? cs.primary : cs.outline,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({
    required this.comment,
    required this.onReply,
  });

  final CommentModel comment;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: cs.surfaceContainerHighest,
                backgroundImage: comment.authorAvatarUrl != null
                    ? NetworkImage(comment.authorAvatarUrl!)
                    : null,
                child: comment.authorAvatarUrl == null
                    ? Text(
                        comment.authorName.isNotEmpty
                            ? comment.authorName[0].toUpperCase()
                            : '?',
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.authorName,
                          style: tt.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          comment.timeAgo,
                          style: tt.bodySmall?.copyWith(
                            color: cs.outline,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.content,
                      style: tt.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: onReply,
                      child: Text(
                        'Tra loi',
                        style: tt.bodySmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Nested replies
          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: AppSpacing.sm),
              child: Column(
                children: comment.replies
                    .map((reply) => _CommentCard(
                          comment: reply,
                          onReply: onReply,
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  const _CommentInput({
    required this.controller,
    required this.replyToName,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onCancelReply,
  });

  final TextEditingController controller;
  final String? replyToName;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onCancelReply;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyToName != null)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      'Tra loi $replyToName',
                      style: tt.bodySmall?.copyWith(color: cs.primary),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onCancelReply,
                      child: Icon(Icons.close, size: 16, color: cs.primary),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Viet binh luan...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filled(
                  onPressed: isSubmitting ? null : onSubmit,
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
