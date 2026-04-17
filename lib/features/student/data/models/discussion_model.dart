import 'package:equatable/equatable.dart';

/// Danh muc bai viet.
enum DiscussionCategory {
  programming,
  design,
  learningTips,
  project,
  other;

  static DiscussionCategory fromString(String? value) {
    switch (value) {
      case 'programming':
        return DiscussionCategory.programming;
      case 'design':
        return DiscussionCategory.design;
      case 'learning-tips':
        return DiscussionCategory.learningTips;
      case 'project':
        return DiscussionCategory.project;
      default:
        return DiscussionCategory.other;
    }
  }

  String get displayName {
    switch (this) {
      case DiscussionCategory.programming:
        return 'Lap trinh';
      case DiscussionCategory.design:
        return 'Thiet ke';
      case DiscussionCategory.learningTips:
        return 'Meo hoc tap';
      case DiscussionCategory.project:
        return 'Du an';
      case DiscussionCategory.other:
        return 'Khac';
    }
  }

  String get value {
    switch (this) {
      case DiscussionCategory.programming:
        return 'programming';
      case DiscussionCategory.design:
        return 'design';
      case DiscussionCategory.learningTips:
        return 'learning-tips';
      case DiscussionCategory.project:
        return 'project';
      case DiscussionCategory.other:
        return 'other';
    }
  }
}

/// Loai vote.
enum VoteType {
  upvote,
  downvote,
  none;

  static VoteType fromString(String? value) {
    switch (value) {
      case 'upvote':
        return VoteType.upvote;
      case 'downvote':
        return VoteType.downvote;
      default:
        return VoteType.none;
    }
  }
}

/// Model cho bai viet dien dan.
class ForumPostModel extends Equatable {
  const ForumPostModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.content,
    required this.category,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.createdAt,
    this.updatedAt,
    required this.upvoteCount,
    required this.replyCount,
    this.userVote = VoteType.none,
    this.comments = const [],
  });

  final String id;
  final String slug;
  final String title;
  final String content;
  final DiscussionCategory category;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int upvoteCount;
  final int replyCount;
  final VoteType userVote;
  final List<CommentModel> comments;

  /// Thoi gian hien thi.
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} ngay truoc';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} gio truoc';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} phut truoc';
    }
    return 'Vua xong';
  }

  ForumPostModel copyWith({
    int? upvoteCount,
    VoteType? userVote,
    List<CommentModel>? comments,
    int? replyCount,
  }) {
    return ForumPostModel(
      id: id,
      slug: slug,
      title: title,
      content: content,
      category: category,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      upvoteCount: upvoteCount ?? this.upvoteCount,
      replyCount: replyCount ?? this.replyCount,
      userVote: userVote ?? this.userVote,
      comments: comments ?? this.comments,
    );
  }

  factory ForumPostModel.fromJson(Map<String, dynamic> json) {
    final commentsJson = json['comments'] as List<dynamic>? ?? [];
    return ForumPostModel(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      category: DiscussionCategory.fromString(json['category'] as String?),
      authorId: json['author_id'] as String? ?? '',
      authorName: json['author_name'] as String? ?? '',
      authorAvatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      upvoteCount: json['upvote_count'] as int? ?? 0,
      replyCount: json['reply_count'] as int? ?? 0,
      userVote: VoteType.fromString(json['user_vote'] as String?),
      comments: commentsJson
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        slug,
        title,
        content,
        category,
        authorId,
        authorName,
        authorAvatarUrl,
        createdAt,
        updatedAt,
        upvoteCount,
        replyCount,
        userVote,
        comments,
      ];
}

/// Model cho binh luan.
class CommentModel extends Equatable {
  const CommentModel({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    this.parentId,
    required this.createdAt,
    this.replies = const [],
  });

  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String? parentId;
  final DateTime createdAt;
  final List<CommentModel> replies;

  /// Thoi gian hien thi.
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    }
    return 'now';
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final repliesJson = json['replies'] as List<dynamic>? ?? [];
    return CommentModel(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      authorId: json['author_id'] as String? ?? '',
      authorName: json['author_name'] as String? ?? json['user_name'] as String? ?? '',
      authorAvatarUrl: json['avatar_url'] as String?,
      parentId: json['parent_id'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      replies: repliesJson
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        authorId,
        authorName,
        authorAvatarUrl,
        parentId,
        createdAt,
        replies,
      ];
}
