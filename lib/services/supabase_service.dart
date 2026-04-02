import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:beauty_advisor/config/app_config.dart';
import 'package:beauty_advisor/models/user_profile.dart';

/// Supabase 服务
class SupabaseService {
  static final SupabaseClient _client = SupabaseClient(
    AppConfig.supabaseUrl,
    AppConfig.supabaseKey,
  );
  
  static SupabaseClient get client => _client;
  
  /// 初始化 Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseKey,
    );
  }
  
  /// 获取当前用户
  static User? get currentUser => Supabase.instance.client.auth.currentUser;
  
  /// 获取当前用户ID
  static String? get currentUserId => currentUser?.id;
  
  /// 匿名登录
  static Future<AuthResponse> signInAnonymously() async {
    return await _client.auth.signInAnonymously();
  }
  
  /// 检查是否已登录
  static bool get isAuthenticated => currentUser != null;
  
  // ============ 用户档案 ============
  
  /// 获取用户档案
  static Future<UserProfile?> getUserProfile(String userId) async {
    final response = await _client
        .from('user_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    
    if (response == null) return null;
    return UserProfile.fromJson(response);
  }
  
  /// 保存用户档案
  static Future<void> saveUserProfile(Map<String, dynamic> profileData) async {
    await _client.from('user_profiles').upsert(profileData);
  }
  
  /// 创建用户档案
  static Future<void> createUserProfile({
    required String userId,
    String? nickname,
    String? city,
  }) async {
    final now = DateTime.now();
    final profile = UserProfile(
      userId: userId,
      nickname: nickname ?? '用户${userId.substring(0, 8)}',
      city: city,
      createdAt: now,
      updatedAt: now,
    );
    await saveUserProfile(profile.toJson());
  }
  
  // ============ 衣橱 ============
  
  /// 保存衣橱物品
  static Future<void> saveWardrobeItem(Map<String, dynamic> item) async {
    await _client.from('wardrobe').insert(item);
  }
  
  /// 获取衣橱数据
  static Future<List<Map<String, dynamic>>> getWardrobe(String userId) async {
    final response = await _client
        .from('wardrobe')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
  
  /// 更新衣橱物品
  static Future<void> updateWardrobeItem(Map<String, dynamic> item) async {
    await _client.from('wardrobe').upsert(item);
  }
  
  /// 删除衣橱物品
  static Future<void> deleteWardrobeItem(String itemId) async {
    await _client.from('wardrobe').delete().eq('id', itemId);
  }
  
  // ============ Storage (图片) ============
  
  /// 上传衣橱图片
  static Future<void> uploadWardrobeImage(String fileName, String base64Data) async {
    final bytes = base64Decode(base64Data);
    await _client.storage.from('wardrobe-images').uploadBinary(
      fileName,
      bytes,
    );
  }
  
  /// 获取衣橱图片公开URL
  static String getWardrobeImageUrl(String fileName) {
    return _client.storage.from('wardrobe-images').getPublicUrl(fileName);
  }
  
  /// 删除衣橱图片
  static Future<void> deleteWardrobeImage(String fileName) async {
    await _client.storage.from('wardrobe-images').remove([fileName]);
  }
  
  // ============ 推荐记录 ============
  
  /// 保存推荐记录
  static Future<void> saveRecommendation(Map<String, dynamic> recommendation) async {
    await _client.from('recommendations').insert(recommendation);
  }
  
  /// 获取推荐记录
  static Future<List<Map<String, dynamic>>> getRecommendations(String userId, {int limit = 20}) async {
    final response = await _client
        .from('recommendations')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }
  
  /// 收藏推荐
  static Future<void> favoriteRecommendation(String recommendationId, bool isFavorite) async {
    await _client.from('recommendations').update({
      'is_favorite': isFavorite,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', recommendationId);
  }
}