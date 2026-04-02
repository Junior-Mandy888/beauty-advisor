/// 天气响应模型
class WeatherResponse {
  final String code;
  final String? message;
  final WeatherNow? now;
  
  WeatherResponse({
    required this.code,
    this.message,
    this.now,
  });
  
  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      code: json['code']?.toString() ?? '',
      message: json['message']?.toString(),
      now: json['now'] != null ? WeatherNow.fromJson(json['now']) : null,
    );
  }
  
  bool get isSuccess => code == '200';
}

class WeatherNow {
  final String obsTime;
  final String temp;
  final String feelsLike;
  final String icon;
  final String text;
  final String wind360;
  final String windDir;
  final String windScale;
  final String windSpeed;
  final String humidity;
  final String precip;
  final String pressure;
  final String vis;
  final String cloud;
  
  WeatherNow({
    this.obsTime = '',
    this.temp = '0',
    this.feelsLike = '0',
    this.icon = '',
    this.text = '',
    this.wind360 = '',
    this.windDir = '',
    this.windScale = '',
    this.windSpeed = '',
    this.humidity = '0',
    this.precip = '0',
    this.pressure = '0',
    this.vis = '0',
    this.cloud = '',
  });
  
  factory WeatherNow.fromJson(Map<String, dynamic> json) {
    return WeatherNow(
      obsTime: json['obsTime']?.toString() ?? '',
      temp: json['temp']?.toString() ?? '0',
      feelsLike: json['feelsLike']?.toString() ?? '0',
      icon: json['icon']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      wind360: json['wind360']?.toString() ?? '',
      windDir: json['windDir']?.toString() ?? '',
      windScale: json['windScale']?.toString() ?? '',
      windSpeed: json['windSpeed']?.toString() ?? '',
      humidity: json['humidity']?.toString() ?? '0',
      precip: json['precip']?.toString() ?? '0',
      pressure: json['pressure']?.toString() ?? '0',
      vis: json['vis']?.toString() ?? '0',
      cloud: json['cloud']?.toString() ?? '',
    );
  }
  
  /// 天气图标 URL
  String get iconUrl => 'https://a.hecdn.net/img/common/icon/202106d/$icon.png';
}
