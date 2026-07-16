import 'package:flutter/material.dart';

/// 天氣現象語意分類（顏色由 [AppColors] 提供）。
enum WeatherCategory { sunny, cloudy, rainy, neutral }

/// 集中管理的顏色設計系統（design tokens）。所有畫面統一由此取色，方便重複使用與改版。
/// 與 iOS 端 `AppColor` 對齊。
class AppColors {
  const AppColors._();

  // Grounds
  static Color pageBackground(bool isDark) =>
      isDark ? const Color(0xFF0E151C) : const Color(0xFFF0F2F5);
  static Color cardSurface(bool isDark) =>
      isDark ? const Color(0xFF1B222B) : Colors.white;

  /// 縣市卡片標題列底色（靛藍，與天氣色系無關）。
  static Color headerBar(bool isDark) =>
      isDark ? const Color(0xFF262A40) : const Color(0xFFE8EBFB);
  static Color border(bool isDark) =>
      isDark ? const Color(0xFF2A343F) : const Color(0xFFDCE2E9);

  // Text
  static Color textPrimary(bool isDark) =>
      isDark ? const Color(0xFFE7EEF5) : const Color(0xFF16232F);
  static Color textSecondary(bool isDark) =>
      isDark ? const Color(0xFF96A6B6) : const Color(0xFF5C6B7A);

  // Weather palette
  static Color weatherBackground(WeatherCategory category, bool isDark) {
    switch (category) {
      case WeatherCategory.sunny:
        return isDark ? const Color(0xFF342A10) : const Color(0xFFFFF3D4);
      case WeatherCategory.cloudy:
        return isDark ? const Color(0xFF212932) : const Color(0xFFE7EDF4);
      case WeatherCategory.rainy:
        return isDark ? const Color(0xFF122833) : const Color(0xFFD8EAF5);
      case WeatherCategory.neutral:
        return isDark ? const Color(0xFF1C2530) : const Color(0xFFEEF2F6);
    }
  }

  static Color weatherIcon(WeatherCategory category) {
    switch (category) {
      case WeatherCategory.sunny:
        return const Color(0xFFE8940F);
      case WeatherCategory.cloudy:
        return const Color(0xFF7E8A99);
      case WeatherCategory.rainy:
        return const Color(0xFF2E82C8);
      case WeatherCategory.neutral:
        return const Color(0xFF9AA6B2);
    }
  }
}
