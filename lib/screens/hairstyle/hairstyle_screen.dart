import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:beauty_advisor/models/hairstyle.dart';
import 'package:beauty_advisor/services/hairstyle_service.dart';
import 'package:beauty_advisor/services/ai_video_service.dart';
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
  Uint8List? _selectedFaceImage;
  bool _isGeneratingVideo = false;
  String? _generatedVideoUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
          isScrollable: true,
          labelColor: const Color(0xFFFF6B9D),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFFF6B9D),
          tabs: const [
            Tab(text: '推荐'),
            Tab(text: '短发'),
            Tab(text: '长发'),
            Tab(text: '卷发'),
            Tab(text: '盘发'),
            Tab(text: '其他'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: BrandLoadingIndicator(size: 32))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRecommendedTab(),
                _buildTypeTabWithVideo(HairstyleType.short, 'short'),
                _buildTypeTabWithVideo(HairstyleType.long, 'long'),
                _buildTypeTabWithVideo(HairstyleType.curly, 'curly'),
                _buildTypeTabWithVideo(HairstyleType.updo, 'updo'),
                _buildOtherTab(),
              ],
            ),
    );
  }

  /// 其他发型类型（包含中发、波波头、刘海、马尾、编发、直发）
  Widget _buildOtherTab() {
    final otherTypes = [
      HairstyleType.medium,
      HairstyleType.bob,
      HairstyleType.bangs,
      HairstyleType.ponytail,
      HairstyleType.braid,
      HairstyleType.straight,
    ];
    
    final filtered = _allHairstyles.where((h) => otherTypes.contains(h.type)).toList();
    
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

  /// 带AI视频生成功能的发型类型标签页
  Widget _buildTypeTabWithVideo(HairstyleType type, String videoType) {
    final filtered = _allHairstyles.where((h) => h.type == type).toList();
    final typeName = _getTypeName(type);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // AI视频生成卡片
          _buildVideoGenerationCard(videoType, typeName),
          SizedBox(height: 16.h),
          // 发型列表
          if (filtered.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 32.h),
              child: Text('暂无该类型发型', style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
            )
          else
            ...filtered.map((h) => _buildHairstyleCard(h)),
        ],
      ),
    );
  }

  String _getTypeName(HairstyleType type) {
    switch (type) {
      case HairstyleType.short: return '短发';
      case HairstyleType.long: return '长发';
      case HairstyleType.updo: return '盘发';
      default: return '发型';
    }
  }

  /// AI视频生成卡片
  Widget _buildVideoGenerationCard(String videoType, String typeName) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFF6B9D).withOpacity(0.15), const Color(0xFFFFB6C1).withOpacity(0.15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFF6B9D).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B9D).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.videocam, color: Color(0xFFFF6B9D)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI $typeName示例视频', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4.h),
                    Text(
                      '上传您的脸型照片，AI将生成专属的${typeName}效果视频',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // 已选图片预览
          if (_selectedFaceImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.memory(
                _selectedFaceImage!,
                height: 120.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 12.h),
          ],
          // 操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isGeneratingVideo ? null : () => _pickFaceImage(videoType),
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: Text(_selectedFaceImage != null ? '更换照片' : '上传脸型照片'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6B9D),
                    side: const BorderSide(color: Color(0xFFFF6B9D)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                  ),
                ),
              ),
              if (_selectedFaceImage != null) ...[
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isGeneratingVideo ? null : () => _generateHairstyleVideo(videoType),
                    icon: _isGeneratingVideo
                        ? SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.play_arrow, size: 18),
                    label: Text(_isGeneratingVideo ? '生成中...' : '生成视频'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B9D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                    ),
                  ),
                ),
              ],
            ],
          ),
          // 生成结果提示
          if (_generatedVideoUrl != null) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '视频生成成功！可点击查看',
                      style: TextStyle(fontSize: 13.sp, color: Colors.green[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 选择脸型照片
  Future<void> _pickFaceImage(String videoType) async {
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
          _selectedFaceImage = bytes;
          _generatedVideoUrl = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片失败: $e')),
      );
    }
  }

  /// 生成发型视频
  Future<void> _generateHairstyleVideo(String videoType) async {
    if (_selectedFaceImage == null || _userFaceShape == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先上传脸型照片')),
      );
      return;
    }

    setState(() => _isGeneratingVideo = true);

    try {
      final result = await AIVideoService.generateHairstyleVideo(
        faceImage: _selectedFaceImage!,
        hairstyleType: videoType,
        faceShape: _userFaceShape!,
      );

      if (result.success) {
        setState(() {
          _generatedVideoUrl = result.videoUrl ?? 'demo_video_url';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.isDemo ? result.demoMessage ?? '演示模式' : '视频生成成功！'),
              backgroundColor: const Color(0xFFFF6B9D),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.error ?? '生成失败')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成失败: $e')),
        );
      }
    } finally {
      setState(() => _isGeneratingVideo = false);
    }
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
