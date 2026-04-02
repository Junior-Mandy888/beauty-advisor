import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:beauty_advisor/models/hairstyle.dart';
import 'package:beauty_advisor/services/hairstyle_service.dart';
import 'package:beauty_advisor/providers/user_provider.dart';
import 'package:beauty_advisor/widgets/loading_animation.dart';

/// 发型推荐页面
class HairstyleScreen extends StatefulWidget {
  const HairstyleScreen({super.key});

  @override
  State<HairstyleScreen> createState() => _HairstyleScreenState();
}

class _HairstyleScreenState extends State<HairstyleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Hairstyle> _recommendedHairstyles = [];
  List<Hairstyle> _allHairstyles = [];
  bool _isLoading = true;
  String? _userFaceShape;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userProvider = context.read<UserProvider>();
    _userFaceShape = userProvider.faceShape;

    setState(() => _isLoading = true);

    try {
      // 获取所有发型
      _allHairstyles = await HairstyleService().getPopularHairstyles();
      
      // 获取推荐发型
      if (_userFaceShape != null) {
        _recommendedHairstyles = await HairstyleService().getRecommendedHairstyles(_userFaceShape!);
      }
    } catch (e) {
      debugPrint('加载发型失败: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发型推荐'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFF6B9D),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFFF6B9D),
          tabs: const [
            Tab(text: '推荐'),
            Tab(text: '短发'),
            Tab(text: '长发'),
            Tab(text: '盘发'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: BrandLoadingIndicator(size: 32))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRecommendedTab(),
                _buildTypeTab(HairstyleType.short),
                _buildTypeTab(HairstyleType.long),
                _buildTypeTab(HairstyleType.updo),
              ],
            ),
    );
  }

  Widget _buildRecommendedTab() {
    if (_userFaceShape == null) {
      return _buildNoFaceDataState();
    }

    if (_recommendedHairstyles.isEmpty) {
      return Center(
        child: Text('暂无适合您脸型的发型推荐', style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _recommendedHairstyles.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildFaceShapeInfo();
        }
        return _buildHairstyleCard(_recommendedHairstyles[index - 1]);
      },
    );
  }

  Widget _buildFaceShapeInfo() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFF6B9D).withOpacity(0.1), const Color(0xFFFFB6C1).withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B9D).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.face, color: Color(0xFFFF6B9D)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('您的脸型: $_userFaceShape', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 4.h),
                Text('为您推荐最适合的发型', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTab(HairstyleType type) {
    final filtered = _allHairstyles.where((h) => h.type == type).toList();
    
    if (filtered.isEmpty) {
      return Center(
        child: Text('暂无该类型发型', style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildHairstyleCard(filtered[index]),
    );
  }

  Widget _buildHairstyleCard(Hairstyle hairstyle) {
    return Container(
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
          // 图片
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: Container(
              height: 180.h,
              width: double.infinity,
              color: Colors.grey[200],
              child: hairstyle.imageUrl.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: hairstyle.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (_, __, ___) => _buildPlaceholderImage(hairstyle),
                    )
                  : _buildPlaceholderImage(hairstyle),
            ),
          ),
          // 信息
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B9D).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(hairstyle.typeName, style: TextStyle(fontSize: 12.sp, color: const Color(0xFFFF6B9D))),
                    ),
                    SizedBox(width: 8.w),
                    ...hairstyle.suitableFaceShapes.take(3).map((face) => Container(
                      margin: EdgeInsets.only(right: 4.w),
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(face, style: TextStyle(fontSize: 10.sp, color: Colors.grey[600])),
                    )),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(hairstyle.name, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Text(
                  hairstyle.description,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600], height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _buildInfoItem(Icons.auto_awesome, '难度', '${hairstyle.difficulty}/5'),
                    SizedBox(width: 24.w),
                    _buildInfoItem(Icons.favorite, '热度', '${hairstyle.popularity}'),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () => _showHairstyleDetail(hairstyle),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF6B9D),
                        side: const BorderSide(color: Color(0xFFFF6B9D)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                      ),
                      child: const Text('查看详情'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(Hairstyle hairstyle) {
    return Container(
      color: const Color(0xFFFF6B9D).withOpacity(0.1),
      child: Center(
        child: Icon(Icons.content_cut, size: 48.sp, color: const Color(0xFFFF6B9D)),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey[500]),
        SizedBox(width: 4.w),
        Text('$label: $value', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildNoFaceDataState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.face_retouching_natural, size: 64.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text('还没有进行脸型分析', style: TextStyle(fontSize: 16.sp, color: Colors.grey[500])),
            SizedBox(height: 8.h),
            Text('分析脸型后可获得专属发型推荐', style: TextStyle(fontSize: 14.sp, color: Colors.grey[400])),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/face-analysis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
              ),
              child: const Text('去分析脸型'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHairstyleDetail(Hairstyle hairstyle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _buildDetailSheet(hairstyle, scrollController),
      ),
    );
  }

  Widget _buildDetailSheet(Hairstyle hairstyle, ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(hairstyle.name, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            Text(hairstyle.description, style: TextStyle(fontSize: 14.sp, color: Colors.grey[600], height: 1.6)),
            SizedBox(height: 24.h),
            _buildDetailSection('适合脸型', hairstyle.suitableFaceShapes.join('、')),
            SizedBox(height: 16.h),
            _buildDetailSection('适合场合', hairstyle.suitableOccasions.join('、')),
            SizedBox(height: 16.h),
            _buildDetailSection('造型难度', '★★★★★'.substring(0, hairstyle.difficulty)),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 收藏或查看教程
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B9D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                ),
                child: const Text('收藏这个发型'),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
        SizedBox(height: 4.h),
        Text(content, style: TextStyle(fontSize: 16.sp)),
      ],
    );
  }
}
