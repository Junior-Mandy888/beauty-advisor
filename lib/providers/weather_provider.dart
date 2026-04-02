import 'package:flutter/foundation.dart';
import 'package:beauty_advisor/services/weather_service.dart';

/// 天气状态管理
class WeatherProvider extends ChangeNotifier {
  WeatherData? _currentWeather;
  String? _location;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  WeatherData? get currentWeather => _currentWeather;
  String? get location => _location;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// 更新天气数据
  void updateWeather(WeatherData weather) {
    _currentWeather = weather;
    _error = null;
    notifyListeners();
  }
  
  /// 设置位置
  void setLocation(String location) {
    _location = location;
    notifyListeners();
  }
  
  /// 设置加载状态
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  /// 设置错误
  void setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
  
  /// 清除天气数据
  void clear() {
    _currentWeather = null;
    _location = null;
    _error = null;
    notifyListeners();
  }
}
