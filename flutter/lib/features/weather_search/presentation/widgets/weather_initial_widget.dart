import 'package:flutter/material.dart';

/// 初始狀態 Widget：尚未輸入 / 尚未搜尋時顯示提示。
class WeatherInitialWidget extends StatelessWidget {
  const WeatherInitialWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 48, color: color),
          const SizedBox(height: 16),
          Text(
            '輸入城市名稱並點「確認」查詢天氣',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }
}
