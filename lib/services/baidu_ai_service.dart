import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:beauty_advisor/config/app_config.dart';

/// 百度 AI 服务 - 脸型分析
class BaiduAIService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
  
  static String? _accessToken;
  
  /// 获取 Access Token（仅移动端使用）
  static Future<String> getAccessToken() async {
    if (_accessToken != null) return _accessToken!;
    
    try {
      final response = await _dio.post(
        'https://aip.baidubce.com/oauth/2.0/token',
        queryParameters: {
          'grant_type': 'client_credentials',
          'client_id': AppConfig.baiduApiKey,
          'client_secret': AppConfig.baiduSecretKey,
        },
      );
      
      _accessToken = response.data['access_token'];
      return _accessToken!;
    } on DioException catch (e) {
      throw Exception('获取百度 Access Token 失败: ${e.message}');
    }
  }
  
  /// 脸型分析
  static Future<FaceAnalysisResult> analyzeFace(String imageBase64) async {
    // Web 环境使用 Supabase Edge Function 代理
    if (kIsWeb) {
      return await _analyzeFaceViaProxy(imageBase64);
    }
    
    // 移动端直接调用百度 API
    return await _analyzeFaceDirect(imageBase64);
  }
  
  /// 通过 Supabase Edge Function 代理调用（Web端）
  static Future<FaceAnalysisResult> _analyzeFaceViaProxy(String imageBase64) async {
    try {
      final response = await _dio.post(
        '${AppConfig.supabaseUrl}/functions/v1/baidu-face-api',
        data: {'image_base64': imageBase64},
        options: Options(
          headers: {
            'apikey': AppConfig.supabaseKey,
            'Content-Type': 'application/json',
          },
        ),
      );
      
      final result = response.data;
      if (result['error_code'] != null && result['error_code'] != 0) {
        throw Exception(result['error_msg'] ?? '分析失败');
      }
      
      if (result['result'] == null || result['result']['face_list'] == null) {
        throw Exception('未检测到人脸');
      }
      
      return FaceAnalysisResult.fromJson(result['result']['face_list'][0]);
    } on DioException catch (e) {
      throw Exception('脸型分析失败: ${e.message}');
    }
  }
  
  /// 直接调用百度API（移动端）
  static Future<FaceAnalysisResult> _analyzeFaceDirect(String imageBase64) async {
    final token = await getAccessToken();
    
    try {
      final response = await _dio.post(
        'https://aip.baidubce.com/rest/2.0/face/v3/detect',
        queryParameters: {'access_token': token},
        data: {
          'image': imageBase64,
          'image_type': 'BASE64',
          'face_field': 'age,beauty,expression,face_shape,gender,glasses,landmark',
        },
      );
      
      final result = response.data;
      if (result['error_code'] != 0) {
        throw Exception(result['error_msg']);
      }
      
      return FaceAnalysisResult.fromJson(result['result']['face_list'][0]);
    } on DioException catch (e) {
      throw Exception('脸型分析失败: ${e.message}');
    }
  }
}

/// 脸型分析结果
class FaceAnalysisResult {
  final int age;
  final String gender;
  final String faceShape;
  final double beauty;
  final bool hasGlasses;
  final String expression;
  
  FaceAnalysisResult({
    required this.age,
    required this.gender,
    required this.faceShape,
    required this.beauty,
    required this.hasGlasses,
    required this.expression,
  });
  
  factory FaceAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FaceAnalysisResult(
      age: json['age'] ?? 0,
      gender: json['gender']['type'] ?? 'unknown',
      faceShape: json['face_shape']['type'] ?? 'unknown',
      beauty: (json['beauty'] ?? 0).toDouble(),
      hasGlasses: json['glasses']['type'] != 'none',
      expression: json['expression']['type'] ?? 'none',
    );
  }
  
  /// 脸型中文映射
  String get faceShapeChinese {
    const mapping = {
      'square': '方形脸',
      'triangle': '三角形脸',
      'oval': '鹅蛋脸',
      'heart': '心形脸',
      'round': '圆脸',
      'oblong': '长形脸',
      'diamond': '菱形脸',
    };
    return mapping[faceShape] ?? '标准脸型';
  }
  
  /// 获取脸型特点描述
  String get faceShapeDescription {
    const descriptions = {
      'square': '下颌线条明显，脸型棱角分明',
      'triangle': '额头较宽，下巴较尖',
      'oval': '脸型比例协调，是标准脸型',
      'heart': '额头饱满，下巴尖翘',
      'round': '脸部线条圆润，显得年轻可爱',
      'oblong': '脸型偏长，五官纵向分布',
      'diamond': '颧骨较宽，额头和下巴较窄',
    };
    return descriptions[faceShape] ?? '脸型比例协调';
  }
}
