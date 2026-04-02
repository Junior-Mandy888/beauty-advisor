import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 加载动画组件
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final Color? color;

  const LoadingOverlay({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LoadingAnimation(color: color ?? const Color(0xFFFF6B9D)),
              if (message != null) ...[
                SizedBox(height: 16.h),
                Text(
                  message!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 品牌加载动画
class _LoadingAnimation extends StatefulWidget {
  final Color color;

  const _LoadingAnimation({required this.color});

  @override
  State<_LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<_LoadingAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 48.w,
          height: 48.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 外圈
              Transform.rotate(
                angle: _controller.value * 2 * 3.14159,
                child: SizedBox(
                  width: 48.w,
                  height: 48.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    value: 0.7,
                    color: widget.color,
                    backgroundColor: widget.color.withOpacity(0.2),
                  ),
                ),
              ),
              // 中心图标
              Text('✨', style: TextStyle(fontSize: 20.sp)),
            ],
          ),
        );
      },
    );
  }
}

/// 简单加载指示器
class BrandLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const BrandLoadingIndicator({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation(color ?? const Color(0xFFFF6B9D)),
      ),
    );
  }
}

/// 骨架屏加载效果
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width.w,
          height: widget.height.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[200]!,
                Colors.grey[100]!,
                Colors.grey[200]!,
              ],
              stops: [
                0.0,
                0.5 + _animation.value * 0.25,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 推荐卡片骨架屏
class RecommendationShimmer extends StatelessWidget {
  const RecommendationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              ShimmerLoading(width: 20, height: 20, borderRadius: 10),
              SizedBox(width: 8.w),
              ShimmerLoading(width: 80, height: 16, borderRadius: 4),
            ],
          ),
          SizedBox(height: 16.h),
          ShimmerLoading(width: double.infinity, height: 14, borderRadius: 4),
          SizedBox(height: 8.h),
          ShimmerLoading(width: 250, height: 14, borderRadius: 4),
          SizedBox(height: 8.h),
          ShimmerLoading(width: 200, height: 14, borderRadius: 4),
        ],
      ),
    );
  }
}

/// 图片骨架屏
class ImageShimmer extends StatelessWidget {
  final double height;

  const ImageShimmer({super.key, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      width: double.infinity,
      height: height,
      borderRadius: 12,
    );
  }
}
