import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// 空状态组件
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final String? routePath;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.buttonText,
    this.onButtonPressed,
    this.routePath,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B9D).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48.sp,
                color: const Color(0xFFFF6B9D),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (description != null) ...[
              SizedBox(height: 12.h),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
            if (buttonText != null) ...[
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: onButtonPressed ?? (routePath != null ? () => context.push(routePath!) : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B9D),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 衣橱为空状态
class EmptyWardrobeState extends StatelessWidget {
  const EmptyWardrobeState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.checkroom,
      title: '衣橱空空如也',
      description: '添加您的衣物，AI 会根据衣橱为您推荐更精准的穿搭',
      buttonText: '添加衣物',
      routePath: '/wardrobe',
    );
  }
}

/// 无推荐历史状态
class EmptyRecommendationsState extends StatelessWidget {
  const EmptyRecommendationsState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.auto_awesome,
      title: '暂无推荐记录',
      description: '去获取 AI 穿搭推荐吧',
      buttonText: '获取推荐',
      routePath: '/recommendation',
    );
  }
}

/// 无收藏状态
class EmptyFavoritesState extends StatelessWidget {
  const EmptyFavoritesState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.favorite_border,
      title: '暂无收藏',
      description: '在推荐页面点击收藏，喜欢的推荐会保存在这里',
      buttonText: '去推荐',
      routePath: '/recommendation',
    );
  }
}

/// 未进行脸型分析状态
class NoFaceAnalysisState extends StatelessWidget {
  const NoFaceAnalysisState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.face_retouching_natural,
      title: '还未进行脸型分析',
      description: '上传一张正面照片，AI 会为您分析脸型',
      buttonText: '开始分析',
      routePath: '/face-analysis',
    );
  }
}
