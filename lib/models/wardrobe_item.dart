import 'dart:typed_data';

/// 衣橱物品分类
enum WardrobeCategory {
  top('衣服', 'top'),
  bottom('裤子', 'bottom'),
  dress('裙子', 'dress'),
  shoes('鞋子', 'shoes'),
  accessory('配饰', 'accessory');

  final String label;
  final String value;
  const WardrobeCategory(this.label, this.value);

  static WardrobeCategory fromValue(String value) {
    return WardrobeCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WardrobeCategory.top,
    );
  }
}

/// 衣橱物品模型
class WardrobeItem {
  final String id;
  final String userId;
  final WardrobeCategory category;
  final String name;
  final String? imageUrl;      // Supabase 存储的图片 URL
  final String? localImagePath; // 本地图片路径（备选）
  final String? color;
  final String? style;
  final String? season;
  final DateTime createdAt;
  final DateTime updatedAt;

  WardrobeItem({
    required this.id,
    required this.userId,
    required this.category,
    required this.name,
    this.imageUrl,
    this.localImagePath,
    this.color,
    this.style,
    this.season,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 JSON 创建（Supabase 返回）
  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      id: json['id'],
      userId: json['user_id'],
      category: WardrobeCategory.fromValue(json['category']),
      name: json['name'],
      imageUrl: json['image_url'],
      localImagePath: json['local_image_path'],
      color: json['color'],
      style: json['style'],
      season: json['season'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// 转换为 JSON（Supabase 存储）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category.value,
      'name': name,
      'image_url': imageUrl,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 从内存临时对象创建（用于添加时的临时对象）
  factory WardrobeItem.fromTemp({
    required String userId,
    required WardrobeCategory category,
    required String name,
    Uint8List? imageBytes,
    String? color,
    String? style,
    String? season,
  }) {
    final now = DateTime.now();
    return WardrobeItem(
      id: 'temp_${now.millisecondsSinceEpoch}',
      userId: userId,
      category: category,
      name: name,
      color: color,
      style: style,
      season: season,
      createdAt: now,
      updatedAt: now,
    );
  }

  WardrobeItem copyWith({
    String? id,
    String? userId,
    WardrobeCategory? category,
    String? name,
    String? imageUrl,
    String? localImagePath,
    String? color,
    String? style,
    String? season,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WardrobeItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      color: color ?? this.color,
      style: style ?? this.style,
      season: season ?? this.season,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}