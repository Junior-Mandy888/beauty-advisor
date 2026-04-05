import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:beauty_advisor/providers/user_provider.dart';
import 'package:beauty_advisor/providers/weather_provider.dart';
import 'package:beauty_advisor/providers/recommendation_provider.dart';
import 'package:beauty_advisor/services/deepseek_service.dart';
import 'package:beauty_advisor/services/liblib_service.dart';
import 'package:beauty_advisor/models/recommendation.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  bool _isLoadingText = false;
  bool _isLoadingImage = false;
  String? _textRecommendation;
  String? _imageUrl;
  String? _projectUrl;
  String? _error;
  
  // 当前生成的推荐（用于保存）
  Recommendation? _currentTextRec;
  Recommendation? _currentImageRec;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecommendations();
    });
  }

  Future<void> _loadRecommendations() async {
    final userProvider = context.read<UserProvider>();
    if (userProvider.userId != null) {
      await context.read<RecommendationProvider>().loadRecommendations(userProvider.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('智能推荐'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistoryBottomSheet(),
            tooltip: '历史记录',
          ),
        ],
      ),
      body: Consumer2<UserProvider, WeatherProvider>(
        builder: (context, user, weather, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConditionCard(user, weather),
                SizedBox(height: 20.h),
                _buildActionButtons(user),
                SizedBox(height: 24.h),
                if (_error != null) _buildErrorCard(),
                if (_isLoadingText || _isLoadingImage) _buildLoadingIndicator(),
                if (_textRecommendation != null) _buildTextResultCard(),
                if (_imageUrl != null) _buildImageResultCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConditionCard(UserProvider user, WeatherProvider weather) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('推荐条件', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          _buildConditionRow('脸型', user.faceShape ?? '未分析'),
          SizedBox(height: 12.h),
          _buildConditionRow('年龄', user.age != null ? '${user.age}岁' : '未设置'),
          SizedBox(height: 12.h),
          _buildConditionRow('天气', weather.currentWeather?.condition ?? '晴'),
          SizedBox(height: 12.h),
          _buildConditionRow('温度', weather.currentWeather != null ? '${weather.currentWeather!.temperature.toInt()}°C' : '26°C'),
        ],
      ),
    );
  }

  Widget _buildConditionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
        Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildActionButtons(UserProvider user) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoadingText ? null : () => _generateTextRecommendation(user),
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('文字推荐'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoadingImage ? null : () => _generateImageRecommendation(user),
            icon: const Icon(Icons.image, size: 18),
            label: const Text('穿搭参考图'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B9DFF),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400]),
          SizedBox(width: 12.w),
          Expanded(child: Text(_error!, style: TextStyle(color: Colors.red[700]))),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
          ),
          SizedBox(height: 16.h),
          Text(
            _isLoadingImage ? 'AI 正在生成穿搭参考图...\n预计需要 30-60 秒' : 'AI 正在生成推荐...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTextResultCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: const Color(0xFFFF6B9D), size: 20.sp),
              SizedBox(width: 8.w),
              Text('文字推荐', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (_currentTextRec != null)
                IconButton(
                  icon: Icon(
                    _currentTextRec!.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _currentTextRec!.isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () => _toggleFavorite(_currentTextRec!),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            _textRecommendation!,
            style: TextStyle(fontSize: 14.sp, height: 1.6),
          ),
          SizedBox(height: 16.h),
          // 新增：根据文字推荐生成图片按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoadingImage ? null : () => _generateImageFromText(),
                  icon: _isLoadingImage 
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.image, size: 18),
                  label: Text(_isLoadingImage ? '生成中...' : '生成推荐图片'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B9DFF),
                    side: const BorderSide(color: Color(0xFF6B9DFF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 根据文字推荐生成对应图片
  Future<void> _generateImageFromText() async {
    if (_textRecommendation == null) return;
    
    final user = context.read<UserProvider>();
    if (user.faceShape == null) {
      setState(() => _error = '请先进行脸型分析');
      return;
    }

    setState(() {
      _isLoadingImage = true;
      _error = null;
      _imageUrl = null;
      _currentImageRec = null;
    });

    try {
      final weather = context.read<WeatherProvider>();
      
      // 基于文字推荐内容生成图片
      final result = await LiblibService.generateOutfitImageFromText(
        textRecommendation: _textRecommendation!,
        faceShape: user.faceShape!,
        weather: '${weather.currentWeather?.condition ?? "晴"}，${weather.currentWeather?.temperature.toInt() ?? 26}°C',
      );

      setState(() {
        if (result.success && result.imageUrl != null) {
          _imageUrl = result.imageUrl;
          _projectUrl = result.projectUrl;
          // 自动保存图片推荐
          if (user.userId != null) {
            _autoSaveImageRecommendation(result.imageUrl!, user, weather, result.projectUrl);
          }
        } else {
          _error = result.error ?? '生成失败，请重试';
        }
        _isLoadingImage = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingImage = false;
      });
    }
  }

  Widget _buildImageResultCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: CachedNetworkImage(
              imageUrl: _imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(
                height: 300.h,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 300.h,
                color: Colors.grey[200],
                child: const Icon(Icons.error),
              ),
            ),
          ),
          // 信息栏
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.image, color: const Color(0xFF6B9DFF), size: 20.sp),
                    SizedBox(width: 8.w),
                    Text('穿搭参考图', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    if (_currentImageRec != null)
                      IconButton(
                        icon: Icon(
                          _currentImageRec!.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _currentImageRec!.isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => _toggleFavorite(_currentImageRec!),
                      ),
                  ],
                ),
                if (_projectUrl != null) ...[
                  SizedBox(height: 12.h),
                  InkWell(
                    onTap: () => _openProjectUrl(),
                    child: Row(
                      children: [
                        Icon(Icons.open_in_new, size: 16.sp, color: Colors.grey[600]),
                        SizedBox(width: 4.w),
                        Text('在 LiblibAI 中编辑', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
                if (_currentImageRec == null) ...[
                  SizedBox(height: 12.h),
                  OutlinedButton.icon(
                    onPressed: _saveImageRecommendation,
                    icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                    label: const Text('保存到历史'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B9DFF),
                      side: const BorderSide(color: Color(0xFF6B9DFF)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
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

  Future<void> _generateTextRecommendation(UserProvider user) async {
    if (user.faceShape == null) {
      setState(() => _error = '请先进行脸型分析');
      return;
    }

    setState(() {
      _isLoadingText = true;
      _error = null;
      _textRecommendation = null;
      _currentTextRec = null;
    });

    try {
      final weather = context.read<WeatherProvider>();
      final result = await DeepSeekService.generateRecommendation(
        faceShape: user.faceShape!,
        age: user.age ?? 25,
        weather: weather.currentWeather?.condition ?? '晴天',
        gender: '女',
      );

      setState(() {
        _textRecommendation = result;
        _isLoadingText = false;
      });

      // 自动保存文字推荐
      if (result.isNotEmpty && user.userId != null) {
        _autoSaveTextRecommendation(result, user, weather);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingText = false;
      });
    }
  }

  /// 自动保存文字推荐
  Future<void> _autoSaveTextRecommendation(String content, UserProvider user, WeatherProvider weather) async {
    final rec = await context.read<RecommendationProvider>().saveTextRecommendation(
      userId: user.userId!,
      content: content,
      faceShape: user.faceShape,
      weatherCondition: weather.currentWeather?.condition,
    );
    
    if (rec != null && mounted) {
      setState(() => _currentTextRec = rec);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已自动保存到历史记录'),
          backgroundColor: Color(0xFFFF6B9D),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _generateImageRecommendation(UserProvider user) async {
    if (user.faceShape == null) {
      setState(() => _error = '请先进行脸型分析');
      return;
    }

    setState(() {
      _isLoadingImage = true;
      _error = null;
      _imageUrl = null;
      _currentImageRec = null;
    });

    try {
      final weather = context.read<WeatherProvider>();
      final result = await LiblibService.generateOutfitImage(
        faceShape: user.faceShape!,
        weather: '${weather.currentWeather?.condition ?? "晴"}，${weather.currentWeather?.temperature.toInt() ?? 26}°C',
      );

      setState(() {
        if (result.success && result.imageUrl != null) {
          _imageUrl = result.imageUrl;
          _projectUrl = result.projectUrl;
          // 自动保存图片推荐
          if (user.userId != null) {
            _autoSaveImageRecommendation(result.imageUrl!, user, weather, result.projectUrl);
          }
        } else {
          _error = result.error ?? '生成失败，请重试';
        }
        _isLoadingImage = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingImage = false;
      });
    }
  }

  /// 自动保存图片推荐
  Future<void> _autoSaveImageRecommendation(String imageUrl, UserProvider user, WeatherProvider weather, String? projectUrl) async {
    final rec = await context.read<RecommendationProvider>().saveImageRecommendation(
      userId: user.userId!,
      imageUrl: imageUrl,
      projectUrl: projectUrl,
      faceShape: user.faceShape,
      weatherCondition: weather.currentWeather?.condition,
    );
    
    if (rec != null && mounted) {
      setState(() => _currentImageRec = rec);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已自动保存到历史记录'),
          backgroundColor: Color(0xFF6B9DFF),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveTextRecommendation() async {
    if (_textRecommendation == null) return;
    
    final userProvider = context.read<UserProvider>();
    final weather = context.read<WeatherProvider>();
    
    final rec = await context.read<RecommendationProvider>().saveTextRecommendation(
      userId: userProvider.userId!,
      content: _textRecommendation!,
      faceShape: userProvider.faceShape,
      weatherCondition: weather.currentWeather?.condition,
    );
    
    if (rec != null && mounted) {
      setState(() => _currentTextRec = rec);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已保存到历史记录'),
          backgroundColor: Color(0xFFFF6B9D),
        ),
      );
    }
  }

  Future<void> _saveImageRecommendation() async {
    if (_imageUrl == null) return;
    
    final userProvider = context.read<UserProvider>();
    final weather = context.read<WeatherProvider>();
    
    final rec = await context.read<RecommendationProvider>().saveImageRecommendation(
      userId: userProvider.userId!,
      imageUrl: _imageUrl!,
      projectUrl: _projectUrl,
      faceShape: userProvider.faceShape,
      weatherCondition: weather.currentWeather?.condition,
    );
    
    if (rec != null && mounted) {
      setState(() => _currentImageRec = rec);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已保存到历史记录'),
          backgroundColor: Color(0xFF6B9DFF),
        ),
      );
    }
  }

  void _toggleFavorite(Recommendation rec) {
    context.read<RecommendationProvider>().toggleFavorite(rec.id);
    _loadRecommendations();
  }

  void _openProjectUrl() {
    // TODO: 打开 LiblibAI 项目链接
  }

  void _showHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => _buildHistorySheet(scrollController),
      ),
    );
  }

  Widget _buildHistorySheet(ScrollController scrollController) {
    return Consumer<RecommendationProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // 标题栏
              Row(
                children: [
                  Text('推荐历史', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  if (provider.hasRecommendations)
                    TextButton(
                      onPressed: () => _confirmClearAll(provider),
                      child: Text('清空', style: TextStyle(color: Colors.red[400])),
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              // 列表
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B9D)))
                    : !provider.hasRecommendations
                        ? _buildEmptyHistory()
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: provider.recommendations.length,
                            itemBuilder: (context, index) {
                              final rec = provider.recommendations[index];
                              return _buildHistoryItem(rec, provider);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text('暂无推荐记录', style: TextStyle(fontSize: 16.sp, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Recommendation rec, RecommendationProvider provider) {
    return Dismissible(
      key: Key(rec.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => provider.deleteRecommendation(rec.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16.w),
        color: Colors.red[400],
        child: Icon(Icons.delete, color: Colors.white, size: 24.sp),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: rec.type == 'text' 
                    ? const Color(0xFFFF6B9D).withOpacity(0.1)
                    : const Color(0xFF6B9DFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                rec.type == 'text' ? Icons.auto_awesome : Icons.image,
                color: rec.type == 'text' ? const Color(0xFFFF6B9D) : const Color(0xFF6B9DFF),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rec.type == 'text' ? '文字推荐' : '穿搭参考图',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _formatDate(rec.createdAt),
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                rec.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: rec.isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: () => provider.toggleFavorite(rec.id),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    
    return '${date.month}月${date.day}日';
  }

  void _confirmClearAll(RecommendationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有推荐记录吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.clearAll(context.read<UserProvider>().userId!);
            },
            child: Text('清空', style: TextStyle(color: Colors.red[400])),
          ),
        ],
      ),
    );
  }
}
