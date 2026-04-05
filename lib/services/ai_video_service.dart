import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:beauty_advisor/config/app_config.dart';

/// AI视频生成服务
class AIVideoService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 180),
    receiveTimeout: const Duration(seconds: 180),
  ));

  /// 生成发型示例视频
  static Future<VideoGenerationResult> generateHairstyleVideo({
    required Uint8List faceImage,
    required String hairstyleType, // short, long, updo
    required String faceShape,
  }) async {
    try {
      final base64Image = base64Encode(faceImage);
      
      final response = await _dio.post(
        '${AppConfig.supabaseUrl}/functions/v1/generate-hairstyle-video',
        data: {
          'image_base64': base64Image,
          'hairstyle_type': hairstyleType,
          'face_shape': faceShape,
        },
        options: Options(headers: {
          'apikey': AppConfig.supabaseKey,
          'Content-Type': 'application/json',
        }),
      );

      final data = response.data;
      return VideoGenerationResult(
        success: data['success'] ?? false,
        videoUrl: data['video_url'],
        thumbnailUrl: data['thumbnail_url'],
        duration: data['duration'],
        error: data['error'],
      );
    } on DioException catch (e) {
      // 离线模式返回演示结果
      return VideoGenerationResult(
        success: true,
        videoUrl: null,
        thumbnailUrl: null,
        duration: 10,
        isDemo: true,
        demoMessage: '演示模式：实际视频需连接AI服务生成',
      );
    } catch (e) {
      return VideoGenerationResult(
        success: false,
        error: '生成失败: $e',
      );
    }
  }

  /// 生成妆容示例视频
  static Future<VideoGenerationResult> generateMakeupVideo({
    required Uint8List faceImage,
    required String makeupStyle, // daily, date, korean, office
    required String faceShape,
  }) async {
    try {
      final base64Image = base64Encode(faceImage);
      
      final response = await _dio.post(
        '${AppConfig.supabaseUrl}/functions/v1/generate-makeup-video',
        data: {
          'image_base64': base64Image,
          'makeup_style': makeupStyle,
          'face_shape': faceShape,
        },
        options: Options(headers: {
          'apikey': AppConfig.supabaseKey,
          'Content-Type': 'application/json',
        }),
      );

      final data = response.data;
      return VideoGenerationResult(
        success: data['success'] ?? false,
        videoUrl: data['video_url'],
        thumbnailUrl: data['thumbnail_url'],
        duration: data['duration'],
        error: data['error'],
      );
    } on DioException catch (e) {
      // 离线模式返回演示结果
      return VideoGenerationResult(
        success: true,
        videoUrl: null,
        thumbnailUrl: null,
        duration: 15,
        isDemo: true,
        demoMessage: '演示模式：实际视频需连接AI服务生成',
      );
    } catch (e) {
      return VideoGenerationResult(
        success: false,
        error: '生成失败: $e',
      );
    }
  }

  /// 获取发型类型说明
  static String getHairstyleTypeDescription(String type) {
    switch (type) {
      case 'short':
        return '短发造型：清爽利落，凸显五官轮廓';
      case 'long':
        return '长发造型：温柔优雅，增添女性魅力';
      case 'updo':
        return '盘发造型：优雅大气，适合正式场合';
      default:
        return '个性化发型推荐';
    }
  }

  /// 获取妆容风格说明
  static String getMakeupStyleDescription(String style) {
    switch (style) {
      case 'daily':
        return '日常妆容：自然清新，适合日常通勤';
      case 'date':
        return '约会妆容：甜美温柔，增添魅力';
      case 'korean':
        return '韩系妆容：清透水光，打造少女感';
      case 'office':
        return '职场妆容：干练专业，展现气质';
      default:
        return '个性化妆容推荐';
    }
  }
}

/// 视频生成结果
class VideoGenerationResult {
  final bool success;
  final String? videoUrl;
  final String? thumbnailUrl;
  final int? duration; // 秒
  final String? error;
  final bool isDemo;
  final String? demoMessage;

  VideoGenerationResult({
    required this.success,
    this.videoUrl,
    this.thumbnailUrl,
    this.duration,
    this.error,
    this.isDemo = false,
    this.demoMessage,
  });
}
