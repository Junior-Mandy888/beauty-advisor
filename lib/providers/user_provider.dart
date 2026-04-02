import 'package:flutter/foundation.dart';
import 'package:beauty_advisor/models/user_profile.dart';
import 'package:beauty_advisor/services/supabase_service.dart';

/// 用户状态管理 Provider
class UserProvider extends ChangeNotifier {
  String? _userId;
  String? _nickname;
  String? _avatarUrl;
  String? _faceShape;
  int? _age;
  String? _gender;
  String? _city;
  String? _phone;
  bool _isLoading = false;
  String? _error;
  UserProfile? _profile;

  // Getters
  String? get userId => _userId;
  String? get nickname => _nickname;
  String? get avatarUrl => _avatarUrl;
  String? get faceShape => _faceShape;
  int? get age => _age;
  String? get gender => _gender;
  String? get city => _city;
  String? get phone => _phone;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _userId != null;
  UserProfile? get profile => _profile;

  /// 初始化 - 检查登录状态并加载数据
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 检查是否已登录
      if (SupabaseService.isAuthenticated) {
        _userId = SupabaseService.currentUserId;
        await _loadUserProfile();
      } else {
        // 匿名登录
        await _anonymousLogin();
      }
    } catch (e) {
      _error = '初始化失败: $e';
      // 离线模式：使用临时ID
      _userId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 匿名登录
  Future<void> _anonymousLogin() async {
    try {
      final response = await SupabaseService.signInAnonymously();
      _userId = response.user?.id;
      
      if (_userId != null) {
        // 创建默认用户档案
        await SupabaseService.createUserProfile(userId: _userId!);
        await _loadUserProfile();
      }
    } catch (e) {
      // 登录失败，使用临时ID
      _userId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      _error = '登录失败，使用本地模式';
    }
  }

  /// 加载用户档案
  Future<void> _loadUserProfile() async {
    if (_userId == null) return;

    try {
      _profile = await SupabaseService.getUserProfile(_userId!);
      if (_profile != null) {
        _nickname = _profile!.nickname;
        _avatarUrl = _profile!.avatarUrl;
        _faceShape = _profile!.faceShape;
        _age = _profile!.age;
        _gender = _profile!.gender;
        _city = _profile!.city;
        _phone = _profile!.phone;
      }
    } catch (e) {
      debugPrint('加载用户档案失败: $e');
    }
  }

  /// 更新用户信息并同步到云端
  Future<void> updateProfile({
    String? nickname,
    String? avatarUrl,
    String? faceShape,
    int? age,
    String? gender,
    String? city,
    String? phone,
  }) async {
    if (_userId == null) return;

    // 更新本地状态
    _nickname = nickname ?? _nickname;
    _avatarUrl = avatarUrl ?? _avatarUrl;
    _faceShape = faceShape ?? _faceShape;
    _age = age ?? _age;
    _gender = gender ?? _gender;
    _city = city ?? _city;
    _phone = phone ?? _phone;
    notifyListeners();

    // 同步到云端
    try {
      final profile = UserProfile(
        userId: _userId!,
        nickname: _nickname,
        avatarUrl: _avatarUrl,
        faceShape: _faceShape,
        age: _age,
        gender: _gender,
        city: _city,
        phone: _phone,
        createdAt: _profile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await SupabaseService.saveUserProfile(profile.toJson());
      _profile = profile;
    } catch (e) {
      _error = '保存失败';
      notifyListeners();
    }
  }

  /// 更新脸型
  Future<void> setFaceShape(String faceShape) async {
    await updateProfile(faceShape: faceShape);
  }

  /// 更新年龄
  Future<void> setAge(int age) async {
    await updateProfile(age: age);
  }

  /// 更新性别
  Future<void> setGender(String gender) async {
    await updateProfile(gender: gender);
  }

  /// 更新城市
  Future<void> setCity(String city) async {
    await updateProfile(city: city);
  }

  /// 更新昵称
  Future<void> setNickname(String nickname) async {
    await updateProfile(nickname: nickname);
  }

  /// 更新手机号码
  Future<void> setPhone(String phone) async {
    await updateProfile(phone: phone);
  }

  /// 重新加载用户数据
  Future<void> reload() async {
    await _loadUserProfile();
    notifyListeners();
  }

  /// 退出登录（清除本地数据）
  void logout() {
    _userId = null;
    _nickname = null;
    _avatarUrl = null;
    _faceShape = null;
    _age = null;
    _gender = null;
    _city = null;
    _phone = null;
    _profile = null;
    _error = null;
    notifyListeners();
  }
}