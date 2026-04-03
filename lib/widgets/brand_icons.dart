import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 品牌图标组件 - 使用统一的图标风格
class BrandIcon extends StatelessWidget {
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final double borderRadius;

  const BrandIcon({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.size = 44,
    this.iconSize = 24,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFFF6B9D).withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
      child: Icon(
        icon,
        size: iconSize.sp,
        color: iconColor ?? const Color(0xFFFF6B9D),
      ),
    );
  }
}

/// 图标按钮组件
class BrandIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? labelColor;

  const BrandIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey[100],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              BrandIcon(
                icon: icon,
                iconColor: iconColor,
                backgroundColor: backgroundColor == null 
                    ? const Color(0xFFFF6B9D).withOpacity(0.1) 
                    : backgroundColor?.withOpacity(0.2),
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: labelColor ?? Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 分类图标配置
class CategoryIconConfig {
  final IconData icon;
  final Color color;
  final String label;

  const CategoryIconConfig({
    required this.icon,
    required this.color,
    required this.label,
  });

  static CategoryIconConfig forCategory(String category) {
    switch (category) {
      case 'top':
        return const CategoryIconConfig(
          icon: Icons.checkroom_rounded,
          color: Color(0xFFFF6B9D),
          label: '上衣',
        );
      case 'bottom':
        return const CategoryIconConfig(
          icon: Icons.straighten_rounded,
          color: Color(0xFF6B9DFF),
          label: '裤装',
        );
      case 'dress':
        return const CategoryIconConfig(
          icon: Icons.local_mall_rounded,
          color: Color(0xFFFFB347),
          label: '裙装',
        );
      case 'shoes':
        return const CategoryIconConfig(
          icon: Icons.directions_walk_rounded,
          color: Color(0xFF9B59B6),
          label: '鞋子',
        );
      case 'accessory':
        return const CategoryIconConfig(
          icon: Icons.diamond_rounded,
          color: Color(0xFF1ABC9C),
          label: '配饰',
        );
      default:
        return const CategoryIconConfig(
          icon: Icons.inventory_2_rounded,
          color: Color(0xFF95A5A6),
          label: '其他',
        );
    }
  }
}

/// 功能图标配置
class FeatureIconConfig {
  final IconData icon;
  final Color color;
  final String label;

  const FeatureIconConfig({
    required this.icon,
    required this.color,
    required this.label,
  });

  static FeatureIconConfig get faceAnalysis => const FeatureIconConfig(
    icon: Icons.face_retouching_natural_rounded,
    color: Color(0xFFFF6B9D),
    label: '脸型分析',
  );

  static FeatureIconConfig get wardrobe => const FeatureIconConfig(
    icon: Icons.checkroom_rounded,
    color: Color(0xFF6B9DFF),
    label: '我的衣橱',
  );

  static FeatureIconConfig get recommendation => const FeatureIconConfig(
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFFFFB347),
    label: '智能推荐',
  );

  static FeatureIconConfig get profile => const FeatureIconConfig(
    icon: Icons.person_rounded,
    color: Color(0xFF9B59B6),
    label: '个人中心',
  );

  static FeatureIconConfig get favorite => const FeatureIconConfig(
    icon: Icons.favorite_rounded,
    color: Color(0xFFE74C3C),
    label: '收藏',
  );

  static FeatureIconConfig get history => const FeatureIconConfig(
    icon: Icons.history_rounded,
    color: Color(0xFF3498DB),
    label: '历史',
  );

  static FeatureIconConfig get weather => const FeatureIconConfig(
    icon: Icons.wb_sunny_rounded,
    color: Color(0xFFF39C12),
    label: '天气',
  );

  static FeatureIconConfig get settings => const FeatureIconConfig(
    icon: Icons.settings_rounded,
    color: Color(0xFF95A5A6),
    label: '设置',
  );

  static FeatureIconConfig get hairstyle => const FeatureIconConfig(
    icon: Icons.face_rounded,
    color: Color(0xFFE91E63),
    label: '发型推荐',
  );

  static FeatureIconConfig get makeup => const FeatureIconConfig(
    icon: Icons.brush_rounded,
    color: Color(0xFF9C27B0),
    label: '妆容教程',
  );

  static FeatureIconConfig get virtualTryOn => const FeatureIconConfig(
    icon: Icons.try_sms_star_rounded,
    color: Color(0xFF00BCD4),
    label: '虚拟试衣',
  );

  static FeatureIconConfig get community => const FeatureIconConfig(
    icon: Icons.forum_rounded,
    color: Color(0xFF4CAF50),
    label: '美妆社区',
  );
}

/// 天气图标配置
class WeatherIconConfig {
  final IconData icon;
  final Color color;

  const WeatherIconConfig({required this.icon, required this.color});

  static WeatherIconConfig forCondition(String condition) {
    switch (condition) {
      case '晴':
        return const WeatherIconConfig(
          icon: Icons.wb_sunny_rounded,
          color: Color(0xFFF39C12),
        );
      case '多云':
        return const WeatherIconConfig(
          icon: Icons.wb_cloudy_rounded,
          color: Color(0xFF85C1E9),
        );
      case '阴':
        return const WeatherIconConfig(
          icon: Icons.cloud_rounded,
          color: Color(0xFF95A5A6),
        );
      case '小雨':
      case '中雨':
      case '大雨':
      case '阵雨':
      case '暴雨':
        return const WeatherIconConfig(
          icon: Icons.grain_rounded,
          color: Color(0xFF3498DB),
        );
      case '雷阵雨':
      case '雷阵雨伴冰雹':
        return const WeatherIconConfig(
          icon: Icons.flash_on_rounded,
          color: Color(0xFF9B59B6),
        );
      case '小雪':
      case '中雪':
      case '大雪':
      case '阵雪':
        return const WeatherIconConfig(
          icon: Icons.ac_unit_rounded,
          color: Color(0xFF85C1E9),
        );
      case '雾':
      case '霜雾':
        return const WeatherIconConfig(
          icon: Icons.blur_on_rounded,
          color: Color(0xFF95A5A6),
        );
      default:
        return const WeatherIconConfig(
          icon: Icons.wb_sunny_rounded,
          color: Color(0xFFF39C12),
        );
    }
  }
}
