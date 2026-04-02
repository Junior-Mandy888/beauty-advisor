import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 首次使用引导页面
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.face_retouching_natural,
      iconColor: const Color(0xFFFF6B9D),
      title: '脸型分析',
      subtitle: 'AI 智能识别您的脸型',
      description: '上传一张正面照片，AI 将分析您的脸型、年龄等信息',
    ),
    OnboardingPage(
      icon: Icons.checkroom,
      iconColor: const Color(0xFF6B9DFF),
      title: '衣橱管理',
      subtitle: '记录您的衣物穿搭',
      description: '添加您的衣服、裤子、鞋子等，让推荐更精准',
    ),
    OnboardingPage(
      icon: Icons.auto_awesome,
      iconColor: const Color(0xFFFFB347),
      title: '智能推荐',
      subtitle: '专属您的穿搭建议',
      description: '根据脸型、天气、衣橱，AI 为您生成个性化推荐',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skip() {
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      // 使用 push 而不是 go，这样用户可以返回首页
      context.push('/face-analysis');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 跳过按钮
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  '跳过',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                ),
              ),
            ),
            
            // 页面内容
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // 指示器
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildDot(index),
                ),
              ),
            ),
            
            // 按钮
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B9D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? '开始使用' : '下一步',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: page.iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                page.icon,
                size: 50.sp,
                color: page.iconColor,
              ),
            ),
            SizedBox(height: 32.h),
            
            // 标题
            Text(
              page.title,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            
            // 副标题
            Text(
              page.subtitle,
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFFFF6B9D),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.h),
            
            // 描述
            Text(
              page.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      width: _currentPage == index ? 24.w : 8.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFFFF6B9D)
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String description;

  const OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
