import 'package:beauty_advisor/models/community.dart';

/// 社区服务
class CommunityService {
  static final CommunityService _instance = CommunityService._internal();
  factory CommunityService() => _instance;
  CommunityService._internal();

  // 保存用户发布的帖子
  final List<CommunityPost> _userPosts = [];

  /// 获取热门帖子
  Future<List<CommunityPost>> getPopularPosts({int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // 合并用户帖子与模拟帖子
    return [..._userPosts, ..._getMockPosts()];
  }

  /// 获取最新帖子
  Future<List<CommunityPost>> getLatestPosts({int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allPosts = [..._userPosts, ..._getMockPosts()];
    allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allPosts;
  }

  /// 获取帖子详情
  Future<CommunityPost?> getPostDetail(String postId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // 先查用户帖子
    final userPost = _userPosts.where((p) => p.id == postId).firstOrNull;
    if (userPost != null) return userPost;
    // 再查模拟帖子
    final posts = _getMockPosts();
    return posts.firstWhere((p) => p.id == postId);
  }

  /// 获取帖子评论
  Future<List<Comment>> getComments(String postId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockComments(postId);
  }

  /// 发布帖子
  Future<CommunityPost?> createPost({
    required String userId,
    required String nickname,
    String? avatarUrl,
    required String content,
    List<String> imageUrls = const [],
    List<String> tags = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final post = CommunityPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      nickname: nickname,
      avatarUrl: avatarUrl,
      content: content,
      imageUrls: imageUrls,
      tags: tags,
      likeCount: 0,
      commentCount: 0,
      isLiked: false,
      createdAt: DateTime.now(),
    );
    
    // 添加到用户帖子列表
    _userPosts.insert(0, post);
    
    return post;
  }

  /// 点赞帖子
  Future<bool> likePost(String postId, bool isLike) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // 更新用户帖子的点赞状态
    final index = _userPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _userPosts[index];
      _userPosts[index] = CommunityPost(
        id: post.id,
        userId: post.userId,
        nickname: post.nickname,
        avatarUrl: post.avatarUrl,
        content: post.content,
        imageUrls: post.imageUrls,
        tags: post.tags,
        likeCount: isLike ? post.likeCount + 1 : post.likeCount - 1,
        commentCount: post.commentCount,
        isLiked: isLike,
        createdAt: post.createdAt,
      );
    }
    return true;
  }

  /// 发布评论
  Future<Comment?> createComment({
    required String postId,
    required String userId,
    required String nickname,
    String? avatarUrl,
    required String content,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return Comment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      userId: userId,
      nickname: nickname,
      avatarUrl: avatarUrl,
      content: content,
      createdAt: DateTime.now(),
    );
  }

  /// 搜索帖子
  Future<List<CommunityPost>> searchPosts(String keyword) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allPosts = [..._userPosts, ..._getMockPosts()];
    return allPosts
        .where((p) => 
            p.content.contains(keyword) || 
            p.tags.any((t) => t.contains(keyword)))
        .toList();
  }

  /// 模拟帖子数据
  List<CommunityPost> _getMockPosts() {
    return [
      CommunityPost(
        id: 'p001',
        userId: 'u001',
        nickname: '穿搭达人小美',
        avatarUrl: null,
        content: '今天尝试了韩系风格，感觉非常适合圆脸！分享一下今天的穿搭心得～',
        imageUrls: ['https://example.com/img1.jpg'],
        tags: ['韩系穿搭', '圆脸', '日常'],
        likeCount: 128,
        commentCount: 23,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CommunityPost(
        id: 'p002',
        userId: 'u002',
        nickname: '时尚博主',
        avatarUrl: null,
        content: '分享一个方脸女生必学的发型技巧！侧分长卷发真的超级显脸小，强烈推荐！',
        imageUrls: ['https://example.com/img2.jpg'],
        tags: ['发型', '方脸', '显脸小'],
        likeCount: 256,
        commentCount: 45,
        isLiked: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      CommunityPost(
        id: 'p003',
        userId: 'u003',
        nickname: '美妆爱好者',
        avatarUrl: null,
        content: '裸妆教程来啦！只需要5分钟，轻松打造天生好皮肤的效果，手残党也能学会～',
        imageUrls: ['https://example.com/img3.jpg', 'https://example.com/img4.jpg'],
        tags: ['裸妆', '化妆教程', '日常'],
        likeCount: 389,
        commentCount: 67,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      CommunityPost(
        id: 'p004',
        userId: 'u004',
        nickname: '职场穿搭师',
        avatarUrl: null,
        content: '职场女性怎么穿既专业又有女人味？这套搭配公式分享给大家～',
        imageUrls: ['https://example.com/img5.jpg'],
        tags: ['职场穿搭', '通勤', 'OL风'],
        likeCount: 167,
        commentCount: 34,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      CommunityPost(
        id: 'p005',
        userId: 'u005',
        nickname: '约会穿搭分享',
        avatarUrl: null,
        content: '周末约会穿什么？这套甜美约会妆+穿搭，男朋友说超好看！',
        imageUrls: ['https://example.com/img6.jpg'],
        tags: ['约会穿搭', '甜美风', '妆容'],
        likeCount: 445,
        commentCount: 89,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// 模拟评论数据
  List<Comment> _getMockComments(String postId) {
    return [
      Comment(
        id: 'c001',
        postId: postId,
        userId: 'u101',
        nickname: '小红',
        content: '太好看了！请问口红是什么色号呀？',
        likeCount: 12,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Comment(
        id: 'c002',
        postId: postId,
        userId: 'u102',
        nickname: '爱美的小美',
        content: '求同款链接！',
        likeCount: 8,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Comment(
        id: 'c003',
        postId: postId,
        userId: 'u103',
        nickname: '穿搭小白',
        content: '学到了！谢谢分享～',
        likeCount: 5,
        isLiked: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }
}
