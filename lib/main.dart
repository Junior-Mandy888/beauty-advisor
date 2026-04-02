import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beauty_advisor/app.dart';
import 'package:beauty_advisor/services/supabase_service.dart';
import 'package:beauty_advisor/providers/user_provider.dart';
import 'package:beauty_advisor/providers/wardrobe_provider.dart';
import 'package:beauty_advisor/providers/weather_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Supabase
  await SupabaseService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        // 用户状态 Provider
        ChangeNotifierProvider(create: (_) => UserProvider()..initialize()),
        // 衣橱状态 Provider
        ChangeNotifierProvider(create: (_) => WardrobeProvider()),
        // 天气状态 Provider
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const BeautyAdvisorApp(),
    ),
  );
}