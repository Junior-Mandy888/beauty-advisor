import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:beauty_advisor/models/community.dart';
import 'package:beauty_advisor/services/community_service.dart';
import 'package:beauty_advisor/providers/user_provider.dart';
import 'package:beauty_advisor/widgets/loading_animation.dart';

/// 社区页面
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CommunityPost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    
    try {
      _posts = await CommunityService().getPopularPosts();
    } catch (e) {
      debugPrint('加载帖子失败: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('穿搭社区'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFF6B9D),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFFF6B9D),
          tabs: const [
            Tab(text: '热门'),
            Tab(text: '最新'),
            Tab(text: '关注'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostList(),
          _buildPostList(),
          _buildFollowPlaceholder(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePost(),
        backgroundColor: const Color(0xFFFF6B9D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPostList() {
    if (_isLoading) {
      return const Center(child: BrandLoadingIndicator(size: 32));
    }

    if (_posts.isEmpty) {
      return Center(
        child: Text('暂无帖子', style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      color: const Color(0xFFFF6B9D),
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _posts.length,
        itemBuilder: (context, index) => _buildPostCard(_posts[index]),
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return GestureDetector(
      onTap: () => _showPostDetail(post),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: const Color(0xFFFF6B9D).withOpacity(0.1),
                    child: post.avatarUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: CachedNetworkImage(
                              imageUrl: post.avatarUrl!,
                              fit: BoxFit.cover,
                              width: 40.w,
                              height: 40.w,
                            ),
                          )
                        : Icon(Icons.person, size: 20.sp, color: const Color(0xFFFF6B9D)),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.nickname, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                        Text(_formatTime(post.createdAt), style: TextStyle(fontSize: 12.sp, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 内容
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                post.content,
                style: TextStyle(fontSize: 14.sp, height: 1.5),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 图片
            if (post.imageUrls.isNotEmpty) ...[
              SizedBox(height: 12.h),
              _buildImageGrid(post.imageUrls),
            ],
            // 标签
            if (post.tags.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Wrap(
                  spacing: 8.w,
                  children: post.tags.map((tag) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B9D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text('#$tag', style: TextStyle(fontSize: 12.sp, color: const Color(0xFFFF6B9D))),
                  )).toList(),
                ),
              ),
            ],
            // 互动栏
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  _buildActionButton(
                    icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                    label: '${post.likeCount}',
                    color: post.isLiked ? Colors.red : Colors.grey[600]!,
                    onTap: () => _likePost(post),
                  ),
                  SizedBox(width: 24.w),
                  _buildActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: '${post.commentCount}',
                    color: Colors.grey[600]!,
                    onTap: () => _showPostDetail(post),
                  ),
                  SizedBox(width: 24.w),
                  _buildActionButton(
                    icon: Icons.share_outlined,
                    label: '分享',
                    color: Colors.grey[600]!,
                    onTap: () => _sharePost(post),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<String> imageUrls) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();
    
    final count = imageUrls.length > 3 ? 3 : imageUrls.length;
    final imageSize = (MediaQuery.of(context).size.width - 32.w - 24.w) / 3;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: List.generate(count, (index) {
          return Container(
            width: imageSize,
            height: imageSize,
            margin: EdgeInsets.only(right: index < count - 1 ? 8.w : 0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    color: const Color(0xFFFF6B9D).withOpacity(0.1),
                    child: Center(
                      child: Icon(Icons.image, size: 32.sp, color: Colors.grey[400]),
                    ),
                  ),
                ),
                if (index == 2 && imageUrls.length > 3)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        '+${imageUrls.length - 3}',
                        style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: color),
          SizedBox(width: 4.w),
          Text(label, style: TextStyle(fontSize: 12.sp, color: color)),
        ],
      ),
    );
  }

  Widget _buildFollowPlaceholder() {
    final userProvider = context.watch<UserProvider>();
    
    if (userProvider.isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text('暂无关注内容', style: TextStyle(fontSize: 16.sp, color: Colors.grey[500])),
            SizedBox(height: 8.h),
            Text('去发现更多精彩内容吧', style: TextStyle(fontSize: 14.sp, color: Colors.grey[400])),
          ],
        ),
      );
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text('登录后查看关注内容', style: TextStyle(fontSize: 16.sp, color: Colors.grey[500])),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
            ),
            child: const Text('去登录'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    
    return '${time.month}月${time.day}日';
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: _PostSearchDelegate(),
    );
  }

  Future<void> _likePost(CommunityPost post) async {
    await CommunityService().likePost(post.id, !post.isLiked);
    _loadPosts();
  }

  void _sharePost(CommunityPost post) {
    // TODO: 实现分享功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享功能开发中')),
    );
  }

  void _showPostDetail(CommunityPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PostDetailPage(post: post),
      ),
    );
  }

  void _showCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const _CreatePostPage(),
      ),
    );
    
    // 如果发布成功，刷新列表
    if (result == true && mounted) {
      _loadPosts();
    }
  }
}

/// 帖子详情页
class _PostDetailPage extends StatelessWidget {
  final CommunityPost post;

  const _PostDetailPage({required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('帖子详情')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 帖子内容
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(post.content, style: TextStyle(fontSize: 16.sp, height: 1.6)),
            ),
            // 评论区
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('评论 (${post.commentCount})', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16.h),
                  FutureBuilder<List<Comment>>(
                    future: CommunityService().getComments(post.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      
                      return Column(
                        children: snapshot.data!.map((comment) => _buildCommentItem(comment)).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCommentInput(context),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: const Color(0xFFFF6B9D).withOpacity(0.1),
            child: Icon(Icons.person, size: 16.sp, color: const Color(0xFFFF6B9D)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comment.nickname, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 4.h),
                Text(comment.content, style: TextStyle(fontSize: 14.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(BuildContext context) {
    final controller = TextEditingController();
    
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '写下你的评论...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          IconButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await CommunityService().createComment(
                  postId: post.id,
                  userId: 'user',
                  nickname: '用户',
                  content: controller.text,
                );
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.send, color: Color(0xFFFF6B9D)),
          ),
        ],
      ),
    );
  }
}

/// 发布帖子页面
class _CreatePostPage extends StatefulWidget {
  const _CreatePostPage();

  @override
  State<_CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<_CreatePostPage> {
  final _controller = TextEditingController();
  final List<String> _tags = [];
  final List<Uint8List> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发布动态'),
        actions: [
          TextButton(
            onPressed: _controller.text.isNotEmpty && !_isSubmitting ? _submitPost : null,
            child: Text('发布', style: TextStyle(fontSize: 16.sp, color: _controller.text.isNotEmpty ? const Color(0xFFFF6B9D) : Colors.grey)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: '分享你的穿搭心得...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 16.h),
            // 图片区域
            _buildImageSection(),
            SizedBox(height: 16.h),
            // 标签
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: ['穿搭分享', '妆容教程', '发型推荐', '好物推荐', '日常'].map((tag) => GestureDetector(
                onTap: () {
                  setState(() {
                    if (_tags.contains(tag)) {
                      _tags.remove(tag);
                    } else {
                      _tags.add(tag);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: _tags.contains(tag) ? const Color(0xFFFF6B9D).withOpacity(0.1) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: _tags.contains(tag) ? const Color(0xFFFF6B9D) : Colors.transparent),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(fontSize: 13.sp, color: _tags.contains(tag) ? const Color(0xFFFF6B9D) : Colors.grey[600]),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('添加图片（最多9张）', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
        SizedBox(height: 12.h),
        SizedBox(
          height: 100.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // 已选图片
              ..._selectedImages.asMap().entries.map((entry) {
                final index = entry.key;
                final bytes = entry.value;
                return Container(
                  width: 100.w,
                  height: 100.h,
                  margin: EdgeInsets.only(right: 8.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: Colors.grey[200],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.memory(bytes, fit: BoxFit.cover, width: 100.w, height: 100.h),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedImages.removeAt(index)),
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, size: 14.sp, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              // 添加按钮
              if (_selectedImages.length < 9)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 28.sp, color: Colors.grey[500]),
                        SizedBox(height: 4.h),
                        Text('添加图片', style: TextStyle(fontSize: 12.sp, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImages.add(bytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片失败: $e')),
      );
    }
  }

  Future<void> _submitPost() async {
    setState(() => _isSubmitting = true);
    
    final userProvider = context.read<UserProvider>();
    
    // 模拟图片URL（实际项目中需要上传到服务器）
    final imageUrls = _selectedImages.asMap().entries.map((e) => 
      'https://example.com/upload/img_${DateTime.now().millisecondsSinceEpoch}_${e.key}.jpg'
    ).toList();
    
    await CommunityService().createPost(
      userId: userProvider.userId ?? 'anonymous',
      nickname: userProvider.nickname ?? '用户',
      content: _controller.text,
      imageUrls: imageUrls,
      tags: _tags,
    );
    
    if (mounted) {
      // 返回并刷新列表
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('发布成功'), backgroundColor: Color(0xFFFF6B9D)),
      );
    }
  }
}

/// 搜索代理
class _PostSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, ''));
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<CommunityPost>>(
      future: CommunityService().searchPosts(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(snapshot.data![index].content, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(snapshot.data![index].nickname),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text('搜索穿搭心得、标签...', style: TextStyle(color: Colors.grey[500])),
    );
  }
}
