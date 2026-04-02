import 'package:flutter/foundation.dart';

/// 推荐记录模型
class Recommendation {
  final String id;
  final String userId;
  final String type; // 'text' 或 'image'
  final String content; // 文字推荐内容或图片URL
  final String? projectUrl; // LiblibAI 项目链接
  final String? faceShape;
  final String? weatherCondition;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Recommendation({
    required this.id,
    required this.userId,
    required this.type,
    required this.content,
    this.projectUrl,
    this.faceShape,
    this.weatherCondition,
    this.isFavorite = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      projectUrl: json['project_url'] as String?,
      faceShape: json['face_shape'] as String?,
      weatherCondition: json['weather_condition'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'content': content,
      'project_url': projectUrl,
      'face_shape': faceShape,
      'weather_condition': weatherCondition,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Recommendation copyWith({
    String? id,
    String? userId,
    String? type,
    String? content,
    String? projectUrl,
    String? faceShape,
    String? weatherCondition,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recommendation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      content: content ?? this.content,
      projectUrl: projectUrl ?? this.projectUrl,
      faceShape: faceShape ?? this.faceShape,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
