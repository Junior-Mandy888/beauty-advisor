import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:beauty_advisor/models/wardrobe_item.dart';
import 'package:beauty_advisor/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 衣橱状态管理 Provider
class WardrobeProvider extends ChangeNotifier {
  List<WardrobeItem> _items = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;

  // Getters
  List<WardrobeItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _userId;

  /// 按分类获取物品
  List<WardrobeItem> getByCategory(WardrobeCategory category) {
    return _items.where((item) => item.category == category).toList();
  }

  /// 获取物品总数
  int get totalCount => _items.length;

  /// 设置用户ID并加载数据
  Future<void> setUserId(String userId) async {
    _userId = userId;
    await loadWardrobe();
  }

  /// 加载衣橱数据
  Future<void> loadWardrobe() async {
    if (_userId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. 尝试从 Supabase 加载
      final supabaseData = await SupabaseService.getWardrobe(_userId!);
      debugPrint('从 Supabase 加载 ${supabaseData.length} 条数据');
      
      if (supabaseData.isNotEmpty) {
        _items = supabaseData.map((json) {
          debugPrint('加载物品: id=${json['id']}, name=${json['name']}, image_url=${json['image_url']}');
          return WardrobeItem.fromJson(json);
        }).toList();
        // 保存到本地缓存
        await _saveToLocalCache();
      } else {
        // 2. Supabase 为空，尝试从本地缓存加载
        await _loadFromLocalCache();
      }
      _error = null;
    } catch (e) {
      debugPrint('加载衣橱失败: $e');
      // 如果 Supabase 失败，从本地缓存加载
      await _loadFromLocalCache();
      _error = '网络异常，已加载本地缓存';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 添加衣橱物品
  Future<void> addItem(WardrobeItem item, {Uint8List? imageBytes}) async {
    if (_userId == null) return;

    try {
      // 生成正式 ID
      final now = DateTime.now();
      final newItem = item.copyWith(
        id: '${_userId}_${now.millisecondsSinceEpoch}',
        createdAt: now,
        updatedAt: now,
      );

      // 如果有图片，先上传到 Supabase Storage
      String? imageUrl;
      if (imageBytes != null) {
        imageUrl = await _uploadImage(newItem.id, imageBytes);
        debugPrint('上传图片结果: $imageUrl');
      }

      // 更新图片URL
      final itemToSave = imageUrl != null 
          ? newItem.copyWith(imageUrl: imageUrl) 
          : newItem;

      debugPrint('保存物品: ${itemToSave.toJson()}');

      // 保存到 Supabase
      await SupabaseService.saveWardrobeItem(itemToSave.toJson());

      // 更新本地列表
      _items.add(itemToSave);
      await _saveToLocalCache();
      _error = null;
    } catch (e) {
      debugPrint('添加物品失败: $e');
      // 如果保存失败，至少保存到本地
      _items.add(item);
      await _saveToLocalCache();
      _error = '保存失败，已保存到本地';
    }

    notifyListeners();
  }

  /// 删除衣橱物品
  Future<void> deleteItem(String itemId) async {
    if (_userId == null) return;

    try {
      // 从 Supabase 删除
      await SupabaseService.deleteWardrobeItem(itemId);
    } catch (e) {
      // 忽略 Supabase 删除错误，本地删除会成功
    }

    // 从本地列表删除
    _items.removeWhere((item) => item.id == itemId);
    await _saveToLocalCache();
    notifyListeners();
  }

  /// 更新衣橱物品
  Future<void> updateItem(WardrobeItem item) async {
    if (_userId == null) return;

    final updatedItem = item.copyWith(updatedAt: DateTime.now());

    try {
      // 更新到 Supabase
      await SupabaseService.updateWardrobeItem(updatedItem.toJson());
    } catch (e) {
      // 忽略错误
    }

    // 更新本地列表
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = updatedItem;
      await _saveToLocalCache();
    }
    notifyListeners();
  }

  /// 上传图片到 Supabase Storage
  Future<String?> _uploadImage(String itemId, Uint8List imageBytes) async {
    try {
      final base64Image = base64Encode(imageBytes);
      final fileName = '$itemId.jpg';
      
      // 使用 Supabase Storage 上传
      await SupabaseService.uploadWardrobeImage(fileName, base64Image);
      
      // 返回公开URL
      return SupabaseService.getWardrobeImageUrl(fileName);
    } catch (e) {
      debugPrint('图片上传失败: $e');
      return null;
    }
  }

  /// 保存到本地缓存
  Future<void> _saveToLocalCache() async {
    if (_userId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _items.map((item) => item.toJson()).toList();
      await prefs.setString('wardrobe_$_userId', jsonEncode(jsonList));
    } catch (e) {
      debugPrint('本地缓存保存失败: $e');
    }
  }

  /// 从本地缓存加载
  Future<void> _loadFromLocalCache() async {
    if (_userId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('wardrobe_$_userId');
      if (cached != null) {
        final List<dynamic> jsonList = jsonDecode(cached);
        _items = jsonList.map((json) => WardrobeItem.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('本地缓存加载失败: $e');
      _items = [];
    }
  }

  /// 同步本地数据到 Supabase
  Future<void> syncToCloud() async {
    if (_userId == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      for (final item in _items) {
        if (item.id.startsWith('temp_')) {
          await SupabaseService.saveWardrobeItem(item.toJson());
        }
      }
      _error = null;
    } catch (e) {
      _error = '同步失败';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 清空数据（退出登录时调用）
  void clear() {
    _items = [];
    _userId = null;
    _error = null;
    notifyListeners();
  }
}