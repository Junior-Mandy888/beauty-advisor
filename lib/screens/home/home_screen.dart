import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:beauty_advisor/providers/user_provider.dart';
import 'package:beauty_advisor/providers/weather_provider.dart';
import 'package:beauty_advisor/providers/wardrobe_provider.dart';
import 'package:beauty_advisor/models/wardrobe_item.dart';
import 'package:beauty_advisor/services/weather_service.dart';
import 'package:beauty_advisor/widgets/loading_animation.dart';
import 'package:beauty_advisor/widgets/brand_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInitialized = false;
  String? _lastCity;
  bool _showGuide = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final userProvider = context.read<UserProvider>();
    _lastCity = userProvider.city;
    
    if (userProvider.userId != null && mounted) {
      final wardrobeProvider = context.read<WardrobeProvider>();
      await wardrobeProvider.setUserId(userProvider.userId!);
    }

    if (mounted) {
      _loadWeather(_lastCity);
      _checkGuideStatus();
    }
  }
  
  void _checkGuideStatus() {
    final userProvider = context.read<UserProvider>();
    final wardrobeProvider = context.read<WardrobeProvider>();
    
    // 如果没有脸型数据或衣橱为空，显示引导
    final hasFaceData = userProvider.faceShape != null;
    final hasWardrobe = wardrobeProvider.totalCount > 0;
    
    setState(() {
      _showGuide = !hasFaceData || !hasWardrobe;
    });
  }
  
  void _onCityChanged(String? newCity) {
    if (_lastCity != newCity && _isInitialized) {
      _lastCity = newCity;
      _loadWeather(newCity);
    }
  }

  Future<void> _loadWeather(String? city) async {
    final weatherProvider = context.read<WeatherProvider>();
    final cityName = city ?? '广州';
    
    try {
      weatherProvider.setLocation(cityName);
      
      final weather = await WeatherService.getWeatherByCity(cityName);
      weatherProvider.updateWeather(WeatherData(
        condition: weather.condition,
        temperature: weather.temperature,
        humidity: weather.humidity,
        windDirection: weather.windDirection,
        windSpeed: weather.windSpeed,
      ));
    } catch (e) {
      debugPrint('获取天气失败: $e');
      weatherProvider.updateWeather(WeatherData(
        condition: '晴',
        temperature: 25,
        humidity: 60,
        windDirection: '东风',
        windSpeed: 2.5,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('美妆穿搭顾问'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () async {
              final currentCity = context.read<UserProvider>().city;
              await context.push('/profile');
              // 返回后检查城市是否变化
              if (mounted) {
                final newCity = context.read<UserProvider>().city;
                if (currentCity != newCity) {
                  _onCityChanged(newCity);
                }
                _checkGuideStatus();
              }
            },
            tooltip: '个人中心',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer2<UserProvider, WeatherProvider>(
          builder: (context, user, weather, child) {
            if (user.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const BrandLoadingIndicator(size: 32),
                    SizedBox(height: 16.h),
                    Text('正在初始化...', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                  ],
                ),
              );
            }
            
            return RefreshIndicator(
              onRefresh: () async {
                final userProvider = context.read<UserProvider>();
                await userProvider.reload();
                if (userProvider.userId != null && mounted) {
                  await context.read<WardrobeProvider>().loadWardrobe();
                }
                _loadWeather(userProvider.city);
                _checkGuideStatus();
              },
              color: const Color(0xFFFF6B9D),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(user),
                    SizedBox(height: 24.h),
                    if (_showGuide) _buildGuideCard(user),
                    if (_showGuide) SizedBox(height: 24.h),
                    _buildWeatherCard(weather),
                    SizedBox(height: 24.h),
                    _buildQuickActions(context),
                    SizedBox(height: 24.h),
                    _buildTodayRecommendation(context, user),
                    SizedBox(height: 24.h),
                    _buildWardrobeSummary(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildGreeting(UserProvider user) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = '早上好';
    } else if (hour < 18) {
      greeting = '下午好';
    } else {
      greeting = '晚上好';
    }
    
    final nickname = user.nickname ?? '小主';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting，$nickname',
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Text('今天想变美吗？让我来帮你', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
      ],
    );
  }
  
  Widget _buildGuideCard(UserProvider user) {
    return Consumer<WardrobeProvider>(
      builder: (context, wardrobe, _) {
        final hasFaceData = user.faceShape != null;
        final hasWardrobe = wardrobe.totalCount > 0;
        
        // 如果都完成了，不显示引导卡片
        if (hasFaceData && hasWardrobe) {
          return const SizedBox.shrink();
        }
        
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.tips_and_updates, color: const Color(0xFFFF6B9D), size: 24.sp),
                  SizedBox(width: 8.w),
                  Text('完善信息，获取更精准推荐', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 16.h),
              if (!hasFaceData) _buildGuideItem(
                icon: Icons.face_retouching_natural,
                title: '脸型分析',
                description: '上传照片，AI 分析您的脸型',
                onTap: () => context.push('/face-analysis'),
                completed: false,
              ),
              if (!hasFaceData && !hasWardrobe) SizedBox(height: 12.h),
              if (!hasWardrobe) _buildGuideItem(
                icon: Icons.checkroom,
                title: '添加衣物',
                description: '记录您的衣橱，推荐更精准',
                onTap: () => context.push('/wardrobe'),
                completed: false,
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildGuideItem({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required bool completed,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: completed ? Colors.green[50] : const Color(0xFFFF6B9D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                completed ? Icons.check : icon,
                size: 24.sp,
                color: completed ? Colors.green : const Color(0xFFFF6B9D),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 2.h),
                  Text(description, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20.sp, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeatherCard(WeatherProvider weather) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFFFFB6C1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(weather.location ?? '广州', style: TextStyle(fontSize: 14.sp, color: Colors.white70)),
                SizedBox(height: 8.h),
                Text(
                  weather.currentWeather != null ? '${weather.currentWeather!.temperature.toInt()}°C' : '--°C',
                  style: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  weather.currentWeather?.condition ?? '获取中...',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white),
                ),
              ],
            ),
          ),
          _buildWeatherIcon(weather.currentWeather?.condition ?? '晴'),
        ],
      ),
    );
  }
  
  /// 根据天气条件返回对应图标
  Widget _buildWeatherIcon(String condition) {
    final config = WeatherIconConfig.forCondition(condition);
    return Icon(config.icon, size: 64.sp, color: Colors.white70);
  }
  
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('快捷功能', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h),
        // 第一行
        Row(
          children: [
            BrandIconButton(
              icon: FeatureIconConfig.faceAnalysis.icon,
              label: FeatureIconConfig.faceAnalysis.label,
              onTap: () => context.push('/face-analysis'),
              iconColor: FeatureIconConfig.faceAnalysis.color,
            ),
            SizedBox(width: 12.w),
            BrandIconButton(
              icon: FeatureIconConfig.wardrobe.icon,
              label: FeatureIconConfig.wardrobe.label,
              onTap: () => context.push('/wardrobe'),
              iconColor: FeatureIconConfig.wardrobe.color,
            ),
            SizedBox(width: 12.w),
            BrandIconButton(
              icon: FeatureIconConfig.recommendation.icon,
              label: FeatureIconConfig.recommendation.label,
              onTap: () => context.push('/recommendation'),
              iconColor: FeatureIconConfig.recommendation.color,
            ),
            SizedBox(width: 12.w),
            BrandIconButton(
              icon: FeatureIconConfig.hairstyle.icon,
              label: FeatureIconConfig.hairstyle.label,
              onTap: () => context.push('/hairstyle'),
              iconColor: FeatureIconConfig.hairstyle.color,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // 第二行
        Row(
          children: [
            BrandIconButton(
              icon: FeatureIconConfig.makeup.icon,
              label: FeatureIconConfig.makeup.label,
              onTap: () => context.push('/makeup'),
              iconColor: FeatureIconConfig.makeup.color,
            ),
            SizedBox(width: 12.w),
            BrandIconButton(
              icon: FeatureIconConfig.virtualTryOn.icon,
              label: FeatureIconConfig.virtualTryOn.label,
              onTap: () => context.push('/virtual-tryon'),
              iconColor: FeatureIconConfig.virtualTryOn.color,
            ),
            SizedBox(width: 12.w),
            BrandIconButton(
              icon: FeatureIconConfig.community.icon,
              label: FeatureIconConfig.community.label,
              onTap: () => context.push('/community'),
              iconColor: FeatureIconConfig.community.color,
            ),
            SizedBox(width: 12.w),
            BrandIconButton(
              icon: FeatureIconConfig.favorite.icon,
              label: FeatureIconConfig.favorite.label,
              onTap: () => context.push('/recommendation'),
              iconColor: FeatureIconConfig.favorite.color,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTodayRecommendation(BuildContext context, UserProvider user) {
    final hasFaceData = user.faceShape != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('今日推荐', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12.r)),
          child: Column(
            children: [
              Icon(Icons.auto_awesome, size: 48.sp, color: const Color(0xFFFF6B9D)),
              SizedBox(height: 12.h),
              Text(
                hasFaceData ? '脸型: ${user.faceShape}' : '还没有进行脸型分析',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => context.push(hasFaceData ? '/recommendation' : '/face-analysis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B9D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                ),
                child: Text(hasFaceData ? '获取推荐' : '开始分析'),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildWardrobeSummary(BuildContext context) {
    return Consumer<WardrobeProvider>(
      builder: (context, wardrobe, _) {
        final totalCount = wardrobe.totalCount;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('衣橱统计', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12.r)),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 12.h,
                children: [
                  _buildStatItem('总数', totalCount.toString(), Icons.inventory_2_rounded, const Color(0xFF95A5A6)),
                  _buildStatItem('上衣', wardrobe.getByCategory(WardrobeCategory.top).length.toString(), 
                    CategoryIconConfig.forCategory('top').icon, CategoryIconConfig.forCategory('top').color),
                  _buildStatItem('裤装', wardrobe.getByCategory(WardrobeCategory.bottom).length.toString(),
                    CategoryIconConfig.forCategory('bottom').icon, CategoryIconConfig.forCategory('bottom').color),
                  _buildStatItem('裙装', wardrobe.getByCategory(WardrobeCategory.dress).length.toString(),
                    CategoryIconConfig.forCategory('dress').icon, CategoryIconConfig.forCategory('dress').color),
                  _buildStatItem('鞋子', wardrobe.getByCategory(WardrobeCategory.shoes).length.toString(),
                    CategoryIconConfig.forCategory('shoes').icon, CategoryIconConfig.forCategory('shoes').color),
                  _buildStatItem('配饰', wardrobe.getByCategory(WardrobeCategory.accessory).length.toString(),
                    CategoryIconConfig.forCategory('accessory').icon, CategoryIconConfig.forCategory('accessory').color),
                ],
              ),
            ),
            if (totalCount == 0)
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Text(
                  '添加衣物到衣橱，获取更精准的穿搭推荐',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                ),
              ),
          ],
        );
      },
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return SizedBox(
      width: 56.w,
      child: Column(
        children: [
          Icon(icon, size: 22.sp, color: color),
          SizedBox(height: 4.h),
          Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
