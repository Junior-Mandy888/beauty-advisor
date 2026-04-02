/// 用户档案模型
class UserProfile {
  final String userId;
  final String? nickname;
  final String? avatarUrl;
  final String? faceShape;
  final int? age;
  final String? gender;
  final String? city;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  UserProfile({
    required this.userId,
    this.nickname,
    this.avatarUrl,
    this.faceShape,
    this.age,
    this.gender,
    this.city,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'],
      nickname: json['nickname'],
      avatarUrl: json['avatar_url'],
      faceShape: json['face_shape'],
      age: json['age'],
      gender: json['gender'],
      city: json['city'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'nickname': nickname,
      'avatar_url': avatarUrl,
      'face_shape': faceShape,
      'age': age,
      'gender': gender,
      'city': city,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  UserProfile copyWith({
    String? userId,
    String? nickname,
    String? avatarUrl,
    String? faceShape,
    int? age,
    String? gender,
    String? city,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      faceShape: faceShape ?? this.faceShape,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
