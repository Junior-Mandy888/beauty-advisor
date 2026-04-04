/// 虚拟试衣任务状态
enum VirtualTryOnStatus {
  pending,    // 等待中
  processing, // 处理中
  completed,  // 已完成
  failed,     // 失败
}

/// 虚拟试衣结果
class VirtualTryOnResult {
  final String id;
  final String userId;
  final String originalImageUrl;
  final String? outfitImageUrl;
  final String? outfitDescription;
  final VirtualTryOnStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? error;

  const VirtualTryOnResult({
    required this.id,
    required this.userId,
    required this.originalImageUrl,
    this.outfitImageUrl,
    this.outfitDescription,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.error,
  });

  bool get isSuccess => status == VirtualTryOnStatus.completed && outfitImageUrl != null;

  factory VirtualTryOnResult.fromJson(Map<String, dynamic> json) {
    return VirtualTryOnResult(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      originalImageUrl: json['original_image_url'] as String,
      outfitImageUrl: json['outfit_image_url'] as String?,
      outfitDescription: json['outfit_description'] as String?,
      status: VirtualTryOnStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => VirtualTryOnStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String) 
          : null,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'original_image_url': originalImageUrl,
      'outfit_image_url': outfitImageUrl,
      'outfit_description': outfitDescription,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'error': error,
    };
  }
}

/// 穿搭风格
enum OutfitStyle {
  casual,     // 休闲风
  formal,     // 正式风
  sweet,      // 甜美风
  cool,       // 酷帅风
  vintage,    // 复古风
  korean,     // 韩系
  japanese,   // 日系
  minimalist, // 极简风
  sporty,     // 运动风
}
