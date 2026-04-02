import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:beauty_advisor/router.dart';

class BeautyAdvisorApp extends StatelessWidget {
  const BeautyAdvisorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider 已在 main.dart 中初始化，这里不再重复创建
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 标准尺寸
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: '美妆穿搭顾问',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF6B9D), // 粉色主题
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
          ),
          routerConfig: appRouter,
        );
      },
    );
  }
}