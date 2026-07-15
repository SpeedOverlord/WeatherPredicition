import 'package:flutter/material.dart';

import '../../domain/entities/weather_forecast.dart';

/// 氣象資料狀態 Widget：一或多個縣市的清單，每個縣市含縣市名 + 3 個時段（今明 36 小時）。
class WeatherContentWidget extends StatelessWidget {
  const WeatherContentWidget({required this.forecasts, super.key});

  final List<WeatherForecast> forecasts;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: forecasts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 24),
      itemBuilder: (context, index) => _CitySection(forecast: forecasts[index]),
    );
  }
}

class _CitySection extends StatelessWidget {
  const _CitySection({required this.forecast});

  final WeatherForecast forecast;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          forecast.cityName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        for (final period in forecast.periods) ...[
          _PeriodCard(period: period),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.period});

  final WeatherPeriod period;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${period.startTime} ~ ${period.endTime}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            period.weatherDescription,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${period.minTemperature}°C ~ ${period.maxTemperature}°C',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            '降雨機率 ${period.rainProbability}%　舒適度 ${period.comfort}',
            style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
