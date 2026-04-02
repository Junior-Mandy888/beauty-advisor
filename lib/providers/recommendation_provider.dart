import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:beauty_advisor/models/recommendation.dart';
import 'package:beauty_advisor/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 推荐历史状态管理 Provider
class RecommendationProvider extends ChangeNotifier {
  List<Recommendation> _recommendations = [];
  List<Recommendation> _favorites = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;

  // Getters
  List<Recommendation> get recommendations => _recommendations;
  List<Recommendation> get favorites => _favorites.where((r) => r.isFavorite).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasRecommendations => _recommendations.isNotEmpty;
  bool get hasFavorites => favorites.isNotEmpty;

  /// 加载推荐历史
  Future<void> loadRecommendations(String userId) async {
    _userId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await SupabaseService.getRecommendations(userId);
      _recommendations = data.map((json) => Recommendation.fromJson(json)).toList();
      _favorites = _recommendations.where((r) => r.isFavorite).toList();
      
      // 保存到本地缓存
      await _saveToLocalCache();
      
      _error = null;
    } catch (e) {
      _error = '网络异常，已加载本地缓存';
      debugPrint('加载推荐失败: $e');
      
      // 从本地缓存加载
      await _loadFromLocalCache();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 保存文字推荐
  Future<Recommendation?> saveTextRecommendation({
    required String userId,
    required String content,
    String? faceShape,
    String? weatherCondition,
  }) async {
    _userId = userId;
    
    try {
      final id = 'rec_${DateTime.now().millisecondsSinceEpoch}';
      final recommendation = Recommendation(
        id: id,
        userId: userId,
        type: 'text',
        content: content,
        faceShape: faceShape,
        weatherCondition: weatherCondition,
        createdAt: DateTime.now(),
      );

      try {
        await SupabaseService.saveRecommendation(recommendation.toJson());
      } catch (e) {
        debugPrint('保存到云端失败，仅保存到本地: $e');
      }

      _recommendations.insert(0, recommendation);
      await _saveToLocalCache();
      notifyListeners();
      return recommendation;
    } catch (e) {
      _error = '保存推荐失败: $e';
      debugPrint(_error);
      return null;
    }
  }

  /// 保存图片推荐
  Future<Recommendation?> saveImageRecommendation({
    required String userId,
    required String imageUrl,
    String? projectUrl,
    String? faceShape,
    String? weatherCondition,
  }) async {
    _userId = userId;
    
    try {
      final id = 'rec_${DateTime.now().millisecondsSinceEpoch}';
      final recommendation = Recommendation(
        id: id,
        userId: userId,
        type: 'image',
        content: imageUrl,
        projectUrl: projectUrl,
        faceShape: faceShape,
        weatherCondition: weatherCondition,
        createdAt: DateTime.now(),
      );

      try {
        await SupabaseService.saveRecommendation(recommendation.toJson());
      } catch (e) {
        debugPrint('保存到云端失败，仅保存到本地: $e');
      }

      _recommendations.insert(0, recommendation);
      await _saveToLocalCache();
      notifyListeners();
      return recommendation;
    } catch (e) {
      _error = '保存推荐失败: $e';
      debugPrint(_error);
      return null;
    }
  }

  /// 收藏/取消收藏
  Future<void> toggleFavorite(String recommendationId) async {
    final index = _recommendations.indexWhere((r) => r.id == recommendationId);
    if (index == -1) return;

    final recommendation = _recommendations[index];
    final newFavoriteStatus = !recommendation.isFavorite;

    try {
      await SupabaseService.favoriteRecommendation(recommendationId, newFavoriteStatus);
    } catch (e) {
      debugPrint('同步收藏状态失败: $e');
    }

    _recommendations[index] = recommendation.copyWith(
      isFavorite: newFavoriteStatus,
      updatedAt: DateTime.now(),
    );

    _favorites = _recommendations.where((r) => r.isFavorite).toList();
    await _saveToLocalCache();
    notifyListeners();
  }

  /// 删除推荐
  Future<void> deleteRecommendation(String recommendationId) async {
    try {
      await SupabaseService.deleteRecommendation(recommendationId);
    } catch (e) {
      debugPrint('从云端删除失败: $e');
    }

    _recommendations.removeWhere((r) => r.id == recommendationId);
    _favorites = _recommendations.where((r) => r.isFavorite).toList();
    await _saveToLocalCache();
    notifyListeners();
  }

  /// 清空所有推荐
  Future<void> clearAll(String userId) async {
    try {
      for (final r in _recommendations) {
        try {
          await SupabaseService.deleteRecommendation(r.id);
        } catch (e) {
          // 忽略单个删除失败
        }
      }
    } catch (e) {
      debugPrint('清空云端数据失败: $e');
    }

    _recommendations.clear();
    _favorites.clear();
    await _saveToLocalCache();
    notifyListeners();
  }

  /// 保存到本地缓存
  Future<void> _saveToLocalCache() async {
    if (_userId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _recommendations.map((r) => r.toJson()).toList();
      await prefs.setString('recommendations_$_userId', jsonEncode(jsonList));
    } catch (e) {
      debugPrint('本地缓存保存失败: $e');
    }
  }

  /// 从本地缓存加载
  Future<void> _loadFromLocalCache() async {
    if (_userId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('recommendations_$_userId');
      if (cached != null) {
        final List<dynamic> jsonList = jsonDecode(cached);
        _recommendations = jsonList.map((json) => Recommendation.fromJson(json)).toList();
        _favorites = _recommendations.where((r) => r.isFavorite).toList();
      }
    } catch (e) {
      debugPrint('本地缓存加载失败: $e');
      _recommendations = [];
      _favorites = [];
    }
  }

  /// 清空数据
  void clear() {
    _recommendations = [];
    _favorites = [];
    _userId = null;
    _error = null;
    notifyListeners();
  }
}
