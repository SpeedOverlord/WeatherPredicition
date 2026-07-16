import 'package:flutter/material.dart';

/// 集中管理的字體設計系統（design tokens）。size / weight 由此提供，顏色於使用處套用。
/// 與 iOS 端 `AppFont` 對齊。
class AppTextStyles {
  const AppTextStyles._();

  /// 縣市卡片標題（縣市名）。
  static const TextStyle cityTitle = TextStyle(fontSize: 19, fontWeight: FontWeight.bold);

  /// 清單結果數（「共 N 個縣市」）。
  static const TextStyle listCount = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);

  /// 卡片標題列右側今日摘要。
  static const TextStyle summary = TextStyle(fontSize: 14);

  /// 時段欄的起訖時間。
  static const TextStyle periodTime = TextStyle(fontSize: 11, fontWeight: FontWeight.w500);

  /// 時段欄的天氣現象。
  static const TextStyle weather = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  /// 時段欄的溫度。
  static const TextStyle temperature = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

  /// 時段欄的降雨 / 舒適度等註記。
  static const TextStyle caption = TextStyle(fontSize: 12);

  /// 一般狀態視圖（初始 / 讀取中 / 錯誤）的說明文字。
  static const TextStyle body = TextStyle(fontSize: 16);
}
