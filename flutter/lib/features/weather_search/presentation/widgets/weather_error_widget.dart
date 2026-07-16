import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 錯誤狀態 Widget：顯示對應錯誤字串（查無城市 / 資料格式錯誤 / 網路錯誤）。
class WeatherErrorWidget extends StatelessWidget {
  const WeatherErrorWidget({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.textSecondary(Theme.of(context).brightness == Brightness.dark);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
