import 'package:flutter/foundation.dart';

/// 商品来源平台
enum ProductPlatform {
  taobao,    // 淘宝
  jd,        // 京东
  pdd,       // 拼多多
  vip,       // 唯品会
}

/// 商品分类
enum ProductCategory {
  makeup,    // 美妆
  skincare,  // 护肤
  clothing,  // 服饰
  accessory, // 配饰
  shoes,     // 鞋子
}

/// 商品模型
class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final String platform;
  final String? platformIcon;
  final String affiliateUrl;
  final String? coupon;
  final double? commission; // 佣金比例
  final ProductCategory category;
  final double rating;
  final int sales;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    required this.platform,
    this.platformIcon,
    required this.affiliateUrl,
    this.coupon,
    this.commission,
    required this.category,
    this.rating = 4.5,
    this.sales = 0,
  });

  double get discount {
    if (originalPrice == null || originalPrice! <= 0) return 0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['original_price'] != null 
          ? (json['original_price'] as num).toDouble() 
          : null,
      platform: json['platform'] as String,
      platformIcon: json['platform_icon'] as String?,
      affiliateUrl: json['affiliate_url'] as String,
      coupon: json['coupon'] as String?,
      commission: json['commission'] != null 
          ? (json['commission'] as num).toDouble() 
          : null,
      category: ProductCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => ProductCategory.clothing,
      ),
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 4.5,
      sales: json['sales'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'original_price': originalPrice,
      'platform': platform,
      'platform_icon': platformIcon,
      'affiliate_url': affiliateUrl,
      'coupon': coupon,
      'commission': commission,
      'category': category.name,
      'rating': rating,
      'sales': sales,
    };
  }
}
