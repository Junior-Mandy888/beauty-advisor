import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:beauty_advisor/models/makeup_tutorial.dart';
import 'package:beauty_advisor/services/makeup_tutorial_service.dart';
import 'package:beauty_advisor/services/ai_video_service.dart';
import 'package:beauty_advisor/providers/user_provider.dart';
import 'package:beauty_advisor/widgets/loading_animation.dart';

/// 妆容教程页面
class MakeupTutorialScreen extends StatefulWidget {
  const MakeupTutorialScreen({super.key});

  @override
  State<MakeupTutorialScreen> createState() => _MakeupTutorialScreenState();
}

class _MakeupTutorialScreenState extends State<MakeupTutorialScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MakeupTutorial> _recommendedTutorials = [];
  List<MakeupTutorial> _allTutorials = [];
  bool _isLoading = true;
  String? _userFaceShape;
  Uint8List? _selectedFaceImage;
  bool _isGeneratingVideo = false;
  String? _generatedVideoUrl;
  String? _currentVideoStyle;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
      _allTutorials = await MakeupTutorialService().getPopularTutorials();
      
      if (_userFaceShape != null) {
        _recommendedTutorials = await MakeupTutorialService().getRecommendedTutorials(_userFaceShape!);
      }
    } catch (e) {
      debugPrint('加载妆容教程失败: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('妆容教程'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFFFF6B9D),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFFF6B9D),
          tabs: const [
            Tab(text: '推荐'),
            Tab(text: '日常'),
            Tab(text: '约会'),
            Tab(text: '韩系'),
            Tab(text: '职场'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: BrandLoadingIndicator(size: 32))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRecommendedTab(),
                _buildStyleTabWithVideo(MakeupStyle.daily, 'daily', '日常妆容'),
                _buildStyleTabWithVideo(MakeupStyle.date, 'date', '约会妆容'),
                _buildStyleTabWithVideo(MakeupStyle.korean, 'korean', '韩系妆容'),
                _buildStyleTabWithVideo(MakeupStyle.office, 'office', '职场妆容'),
              ],
            ),
    );
  }

  Widget _buildRecommendedTab() {
    if (_userFaceShape == null) {
      return _buildNoFaceDataState();
    }

    if (_recommendedTutorials.isEmpty) {
      return Center(
        child: Text('暂无适合您脸型的妆容推荐', style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _recommendedTutorials.length,
      itemBuilder: (context, index) => _buildTutorialCard(_recommendedTutorials[index]),
    );
  }

  Widget _buildStyleTab(MakeupStyle style) {
    final filtered = _allTutorials.where((t) => t.style == style).toList();
    
    if (filtered.isEmpty) {
      return Center(
        child: Text('暂无该风格妆容', style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildTutorialCard(filtered[index]),
    );
  }

  /// 带AI视频生成功能的妆容风格标签页
  Widget _buildStyleTabWithVideo(MakeupStyle style, String videoStyle, String styleName) {
    final filtered = _allTutorials.where((t) => t.style == style).toList();
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // AI视频生成卡片
          _buildVideoGenerationCard(videoStyle, styleName),
          SizedBox(height: 16.h),
          // 妆容列表
          if (filtered.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 32.h),
              child: Text('暂无该风格妆容', style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
            )
          else
            ...filtered.map((t) => _buildTutorialCard(t)),
        ],
      ),
    );
  }

  /// AI视频生成卡片
  Widget _buildVideoGenerationCard(String videoStyle, String styleName) {
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
                    Text('AI $styleName示例视频', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4.h),
                    Text(
                      '上传您的脸型照片，AI将生成专属的${styleName}效果视频',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // 已选图片预览
          if (_selectedFaceImage != null && _currentVideoStyle == videoStyle) ...[
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
                  onPressed: _isGeneratingVideo ? null : () => _pickFaceImage(videoStyle),
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: Text(_selectedFaceImage != null && _currentVideoStyle == videoStyle ? '更换照片' : '上传脸型照片'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6B9D),
                    side: const BorderSide(color: Color(0xFFFF6B9D)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                  ),
                ),
              ),
              if (_selectedFaceImage != null && _currentVideoStyle == videoStyle) ...[
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isGeneratingVideo ? null : () => _generateMakeupVideo(videoStyle),
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
          if (_generatedVideoUrl != null && _currentVideoStyle == videoStyle) ...[
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
  Future<void> _pickFaceImage(String videoStyle) async {
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
          _currentVideoStyle = videoStyle;
          _generatedVideoUrl = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片失败: $e')),
      );
    }
  }

  /// 生成妆容视频
  Future<void> _generateMakeupVideo(String videoStyle) async {
    if (_selectedFaceImage == null || _userFaceShape == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先上传脸型照片')),
      );
      return;
    }

    setState(() => _isGeneratingVideo = true);

    try {
      final result = await AIVideoService.generateMakeupVideo(
        faceImage: _selectedFaceImage!,
        makeupStyle: videoStyle,
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

  Widget _buildTutorialCard(MakeupTutorial tutorial) {
    return GestureDetector(
      onTap: () => _showTutorialDetail(tutorial),
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
            // 封面图
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: Container(
                height: 160.h,
                width: double.infinity,
                color: Colors.grey[200],
                child: tutorial.coverImageUrl.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: tutorial.coverImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        errorWidget: (_, __, ___) => _buildPlaceholderImage(tutorial),
                      )
                    : _buildPlaceholderImage(tutorial),
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
                        child: Text(tutorial.styleName, style: TextStyle(fontSize: 12.sp, color: const Color(0xFFFF6B9D))),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.access_time, size: 14.sp, color: Colors.grey[500]),
                      SizedBox(width: 4.w),
                      Text('${tutorial.totalDuration}分钟', style: TextStyle(fontSize: 12.sp, color: Colors.grey[500])),
                      const Spacer(),
                      Icon(Icons.star, size: 14.sp, color: Colors.amber),
                      SizedBox(width: 4.w),
                      Text(tutorial.rating.toString(), style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(tutorial.name, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  Text(
                    tutorial.description,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(Icons.face, size: 16.sp, color: Colors.grey[400]),
                      SizedBox(width: 4.w),
                      Text(
                        '适合: ${tutorial.suitableFaceShapes.take(3).join('、')}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(MakeupTutorial tutorial) {
    return Container(
      color: const Color(0xFFFF6B9D).withOpacity(0.1),
      child: Center(
        child: Icon(Icons.brush, size: 48.sp, color: const Color(0xFFFF6B9D)),
      ),
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
            Text('分析脸型后可获得专属妆容推荐', style: TextStyle(fontSize: 14.sp, color: Colors.grey[400])),
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

  void _showTutorialDetail(MakeupTutorial tutorial) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _TutorialDetailPage(tutorial: tutorial),
      ),
    );
  }
}

/// 教程详情页面
class _TutorialDetailPage extends StatelessWidget {
  final MakeupTutorial tutorial;

  const _TutorialDetailPage({required this.tutorial});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tutorial.name),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 描述
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B9D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 20.sp, color: const Color(0xFFFF6B9D)),
                      SizedBox(width: 8.w),
                      Text('妆容简介', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(tutorial.description, style: TextStyle(fontSize: 14.sp, height: 1.5)),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      _buildInfoChip(Icons.access_time, '${tutorial.totalDuration}分钟'),
                      SizedBox(width: 12.w),
                      _buildInfoChip(Icons.star, tutorial.rating.toString()),
                      SizedBox(width: 12.w),
                      _buildInfoChip(Icons.face, tutorial.styleName),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            
            // 步骤
            Text('化妆步骤', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            ...tutorial.steps.asMap().entries.map((entry) {
              final step = entry.value;
              return _buildStepCard(entry.key + 1, step);
            }),
            SizedBox(height: 24.h),
            
            // 所需产品
            Text('所需产品', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: tutorial.products.map((product) => Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(product, style: TextStyle(fontSize: 14.sp)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.sp, color: const Color(0xFFFF6B9D)),
        SizedBox(width: 4.w),
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildStepCard(int index, MakeupStep step) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B9D),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: Text('$index', style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(step.title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('${step.durationMinutes}分钟', style: TextStyle(fontSize: 12.sp, color: Colors.grey[500])),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(step.description, style: TextStyle(fontSize: 14.sp, color: Colors.grey[600], height: 1.5)),
                if (step.productRecommendation != null) ...[
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B9DFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 14.sp, color: const Color(0xFF6B9DFF)),
                        SizedBox(width: 4.w),
                        Text('推荐: ${step.productRecommendation}', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B9DFF))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
