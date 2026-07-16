import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'router/app_router.dart';

void main() {
  // API 授權碼由 --dart-define-from-file 注入（見 config/dart_defines.example.json），不進版控。
  const apiKey = String.fromEnvironment('CWA_API_KEY');
  runApp(const WeatherPredictionApp(apiKey: apiKey));
}

class WeatherPredictionApp extends StatelessWidget {
  const WeatherPredictionApp({required this.apiKey, super.key});

  final String apiKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '天氣預測',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: AppColors.pageBackground(false),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        scaffoldBackgroundColor: AppColors.pageBackground(true),
        useMaterial3: true,
      ),
      routerConfig: createAppRouter(apiKey: apiKey),
    );
  }
}
