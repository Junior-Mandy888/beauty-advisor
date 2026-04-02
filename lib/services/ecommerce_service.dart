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
}

/// 电商导流服务
class EcommerceService {
  static final EcommerceService _instance = EcommerceService._internal();
  factory EcommerceService() => _instance;
  EcommerceService._internal();

  /// 根据推荐内容获取相关商品
  Future<List<Product>> getRelatedProducts({
    required String faceShape,
    required String weather,
    required String recommendation,
  }) async {
    // TODO: 对接真实电商API（淘宝客、京东联盟等）
    // 模拟返回商品列表
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _getMockProducts();
  }

  /// 获取热门商品
  Future<List<Product>> getHotProducts(ProductCategory category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockProducts().where((p) => p.category == category).toList();
  }

  /// 生成推广链接
  Future<String?> generateAffiliateUrl({
    required String productId,
    required ProductPlatform platform,
  }) async {
    // TODO: 调用淘宝客/京东联盟API生成推广链接
    return 'https://example.com/product/$productId';
  }

  /// 模拟商品数据
  List<Product> _getMockProducts() {
    return [
      Product(
        id: 'p001',
        name: '优雅气质连衣裙',
        description: '适合圆脸型，显瘦修身款',
        imageUrl: 'https://example.com/dress1.jpg',
        price: 199,
        originalPrice: 399,
        platform: '淘宝',
        platformIcon: '🛒',
        affiliateUrl: 'https://taobao.com/item/1',
        coupon: '满200减20',
        commission: 0.05,
        category: ProductCategory.clothing,
        rating: 4.8,
        sales: 1280,
      ),
      Product(
        id: 'p002',
        name: '清透裸妆粉底液',
        description: '适合日常妆容，轻薄自然',
        imageUrl: 'https://example.com/makeup1.jpg',
        price: 89,
        originalPrice: 159,
        platform: '京东',
        platformIcon: '🛍️',
        affiliateUrl: 'https://jd.com/item/1',
        coupon: '限时5折',
        commission: 0.08,
        category: ProductCategory.makeup,
        rating: 4.9,
        sales: 3560,
      ),
      Product(
        id: 'p003',
        name: '复古珍珠耳环',
        description: '修饰脸型，提升气质',
        imageUrl: 'https://example.com/accessory1.jpg',
        price: 39,
        originalPrice: 79,
        platform: '拼多多',
        platformIcon: '🎁',
        affiliateUrl: 'https://pdd.com/item/1',
        commission: 0.10,
        category: ProductCategory.accessory,
        rating: 4.6,
        sales: 890,
      ),
      Product(
        id: 'p004',
        name: '保湿补水面膜套装',
        description: '换季护肤必备，深层补水',
        imageUrl: 'https://example.com/skincare1.jpg',
        price: 59,
        originalPrice: 99,
        platform: '淘宝',
        platformIcon: '🛒',
        affiliateUrl: 'https://taobao.com/item/2',
        coupon: '买二送一',
        commission: 0.06,
        category: ProductCategory.skincare,
        rating: 4.7,
        sales: 2340,
      ),
      Product(
        id: 'p005',
        name: '时尚小白鞋',
        description: '百搭款式，春秋必备',
        imageUrl: 'https://example.com/shoes1.jpg',
        price: 129,
        originalPrice: 259,
        platform: '京东',
        platformIcon: '🛍️',
        affiliateUrl: 'https://jd.com/item/2',
        commission: 0.04,
        category: ProductCategory.shoes,
        rating: 4.5,
        sales: 1890,
      ),
    ];
  }
}
