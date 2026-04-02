import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beauty_advisor/models/membership.dart';

/// 会员状态管理 Provider
class MembershipProvider extends ChangeNotifier {
  MembershipLevel _level = MembershipLevel.free;
  DateTime? _expireDate;
  bool _isLoading = false;
  String? _error;

  // 使用次数限制
  int _faceAnalysisCount = 0;
  int _recommendationCount = 0;
  int _imageRecommendationCount = 0;
  DateTime? _lastResetDate;

  // Getters
  MembershipLevel get level => _level;
  DateTime? get expireDate => _expireDate;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  bool get isPro => _level == MembershipLevel.pro || _level == MembershipLevel.premium;
  bool get isPremium => _level == MembershipLevel.premium;
  bool get isExpired => _expireDate != null && DateTime.now().isAfter(_expireDate!);

  // 使用次数
  int get faceAnalysisCount => _faceAnalysisCount;
  int get recommendationCount => _recommendationCount;
  int get imageRecommendationCount => _imageRecommendationCount;

  // 每日限制
  int get faceAnalysisLimit => isPro ? 999 : 3;
  int get recommendationLimit => isPro ? 999 : 5;
  int get imageRecommendationLimit => isPremium ? 999 : (isPro ? 10 : 0);

  /// 初始化
  Future<void> initialize() async {
    await _loadFromLocal();
    _checkAndResetDaily();
  }

  /// 从本地加载
  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 加载会员等级
      final levelStr = prefs.getString('membership_level');
      if (levelStr != null) {
        _level = MembershipLevel.values.firstWhere(
          (l) => l.name == levelStr,
          orElse: () => MembershipLevel.free,
        );
      }
      
      // 加载过期时间
      final expireStr = prefs.getString('membership_expire');
      if (expireStr != null) {
        _expireDate = DateTime.parse(expireStr);
        if (isExpired) {
          _level = MembershipLevel.free;
          _expireDate = null;
        }
      }
      
      // 加载使用次数
      _faceAnalysisCount = prefs.getInt('face_analysis_count') ?? 0;
      _recommendationCount = prefs.getInt('recommendation_count') ?? 0;
      _imageRecommendationCount = prefs.getInt('image_recommendation_count') ?? 0;
      
      final lastResetStr = prefs.getString('last_reset_date');
      if (lastResetStr != null) {
        _lastResetDate = DateTime.parse(lastResetStr);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('加载会员信息失败: $e');
    }
  }

  /// 保存到本地
  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('membership_level', _level.name);
      if (_expireDate != null) {
        await prefs.setString('membership_expire', _expireDate!.toIso8601String());
      }
      
      await prefs.setInt('face_analysis_count', _faceAnalysisCount);
      await prefs.setInt('recommendation_count', _recommendationCount);
      await prefs.setInt('image_recommendation_count', _imageRecommendationCount);
      if (_lastResetDate != null) {
        await prefs.setString('last_reset_date', _lastResetDate!.toIso8601String());
      }
    } catch (e) {
      debugPrint('保存会员信息失败: $e');
    }
  }

  /// 检查并重置每日计数
  void _checkAndResetDaily() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastResetDate == null || 
        _lastResetDate!.year != today.year ||
        _lastResetDate!.month != today.month ||
        _lastResetDate!.day != today.day) {
      // 重置计数
      _faceAnalysisCount = 0;
      _recommendationCount = 0;
      _imageRecommendationCount = 0;
      _lastResetDate = today;
      _saveToLocal();
      notifyListeners();
    }
  }

  /// 检查是否可以使用脸型分析
  bool canUseFaceAnalysis() {
    _checkAndResetDaily();
    return _faceAnalysisCount < faceAnalysisLimit;
  }

  /// 使用脸型分析
  void useFaceAnalysis() {
    if (canUseFaceAnalysis()) {
      _faceAnalysisCount++;
      _saveToLocal();
      notifyListeners();
    }
  }

  /// 检查是否可以使用文字推荐
  bool canUseRecommendation() {
    _checkAndResetDaily();
    return _recommendationCount < recommendationLimit;
  }

  /// 使用文字推荐
  void useRecommendation() {
    if (canUseRecommendation()) {
      _recommendationCount++;
      _saveToLocal();
      notifyListeners();
    }
  }

  /// 检查是否可以使用图片推荐
  bool canUseImageRecommendation() {
    _checkAndResetDaily();
    return _imageRecommendationCount < imageRecommendationLimit;
  }

  /// 使用图片推荐
  void useImageRecommendation() {
    if (canUseImageRecommendation()) {
      _imageRecommendationCount++;
      _saveToLocal();
      notifyListeners();
    }
  }

  /// 购买会员
  Future<bool> purchaseMembership(MembershipLevel level, int months) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: 集成真实支付
      // 模拟购买成功
      await Future.delayed(const Duration(seconds: 1));
      
      _level = level;
      _expireDate = DateTime.now().add(Duration(days: months * 30));
      
      await _saveToLocal();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '购买失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 恢复购买
  Future<void> restorePurchase() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: 从服务器验证购买记录
      await Future.delayed(const Duration(seconds: 1));
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '恢复失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取剩余次数
  int getRemainingCount(String feature) {
    _checkAndResetDaily();
    
    switch (feature) {
      case 'face_analysis':
        return faceAnalysisLimit - _faceAnalysisCount;
      case 'recommendation':
        return recommendationLimit - _recommendationCount;
      case 'image_recommendation':
        return imageRecommendationLimit - _imageRecommendationCount;
      default:
        return 0;
    }
  }

  /// 清除会员信息
  void clear() {
    _level = MembershipLevel.free;
    _expireDate = null;
    _faceAnalysisCount = 0;
    _recommendationCount = 0;
    _imageRecommendationCount = 0;
    _lastResetDate = null;
    _error = null;
    notifyListeners();
  }
}
