import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 事件类型
enum AnalyticsEvent {
  appLaunch,           // 启动应用
  appExit,             // 退出应用
  pageView,            // 页面浏览
  faceAnalysis,        // 脸型分析
  faceAnalysisSuccess, // 脸型分析成功
  recommendation,      // 获取推荐
  recommendationText,  // 文字推荐
  recommendationImage, // 图片推荐
  wardrobeAdd,         // 添加衣物
  wardrobeDelete,      // 删除衣物
  membershipView,      // 查看会员页
  membershipPurchase,  // 购买会员
  adShow,              // 展示广告
  adClick,             // 点击广告
  productClick,        // 点击商品
  share,               // 分享
  error,               // 错误
}

/// 用户行为统计服务
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static const String _eventLogKey = 'analytics_event_log';
  static const String _userStatsKey = 'analytics_user_stats';
  
  List<Map<String, dynamic>> _eventLog = [];
  Map<String, dynamic> _userStats = {};
  bool _initialized = false;

  /// 初始化
  Future<void> initialize() async {
    if (_initialized) return;
    
    await _loadFromLocal();
    _initialized = true;
    
    // 记录启动事件
    logEvent(AnalyticsEvent.appLaunch);
  }

  /// 从本地加载
  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 加载事件日志（最近7天）
      final logStr = prefs.getString(_eventLogKey);
      if (logStr != null) {
        final List<dynamic> log = jsonDecode(logStr);
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        _eventLog = log
            .map((e) => e as Map<String, dynamic>)
            .where((e) {
              final timestamp = DateTime.parse(e['timestamp'] as String);
              return timestamp.isAfter(sevenDaysAgo);
            })
            .toList();
      }
      
      // 加载用户统计
      final statsStr = prefs.getString(_userStatsKey);
      if (statsStr != null) {
        _userStats = jsonDecode(statsStr);
      }
    } catch (e) {
      debugPrint('加载统计数据失败: $e');
    }
  }

  /// 保存到本地
  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 只保留最近7天的日志
      await prefs.setString(_eventLogKey, jsonEncode(_eventLog));
      await prefs.setString(_userStatsKey, jsonEncode(_userStats));
    } catch (e) {
      debugPrint('保存统计数据失败: $e');
    }
  }

  /// 记录事件
  Future<void> logEvent(
    AnalyticsEvent event, {
    Map<String, dynamic>? properties,
  }) async {
    final eventRecord = {
      'event': event.name,
      'timestamp': DateTime.now().toIso8601String(),
      'properties': properties,
    };
    
    _eventLog.add(eventRecord);
    
    // 更新统计
    _updateStats(event, properties);
    
    // 保存
    await _saveToLocal();
    
    debugPrint('📊 Analytics: ${event.name} ${properties ?? ''}');
  }

  /// 更新统计数据
  void _updateStats(AnalyticsEvent event, Map<String, dynamic>? properties) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = '${event.name}_$today';
    
    _userStats[key] = (_userStats[key] ?? 0) + 1;
    
    // 总计
    final totalKey = '${event.name}_total';
    _userStats[totalKey] = (_userStats[totalKey] ?? 0) + 1;
    
    // 特殊统计
    switch (event) {
      case AnalyticsEvent.appLaunch:
        _userStats['last_launch'] = DateTime.now().toIso8601String();
        break;
      case AnalyticsEvent.membershipPurchase:
        if (properties?['level'] != null) {
          _userStats['membership_level'] = properties!['level'];
        }
        break;
      default:
        break;
    }
  }

  /// 获取今日事件次数
  int getTodayCount(AnalyticsEvent event) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = '${event.name}_$today';
    return _userStats[key] ?? 0;
  }

  /// 获取总次数
  int getTotalCount(AnalyticsEvent event) {
    final key = '${event.name}_total';
    return _userStats[key] ?? 0;
  }

  /// 获取用户统计概览
  Map<String, dynamic> getUserStats() {
    return Map.from(_userStats);
  }

  /// 获取最近活跃天数
  int getActiveDays() {
    final launchDates = _eventLog
        .where((e) => e['event'] == AnalyticsEvent.appLaunch.name)
        .map((e) => (e['timestamp'] as String).split('T')[0])
        .toSet()
        .length;
    return launchDates;
  }

  /// 获取事件趋势（最近7天）
  Map<String, int> getEventTrend(AnalyticsEvent event) {
    final result = <String, int>{};
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      final key = '${event.name}_$dateStr';
      result[dateStr] = _userStats[key] ?? 0;
    }
    
    return result;
  }

  /// 清除统计数据
  Future<void> clear() async {
    _eventLog.clear();
    _userStats.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_eventLogKey);
    await prefs.remove(_userStatsKey);
  }
}

/// 页面浏览追踪混入
mixin PageViewTracking<T extends StatefulWidget> on State<T> {
  String get pageName;
  
  @override
  void initState() {
    super.initState();
    AnalyticsService().logEvent(
      AnalyticsEvent.pageView,
      properties: {'page': pageName},
    );
  }
}
