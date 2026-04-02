import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 天气数据模型
class WeatherData {
  final String condition;
  final double temperature;
  final int humidity;
  final String windDirection;
  final double windSpeed;

  WeatherData({
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.windDirection,
    required this.windSpeed,
  });
}

/// Open-Meteo 天气服务（免费，无需API Key）
class WeatherService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// 中国主要城市坐标
  static const Map<String, Map<String, double>> cities = {
    '北京': {'lat': 39.9042, 'lon': 116.4074},
    '上海': {'lat': 31.2304, 'lon': 121.4737},
    '广州': {'lat': 23.1291, 'lon': 113.2644},
    '深圳': {'lat': 22.5431, 'lon': 114.0579},
    '杭州': {'lat': 30.2741, 'lon': 120.1551},
    '成都': {'lat': 30.5728, 'lon': 104.0668},
    '武汉': {'lat': 30.5928, 'lon': 114.3055},
    '西安': {'lat': 34.3416, 'lon': 108.9398},
    '南京': {'lat': 32.0603, 'lon': 118.7969},
    '重庆': {'lat': 29.4316, 'lon': 106.9123},
    '苏州': {'lat': 31.2990, 'lon': 120.5853},
    '天津': {'lat': 39.0842, 'lon': 117.2010},
    '长沙': {'lat': 28.2282, 'lon': 112.9388},
    '郑州': {'lat': 34.7466, 'lon': 113.6254},
    '青岛': {'lat': 36.0671, 'lon': 120.3826},
  };

  /// 天气代码转文字
  static String _weatherCodeToText(int code) {
    const weatherMap = {
      0: '晴',
      1: '晴',
      2: '多云',
      3: '阴',
      45: '雾',
      48: '霜雾',
      51: '小雨',
      53: '小雨',
      55: '中雨',
      56: '冻雨',
      57: '冻雨',
      61: '小雨',
      63: '中雨',
      65: '大雨',
      66: '冻雨',
      67: '冻雨',
      71: '小雪',
      73: '中雪',
      75: '大雪',
      77: '雪粒',
      80: '阵雨',
      81: '阵雨',
      82: '暴雨',
      85: '阵雪',
      86: '阵雪',
      95: '雷阵雨',
      96: '雷阵雨伴冰雹',
      99: '雷阵雨伴冰雹',
    };
    return weatherMap[code] ?? '未知';
  }

  /// 风向角度转文字
  static String _windDirectionToText(int direction) {
    if (direction >= 337 || direction < 23) return '北风';
    if (direction >= 23 && direction < 68) return '东北风';
    if (direction >= 68 && direction < 113) return '东风';
    if (direction >= 113 && direction < 158) return '东南风';
    if (direction >= 158 && direction < 203) return '南风';
    if (direction >= 203 && direction < 248) return '西南风';
    if (direction >= 248 && direction < 293) return '西风';
    return '西北风';
  }

  /// 获取城市天气
  static Future<WeatherData> getWeatherByCity(String cityName) async {
    final city = cities[cityName] ?? cities['广州']!;
    return await getWeather(city['lat']!, city['lon']!);
  }

  /// 获取天气（通过经纬度）
  static Future<WeatherData> getWeather(double lat, double lon) async {
    try {
      final url = 'https://api.open-meteo.com/v1/forecast';
      
      final response = await _dio.get(
        url,
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current': 'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,wind_direction_10m',
          'timezone': 'Asia/Shanghai',
        },
      );

      debugPrint('天气响应: ${response.data}');

      final current = response.data['current'];
      
      return WeatherData(
        condition: _weatherCodeToText(current['weather_code']),
        temperature: (current['temperature_2m'] as num).toDouble(),
        humidity: current['relative_humidity_2m'],
        windDirection: _windDirectionToText(current['wind_direction_10m']),
        windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      );
    } on DioException catch (e) {
      debugPrint('天气请求失败: ${e.message}');
      throw Exception('获取天气失败: ${e.message}');
    }
  }

  /// 获取支持的城市列表
  static List<String> getSupportedCities() {
    return cities.keys.toList();
  }
}