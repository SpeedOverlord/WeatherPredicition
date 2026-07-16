import 'package:equatable/equatable.dart';

/// 單一時段（12 小時）的天氣預報。今明 36 小時共 3 段。
class WeatherPeriod extends Equatable {
  const WeatherPeriod({
    required this.startTime,
    required this.endTime,
    required this.weatherDescription,
    required this.rainProbability,
    required this.minTemperature,
    required this.maxTemperature,
    required this.comfort,
  });

  final String startTime;
  final String endTime;

  /// 天氣現象（Wx），例如「多雲」。
  final String weatherDescription;

  /// 降雨機率（PoP）百分比字串，例如「20」。
  final String rainProbability;

  /// 最低溫（MinT，°C）。
  final String minTemperature;

  /// 最高溫（MaxT，°C）。
  final String maxTemperature;

  /// 舒適度（CI），例如「舒適至悶熱」。
  final String comfort;

  @override
  List<Object?> get props => [
        startTime,
        endTime,
        weatherDescription,
        rainProbability,
        minTemperature,
        maxTemperature,
        comfort,
      ];
}

/// 一個城市的今明 36 小時天氣預報（3 個時段）。
class WeatherForecast extends Equatable {
  const WeatherForecast({required this.cityName, required this.periods});

  final String cityName;
  final List<WeatherPeriod> periods;

  @override
  List<Object?> get props => [cityName, periods];
}
