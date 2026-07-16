import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 讀取中狀態 Widget：畫面內 inline loading（非 Dialog）。
class WeatherLoadingWidget extends StatelessWidget {
  const WeatherLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.textSecondary(Theme.of(context).brightness == Brightness.dark);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('讀取中…', style: AppTextStyles.body.copyWith(color: color)),
        ],
      ),
    );
  }
}
