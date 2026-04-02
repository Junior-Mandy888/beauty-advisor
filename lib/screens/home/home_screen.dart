import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beauty_advisor/providers/user_provider.dart';
import 'package:beauty_advisor/providers/weather_provider.dart';
import 'package:beauty_advisor/providers/wardrobe_provider.dart';
import 'package:beauty_advisor/models/wardrobe_item.dart';
import 'package:beauty_advisor/services/weather_service.dart';

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
      _checkOnboardingAndInitialize();
    });
  }
  
  Future<void> _checkOnboardingAndInitialize() async {
    // 检查是否完成引导
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    
    if (!onboardingCompleted && mounted) {
      context.push('/onboarding');
      return;
    }
    
    await _initialize();
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
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFFF6B9D)),
                    SizedBox(height: 16),
                    Text('正在初始化...'),
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
    IconData iconData;
    switch (condition) {
      case '晴':
        iconData = Icons.wb_sunny;
        break;
      case '多云':
        iconData = Icons.wb_cloudy;
        break;
      case '阴':
        iconData = Icons.cloud;
        break;
      case '小雨':
      case '中雨':
      case '大雨':
      case '阵雨':
      case '暴雨':
        iconData = Icons.grain;
        break;
      case '雷阵雨':
      case '雷阵雨伴冰雹':
        iconData = Icons.flash_on;
        break;
      case '小雪':
      case '中雪':
      case '大雪':
      case '阵雪':
        iconData = Icons.ac_unit;
        break;
      case '雾':
      case '霜雾':
        iconData = Icons.blur_on;
        break;
      default:
        iconData = Icons.wb_sunny;
    }
    return Icon(iconData, size: 64.sp, color: Colors.white70);
  }
  
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('快捷功能', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h),
        Row(
          children: [
            _buildActionButton(icon: Icons.face, label: '脸型分析', onTap: () => context.push('/face-analysis')),
            SizedBox(width: 16.w),
            _buildActionButton(icon: Icons.checkroom, label: '我的衣橱', onTap: () => context.push('/wardrobe')),
            SizedBox(width: 16.w),
            _buildActionButton(icon: Icons.auto_awesome, label: '智能推荐', onTap: () => context.push('/recommendation')),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12.r)),
          child: Column(
            children: [
              Icon(icon, size: 32.sp, color: const Color(0xFFFF6B9D)),
              SizedBox(height: 8.h),
              Text(label, style: TextStyle(fontSize: 12.sp)),
            ],
          ),
        ),
      ),
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
                  _buildStatItem('总数', totalCount.toString(), Icons.inventory_2),
                  _buildStatItem('衣服', wardrobe.getByCategory(WardrobeCategory.top).length.toString(), Icons.checkroom),
                  _buildStatItem('裤子', wardrobe.getByCategory(WardrobeCategory.bottom).length.toString(), Icons.straighten),
                  _buildStatItem('裙子', wardrobe.getByCategory(WardrobeCategory.dress).length.toString(), Icons.local_mall),
                  _buildStatItem('鞋子', wardrobe.getByCategory(WardrobeCategory.shoes).length.toString(), Icons.hiking),
                  _buildStatItem('配饰', wardrobe.getByCategory(WardrobeCategory.accessory).length.toString(), Icons.diamond),
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
  
  Widget _buildStatItem(String label, String value, IconData icon) {
    return SizedBox(
      width: 56.w,
      child: Column(
        children: [
          Icon(icon, size: 22.sp, color: const Color(0xFFFF6B9D)),
          SizedBox(height: 4.h),
          Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
