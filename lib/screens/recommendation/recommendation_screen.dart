import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:beauty_advisor/providers/user_provider.dart';
import 'package:beauty_advisor/providers/weather_provider.dart';
import 'package:beauty_advisor/services/deepseek_service.dart';
import 'package:beauty_advisor/services/liblib_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('智能推荐'),
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
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            _textRecommendation!,
            style: TextStyle(fontSize: 14.sp, height: 1.6),
          ),
        ],
      ),
    );
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
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingText = false;
      });
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

  void _openProjectUrl() {
    // TODO: 打开 LiblibAI 项目链接
  }
}
