import 'package:flutter/material.dart';

/// 錯誤狀態 Widget：顯示對應錯誤字串（輸入無效 / 查無城市 / 資料格式錯誤 / 網路錯誤）。
class WeatherErrorWidget extends StatelessWidget {
  const WeatherErrorWidget({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }
}
