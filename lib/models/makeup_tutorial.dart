/// 妆容风格
enum MakeupStyle {
  daily,      // 日常妆
  natural,    // 裸妆
  office,     // 职场妆
  date,       // 约会妆
  party,      // 派对妆
  wedding,    // 新娘妆
  korean,     // 韩妆
  japanese,   // 日妆
  western,    // 欧美妆
}

/// 妆容步骤
class MakeupStep {
  final int order;
  final String title;
  final String description;
  final String? imageUrl;
  final String? productRecommendation;
  final int durationMinutes;

  const MakeupStep({
    required this.order,
    required this.title,
    required this.description,
    this.imageUrl,
    this.productRecommendation,
    this.durationMinutes = 2,
  });

  factory MakeupStep.fromJson(Map<String, dynamic> json) {
    return MakeupStep(
      order: json['order'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      productRecommendation: json['product_recommendation'] as String?,
      durationMinutes: json['duration_minutes'] as int? ?? 2,
    );
  }
}

/// 妆容教程
class MakeupTutorial {
  final String id;
  final String name;
  final String description;
  final String coverImageUrl;
  final MakeupStyle style;
  final List<String> suitableFaceShapes;
  final List<MakeupStep> steps;
  final int totalDuration;
  final int difficulty;
  final List<String> products;
  final String? videoUrl;
  final int popularity;
  final double rating;

  const MakeupTutorial({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImageUrl,
    required this.style,
    this.suitableFaceShapes = const [],
    this.steps = const [],
    this.totalDuration = 15,
    this.difficulty = 2,
    this.products = const [],
    this.videoUrl,
    this.popularity = 0,
    this.rating = 4.5,
  });

  bool isSuitableFor(String faceShape) {
    return suitableFaceShapes.contains(faceShape) || 
           suitableFaceShapes.contains('all');
  }

  String get styleName {
    switch (style) {
      case MakeupStyle.daily: return '日常妆';
      case MakeupStyle.natural: return '裸妆';
      case MakeupStyle.office: return '职场妆';
      case MakeupStyle.date: return '约会妆';
      case MakeupStyle.party: return '派对妆';
      case MakeupStyle.wedding: return '新娘妆';
      case MakeupStyle.korean: return '韩妆';
      case MakeupStyle.japanese: return '日妆';
      case MakeupStyle.western: return '欧美妆';
    }
  }

  factory MakeupTutorial.fromJson(Map<String, dynamic> json) {
    return MakeupTutorial(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      coverImageUrl: json['cover_image_url'] as String,
      style: MakeupStyle.values.firstWhere(
        (s) => s.name == json['style'],
        orElse: () => MakeupStyle.daily,
      ),
      suitableFaceShapes: List<String>.from(json['suitable_face_shapes'] ?? []),
      steps: (json['steps'] as List?)
          ?.map((s) => MakeupStep.fromJson(s))
          .toList() ?? [],
      totalDuration: json['total_duration'] as int? ?? 15,
      difficulty: json['difficulty'] as int? ?? 2,
      products: List<String>.from(json['products'] ?? []),
      videoUrl: json['video_url'] as String?,
      popularity: json['popularity'] as int? ?? 0,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 4.5,
    );
  }
}
