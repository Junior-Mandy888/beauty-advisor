import 'package:dio/dio.dart';
import 'package:beauty_advisor/config/app_config.dart';

/// LiblibAI 穿搭图片生成服务
class LiblibService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 120),
    receiveTimeout: const Duration(seconds: 120),
  ));
  
  /// 生成穿搭参考图
  static Future<LiblibResult> generateOutfitImage({
    required String faceShape,
    required String weather,
    String? style,
    String? colorPreference,
  }) async {
    // 构建提示词
    final prompt = '''
生成一张时尚穿搭参考图：
- 适合${faceShape}脸型的人群
- 天气：$weather
- 风格：${style ?? '日常休闲'}
- 颜色偏好：${colorPreference ?? '自然柔和'}

要求：
1. 展示完整的穿搭搭配效果
2. 包含上装、下装、鞋子、配饰
3. 风格协调，适合日常穿着
4. 高清、真实感、时尚杂志风格
''';

    try {
      final response = await _dio.post(
        '${AppConfig.supabaseUrl}/functions/v1/liblib-outfit',
        data: {'prompt': prompt},
        options: Options(headers: {
          'apikey': AppConfig.supabaseKey,
          'Content-Type': 'application/json',
        }),
      );

      final data = response.data;
      return LiblibResult(
        success: data['success'] ?? false,
        imageUrl: data['imageUrl'],
        projectUrl: data['projectUrl'],
      );
    } on DioException catch (e) {
      return LiblibResult(
        success: false,
        error: '生成失败: ${e.message}',
      );
    }
  }
}

/// 生成结果
class LiblibResult {
  final bool success;
  final String? imageUrl;
  final String? projectUrl;
  final String? error;

  LiblibResult({
    required this.success,
    this.imageUrl,
    this.projectUrl,
    this.error,
  });
}
