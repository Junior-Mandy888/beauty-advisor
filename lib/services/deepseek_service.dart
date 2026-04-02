import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:beauty_advisor/config/app_config.dart';

/// DeepSeek 服务 - AI 推荐
class DeepSeekService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.deepseek.com/v1',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      'Content-Type': 'application/json',
    },
  ));
  
  /// 生成穿搭推荐
  static Future<String> generateRecommendation({
    required String faceShape,
    required int age,
    required String weather,
    required String gender,
    String? wardrobeInfo,
  }) async {
    final prompt = '''
你是一位专业的美妆穿搭顾问。请根据以下信息给出妆容、发型和穿搭建议：

【个人信息】
- 脸型：$faceShape
- 年龄：$age岁
- 性别：$gender
- 当前天气：$weather

${wardrobeInfo != null ? '【用户衣橱】\n$wardrobeInfo' : ''}

请给出：
1. 妆容建议（适合该脸型和场合）
2. 发型建议（修饰脸型）
3. 穿搭建议（结合天气和衣橱）
4. 配饰建议

请用简洁、实用的语言回答。
''';

    try {
      final response = await _dio.post(
        '/chat/completions',
        options: Options(headers: {
          'Authorization': 'Bearer ${AppConfig.deepseekApiKey}',
        }),
        data: {
          'model': 'deepseek-chat',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('API 返回错误: ${response.statusCode}');
      }
      
      final choices = response.data['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw Exception('API 返回数据格式错误');
      }
      
      final content = choices[0]['message']?['content'];
      if (content == null) {
        throw Exception('API 未返回内容');
      }
      
      return content;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error']?['message'] ?? e.message;
      throw Exception('AI 推荐生成失败: $errorMsg');
    } catch (e) {
      throw Exception('AI 推荐生成失败: $e');
    }
  }
  
  /// 流式生成推荐（用于实时显示）
  static Stream<String> streamRecommendation({
    required String faceShape,
    required int age,
    required String weather,
    required String gender,
    String? wardrobeInfo,
  }) async* {
    final prompt = '''
你是一位专业的美妆穿搭顾问。请根据以下信息给出妆容、发型和穿搭建议：

【个人信息】
- 脸型：$faceShape
- 年龄：$age岁
- 性别：$gender
- 当前天气：$weather

${wardrobeInfo != null ? '【用户衣橱】\n$wardrobeInfo' : ''}

请给出：
1. 妆容建议
2. 发型建议
3. 穿搭建议
4. 配饰建议
''';

    try {
      final response = await _dio.post(
        '/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConfig.deepseekApiKey}',
          },
          responseType: ResponseType.stream,
        ),
        data: {
          'model': 'deepseek-chat',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
          'stream': true,
        },
      );
      
      // 处理流式响应
      final stream = response.data.stream as Stream<List<int>>;
      await for (final chunk in stream) {
        final text = String.fromCharCodes(chunk);
        // 解析 SSE 格式
        for (final line in text.split('\n')) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') break;
            try {
              final json = Map<String, dynamic>.from(
                Map<String, dynamic>.from(
                  Map<String, dynamic>.from(jsonDecode(data))
                )['choices'][0]
              )['delta'];
              if (json['content'] != null) {
                yield json['content'];
              }
            } catch (_) {}
          }
        }
      }
    } on DioException catch (e) {
      throw Exception('AI 推荐生成失败: ${e.message}');
    }
  }
}
