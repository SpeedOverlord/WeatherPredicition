import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/weather_forecast.dart';
import 'weather_style.dart';

/// 氣象資料狀態 Widget：一或多個縣市的**卡片**清單。
/// 每張卡片可點靛藍標題列展開 / 收合；展開時 3 個時段以**三欄並排**呈現，欄位底色依天氣變化。
/// 展開狀態由本容器持有（≈ iOS 的 WeatherContentView），**每次新搜尋一律收合**、主題等重建則保留。
class WeatherContentWidget extends StatefulWidget {
  const WeatherContentWidget({required this.forecasts, super.key});

  final List<WeatherForecast> forecasts;

  @override
  State<WeatherContentWidget> createState() => _WeatherContentWidgetState();
}

class _WeatherContentWidgetState extends State<WeatherContentWidget> {
  final Set<String> _expanded = <String>{};

  @override
  void didUpdateWidget(WeatherContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 新一次搜尋（清單改變）→ 一律收合；主題等其他重建則保留展開狀態。
    if (!listEquals(oldWidget.forecasts, widget.forecasts)) {
      _expanded.clear();
    }
  }

  void _toggle(String city) {
    setState(() {
      if (!_expanded.remove(city)) {
        _expanded.add(city);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2),
          child: Text(
            '共 ${widget.forecasts.length} 個縣市',
            style: AppTextStyles.listCount.copyWith(color: AppColors.textSecondary(isDark)),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: widget.forecasts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final forecast = widget.forecasts[index];
              return _CityCard(
                forecast: forecast,
                expanded: _expanded.contains(forecast.cityName),
                onToggle: () => _toggle(forecast.cityName),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CityCard extends StatelessWidget {
  const _CityCard({required this.forecast, required this.expanded, required this.onToggle});

  final WeatherForecast forecast;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final periods = forecast.periods;
    final first = periods.isNotEmpty ? periods.first : null;
    final summary = first == null
        ? ''
        : '${first.weatherDescription} ${first.minTemperature}–${first.maxTemperature}°';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.cardSurface(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(isDark), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 靛藍標題列（與天氣色無關）
          InkWell(
            onTap: onToggle,
            child: Container(
              color: AppColors.headerBar(isDark),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      forecast.cityName,
                      style: AppTextStyles.cityTitle.copyWith(color: AppColors.textPrimary(isDark)),
                    ),
                  ),
                  Text(
                    summary,
                    style: AppTextStyles.summary.copyWith(color: AppColors.textSecondary(isDark)),
                  ),
                  const SizedBox(width: 8),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more, size: 22),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.all(12),
              // IntrinsicHeight 給 Row 有界的高度，讓三欄等高（stretch）且不觸發版面錯誤。
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < periods.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(child: _PeriodColumn(period: periods[i], isDark: isDark)),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PeriodColumn extends StatelessWidget {
  const _PeriodColumn({required this.period, required this.isDark});

  final WeatherPeriod period;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final category = WeatherStyle.categoryOf(period.weatherDescription);
    final primary = AppColors.textPrimary(isDark);
    final secondary = AppColors.textSecondary(isDark);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.weatherBackground(category, isDark),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${period.startTime}\n~ ${period.endTime}',
              style: AppTextStyles.periodTime.copyWith(color: secondary)),
          const SizedBox(height: 8),
          Icon(WeatherStyle.icon(category), size: 26, color: AppColors.weatherIcon(category)),
          const SizedBox(height: 8),
          Text(period.weatherDescription, style: AppTextStyles.weather.copyWith(color: primary)),
          const SizedBox(height: 4),
          Text('${period.minTemperature}–${period.maxTemperature}°C',
              style: AppTextStyles.temperature.copyWith(color: primary)),
          const SizedBox(height: 4),
          Text('降雨 ${period.rainProbability}%', style: AppTextStyles.caption.copyWith(color: secondary)),
          const SizedBox(height: 2),
          Text(period.comfort, style: AppTextStyles.caption.copyWith(color: secondary)),
        ],
      ),
    );
  }
}
