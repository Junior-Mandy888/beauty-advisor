import 'package:flutter/material.dart';

/// 会员等级
enum MembershipLevel {
  free,    // 免费用户
  pro,     // 专业版
  premium, // 高级版
}

/// 会员等级扩展
extension MembershipLevelExtension on MembershipLevel {
  String get name {
    switch (this) {
      case MembershipLevel.free:
        return '普通用户';
      case MembershipLevel.pro:
        return 'Pro会员';
      case MembershipLevel.premium:
        return 'Premium会员';
    }
  }

  String get shortName {
    switch (this) {
      case MembershipLevel.free:
        return '免费';
      case MembershipLevel.pro:
        return 'Pro';
      case MembershipLevel.premium:
        return 'Premium';
    }
  }
}

/// 会员权益
class MembershipBenefit {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isProOnly;
  final bool isPremiumOnly;

  const MembershipBenefit({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isProOnly = false,
    this.isPremiumOnly = false,
  });

  bool isAvailableFor(MembershipLevel level) {
    if (isPremiumOnly) {
      return level == MembershipLevel.premium;
    }
    if (isProOnly) {
      return level == MembershipLevel.pro || level == MembershipLevel.premium;
    }
    return true;
  }
}

/// 会员权益配置
class MembershipBenefits {
  static const List<MembershipBenefit> all = [
    // 免费用户权益
    MembershipBenefit(
      id: 'face_analysis_basic',
      title: '脸型分析',
      description: '每天3次免费分析',
      icon: Icons.face_retouching_natural,
    ),
    MembershipBenefit(
      id: 'wardrobe_basic',
      title: '衣橱管理',
      description: '最多保存20件衣物',
      icon: Icons.checkroom,
    ),
    MembershipBenefit(
      id: 'recommendation_basic',
      title: '穿搭推荐',
      description: '每天5次文字推荐',
      icon: Icons.auto_awesome,
    ),
    
    // Pro会员权益
    MembershipBenefit(
      id: 'face_analysis_unlimited',
      title: '无限脸型分析',
      description: '不限次数分析',
      icon: Icons.all_inclusive,
      isProOnly: true,
    ),
    MembershipBenefit(
      id: 'wardrobe_unlimited',
      title: '无限衣橱',
      description: '不限衣物数量',
      icon: Icons.inventory_2,
      isProOnly: true,
    ),
    MembershipBenefit(
      id: 'recommendation_unlimited',
      title: '无限推荐',
      description: '不限次数推荐',
      icon: Icons.auto_awesome,
      isProOnly: true,
    ),
    MembershipBenefit(
      id: 'image_recommendation',
      title: '穿搭参考图',
      description: '每天10张AI生成图',
      icon: Icons.image,
      isProOnly: true,
    ),
    MembershipBenefit(
      id: 'no_ads',
      title: '免广告',
      description: '清爽无广告体验',
      icon: Icons.block,
      isProOnly: true,
    ),
    
    // Premium会员权益
    MembershipBenefit(
      id: 'image_recommendation_unlimited',
      title: '无限参考图',
      description: '不限AI生成图片',
      icon: Icons.image,
      isPremiumOnly: true,
    ),
    MembershipBenefit(
      id: 'priority_support',
      title: '优先客服',
      description: '专属客服通道',
      icon: Icons.support_agent,
      isPremiumOnly: true,
    ),
    MembershipBenefit(
      id: 'advanced_analysis',
      title: '深度分析',
      description: '更详细的穿搭建议',
      icon: Icons.analytics,
      isPremiumOnly: true,
    ),
    MembershipBenefit(
      id: 'custom_style',
      title: '风格定制',
      description: 'AI学习你的风格',
      icon: Icons.tune,
      isPremiumOnly: true,
    ),
  ];

  /// 获取指定等级可用的权益
  static List<MembershipBenefit> getAvailableFor(MembershipLevel level) {
    return all.where((b) => b.isAvailableFor(level)).toList();
  }

  /// 获取指定等级新增的权益
  static List<MembershipBenefit> getNewBenefitsFor(MembershipLevel level) {
    switch (level) {
      case MembershipLevel.free:
        return all.where((b) => !b.isProOnly && !b.isPremiumOnly).toList();
      case MembershipLevel.pro:
        return all.where((b) => b.isProOnly && !b.isPremiumOnly).toList();
      case MembershipLevel.premium:
        return all.where((b) => b.isPremiumOnly).toList();
    }
  }
}

/// 会员价格
class MembershipPrice {
  final String id;
  final MembershipLevel level;
  final int months;
  final double originalPrice;
  final double currentPrice;
  final String? discountLabel;

  const MembershipPrice({
    required this.id,
    required this.level,
    required this.months,
    required this.originalPrice,
    required this.currentPrice,
    this.discountLabel,
  });

  double get discount => (originalPrice - currentPrice) / originalPrice * 100;
  
  double get monthlyPrice => currentPrice / months;
}
