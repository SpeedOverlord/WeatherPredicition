import 'package:flutter/material.dart';

/// 讀取中狀態 Widget：畫面內 inline loading（非 Dialog）。
class WeatherLoadingWidget extends StatelessWidget {
  const WeatherLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('讀取中…', style: TextStyle(fontSize: 16, color: color)),
        ],
      ),
    );
  }
}
