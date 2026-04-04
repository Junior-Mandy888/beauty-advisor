/// 社区帖子
class CommunityPost {
  final String id;
  final String userId;
  final String nickname;
  final String? avatarUrl;
  final String content;
  final List<String> imageUrls;
  final List<String> tags;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CommunityPost({
    required this.id,
    required this.userId,
    required this.nickname,
    this.avatarUrl,
    required this.content,
    this.imageUrls = const [],
    this.tags = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      avatarUrl: json['avatar_url'] as String?,
      content: json['content'] as String,
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nickname': nickname,
      'avatar_url': avatarUrl,
      'content': content,
      'image_urls': imageUrls,
      'tags': tags,
      'like_count': likeCount,
      'comment_count': commentCount,
      'is_liked': isLiked,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CommunityPost copyWith({
    String? id,
    String? userId,
    String? nickname,
    String? avatarUrl,
    String? content,
    List<String>? imageUrls,
    List<String>? tags,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      tags: tags ?? this.tags,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 评论
class Comment {
  final String id;
  final String postId;
  final String userId;
  final String nickname;
  final String? avatarUrl;
  final String content;
  final int likeCount;
  final bool isLiked;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.nickname,
    this.avatarUrl,
    required this.content,
    this.likeCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      avatarUrl: json['avatar_url'] as String?,
      content: json['content'] as String,
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
