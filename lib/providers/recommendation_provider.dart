import 'package:flutter/foundation.dart';
import 'package:beauty_advisor/models/recommendation.dart';
import 'package:beauty_advisor/services/supabase_service.dart';

/// 推荐历史状态管理 Provider
class RecommendationProvider extends ChangeNotifier {
  List<Recommendation> _recommendations = [];
  List<Recommendation> _favorites = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Recommendation> get recommendations => _recommendations;
  List<Recommendation> get favorites => _favorites.where((r) => r.isFavorite).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasRecommendations => _recommendations.isNotEmpty;
  bool get hasFavorites => favorites.isNotEmpty;

  /// 加载推荐历史
  Future<void> loadRecommendations(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await SupabaseService.getRecommendations(userId);
      _recommendations = data.map((json) => Recommendation.fromJson(json)).toList();
      _favorites = _recommendations.where((r) => r.isFavorite).toList();
      _error = null;
    } catch (e) {
      _error = '加载推荐历史失败: $e';
      debugPrint(_error);
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

      await SupabaseService.saveRecommendation(recommendation.toJson());
      _recommendations.insert(0, recommendation);
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

      await SupabaseService.saveRecommendation(recommendation.toJson());
      _recommendations.insert(0, recommendation);
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
      
      _recommendations[index] = recommendation.copyWith(
        isFavorite: newFavoriteStatus,
        updatedAt: DateTime.now(),
      );
      
      _favorites = _recommendations.where((r) => r.isFavorite).toList();
      notifyListeners();
    } catch (e) {
      _error = '操作失败: $e';
      debugPrint(_error);
    }
  }

  /// 删除推荐
  Future<void> deleteRecommendation(String recommendationId) async {
    try {
      await SupabaseService.deleteRecommendation(recommendationId);
      _recommendations.removeWhere((r) => r.id == recommendationId);
      _favorites = _recommendations.where((r) => r.isFavorite).toList();
      notifyListeners();
    } catch (e) {
      _error = '删除失败: $e';
      debugPrint(_error);
    }
  }

  /// 清空所有推荐
  Future<void> clearAll(String userId) async {
    try {
      for (final r in _recommendations) {
        await SupabaseService.deleteRecommendation(r.id);
      }
      _recommendations.clear();
      _favorites.clear();
      notifyListeners();
    } catch (e) {
      _error = '清空失败: $e';
      debugPrint(_error);
    }
  }
}
