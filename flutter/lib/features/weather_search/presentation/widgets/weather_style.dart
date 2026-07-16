import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 天氣現象（Wx）文字的語意分類。實際顏色由 [AppColors] 提供、圖示見下方。與 iOS 端一致。
class WeatherStyle {
  const WeatherStyle._();

  /// 依 Wx 文字關鍵字分類。優先序：雨/雷 → 晴 → 多雲/陰 → 其他。
  static WeatherCategory categoryOf(String description) {
    if (description.contains('雨') || description.contains('雷')) {
      return WeatherCategory.rainy;
    }
    if (description.contains('晴')) {
      return WeatherCategory.sunny;
    }
    if (description.contains('雲') || description.contains('陰')) {
      return WeatherCategory.cloudy;
    }
    return WeatherCategory.neutral;
  }

  static IconData icon(WeatherCategory category) {
    switch (category) {
      case WeatherCategory.sunny:
        return Icons.wb_sunny_rounded;
      case WeatherCategory.cloudy:
        return Icons.cloud_rounded;
      case WeatherCategory.rainy:
        return Icons.water_drop_rounded;
      case WeatherCategory.neutral:
        return Icons.wb_cloudy_rounded;
    }
  }
}
