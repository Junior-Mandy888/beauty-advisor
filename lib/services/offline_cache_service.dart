import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 离线缓存服务
class OfflineCacheService {
  static const String _cachePrefix = 'offline_cache_';
  static const String _cacheTimePrefix = 'offline_cache_time_';
  
  /// 缓存有效期（默认24小时）
  static const Duration defaultExpiration = Duration(hours: 24);

  /// 保存数据到缓存
  static Future<void> save<T>({
    required String key,
    required T data,
    Duration? expiration,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timeKey = '$_cacheTimePrefix$key';
      
      // 保存数据
      await prefs.setString(cacheKey, jsonEncode(toJson(data)));
      
      // 保存时间戳
      final expirationTime = DateTime.now().add(expiration ?? defaultExpiration);
      await prefs.setString(timeKey, expirationTime.toIso8601String());
      
      debugPrint('缓存已保存: $key');
    } catch (e) {
      debugPrint('保存缓存失败: $e');
    }
  }

  /// 保存列表数据到缓存
  static Future<void> saveList<T>({
    required String key,
    required List<T> data,
    Duration? expiration,
    required List<Map<String, dynamic>> Function(List<T>) toJsonList,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timeKey = '$_cacheTimePrefix$key';
      
      // 保存数据
      await prefs.setString(cacheKey, jsonEncode(toJsonList(data)));
      
      // 保存时间戳
      final expirationTime = DateTime.now().add(expiration ?? defaultExpiration);
      await prefs.setString(timeKey, expirationTime.toIso8601String());
      
      debugPrint('缓存列表已保存: $key (${data.length}条)');
    } catch (e) {
      debugPrint('保存缓存列表失败: $e');
    }
  }

  /// 从缓存读取数据
  static Future<T?> get<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timeKey = '$_cacheTimePrefix$key';
      
      // 检查是否过期
      final timeStr = prefs.getString(timeKey);
      if (timeStr == null) return null;
      
      final expirationTime = DateTime.parse(timeStr);
      if (DateTime.now().isAfter(expirationTime)) {
        // 缓存已过期，清除
        await clear(key);
        return null;
      }
      
      // 读取数据
      final dataStr = prefs.getString(cacheKey);
      if (dataStr == null) return null;
      
      final jsonData = jsonDecode(dataStr) as Map<String, dynamic>;
      return fromJson(jsonData);
    } catch (e) {
      debugPrint('读取缓存失败: $e');
      return null;
    }
  }

  /// 从缓存读取列表数据
  static Future<List<T>?> getList<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timeKey = '$_cacheTimePrefix$key';
      
      // 检查是否过期
      final timeStr = prefs.getString(timeKey);
      if (timeStr == null) return null;
      
      final expirationTime = DateTime.parse(timeStr);
      if (DateTime.now().isAfter(expirationTime)) {
        // 缓存已过期，清除
        await clear(key);
        return null;
      }
      
      // 读取数据
      final dataStr = prefs.getString(cacheKey);
      if (dataStr == null) return null;
      
      final jsonList = jsonDecode(dataStr) as List;
      return jsonList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('读取缓存列表失败: $e');
      return null;
    }
  }

  /// 清除指定缓存
  static Future<void> clear(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_cachePrefix$key');
      await prefs.remove('$_cacheTimePrefix$key');
      debugPrint('缓存已清除: $key');
    } catch (e) {
      debugPrint('清除缓存失败: $e');
    }
  }

  /// 清除所有缓存
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_cachePrefix) || key.startsWith(_cacheTimePrefix)) {
          await prefs.remove(key);
        }
      }
      
      debugPrint('所有缓存已清除');
    } catch (e) {
      debugPrint('清除所有缓存失败: $e');
    }
  }

  /// 检查是否有缓存
  static Future<bool> has(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timeKey = '$_cacheTimePrefix$key';
      
      final dataStr = prefs.getString(cacheKey);
      final timeStr = prefs.getString(timeKey);
      
      if (dataStr == null || timeStr == null) return false;
      
      // 检查是否过期
      final expirationTime = DateTime.parse(timeStr);
      return DateTime.now().isBefore(expirationTime);
    } catch (e) {
      return false;
    }
  }

  /// 获取缓存大小（估算）
  static Future<int> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      int totalSize = 0;
      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          final data = prefs.getString(key);
          if (data != null) {
            totalSize += data.length;
          }
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}

/// 缓存键常量
class CacheKeys {
  static const String userProfile = 'user_profile';
  static const String wardrobe = 'wardrobe';
  static const String recommendations = 'recommendations';
  static const String weather = 'weather';
  static const String faceShape = 'face_shape';
}
