import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 初始狀態 Widget：尚未輸入 / 尚未搜尋時顯示提示。
class WeatherInitialWidget extends StatelessWidget {
  const WeatherInitialWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.textSecondary(Theme.of(context).brightness == Brightness.dark);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 48, color: color),
          const SizedBox(height: 16),
          Text(
            '輸入城市名稱並點「確認」查詢天氣',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
