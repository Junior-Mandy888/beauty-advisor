import 'package:flutter/foundation.dart';

/// 发型类型
enum HairstyleType {
  short,      // 短发
  medium,     // 中发
  long,       // 长发
  updo,       // 盘发
  ponytail,   // 马尾
  braid,      // 编发
  curly,      // 卷发
  straight,   // 直发
  bob,        // 波波头
  bangs,      // 刘海
}

/// 发型模型
class Hairstyle {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final HairstyleType type;
  final List<String> suitableFaceShapes; // 适合的脸型
  final List<String> suitableOccasions;   // 适合的场合
  final int difficulty; // 难度 1-5
  final int popularity; // 热度
  final String? tutorialUrl; // 教程链接

  const Hairstyle({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.suitableFaceShapes,
    this.suitableOccasions = const [],
    this.difficulty = 2,
    this.popularity = 0,
    this.tutorialUrl,
  });

  bool isSuitableFor(String faceShape) {
    return suitableFaceShapes.contains(faceShape) || 
           suitableFaceShapes.contains('all');
  }

  String get typeName {
    switch (type) {
      case HairstyleType.short: return '短发';
      case HairstyleType.medium: return '中发';
      case HairstyleType.long: return '长发';
      case HairstyleType.updo: return '盘发';
      case HairstyleType.ponytail: return '马尾';
      case HairstyleType.braid: return '编发';
      case HairstyleType.curly: return '卷发';
      case HairstyleType.straight: return '直发';
      case HairstyleType.bob: return '波波头';
      case HairstyleType.bangs: return '刘海';
    }
  }

  factory Hairstyle.fromJson(Map<String, dynamic> json) {
    return Hairstyle(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      type: HairstyleType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => HairstyleType.long,
      ),
      suitableFaceShapes: List<String>.from(json['suitable_face_shapes'] ?? []),
      suitableOccasions: List<String>.from(json['suitable_occasions'] ?? []),
      difficulty: json['difficulty'] as int? ?? 2,
      popularity: json['popularity'] as int? ?? 0,
      tutorialUrl: json['tutorial_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'type': type.name,
      'suitable_face_shapes': suitableFaceShapes,
      'suitable_occasions': suitableOccasions,
      'difficulty': difficulty,
      'popularity': popularity,
      'tutorial_url': tutorialUrl,
    };
  }
}
