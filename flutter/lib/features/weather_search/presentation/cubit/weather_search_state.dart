import 'package:equatable/equatable.dart';

import '../../domain/entities/weather_forecast.dart';

/// 顯示區塊的四種狀態（對應 spec：初始 / 讀取中 / 氣象資料 / 錯誤）。
enum WeatherSearchStatus { initial, loading, loaded, error }

class WeatherSearchState extends Equatable {
  const WeatherSearchState({
    this.status = WeatherSearchStatus.initial,
    this.forecasts = const [],
    this.errorMessage,
  });

  const WeatherSearchState.initial() : this();

  final WeatherSearchStatus status;

  /// 氣象資料狀態時，顯示的縣市清單（1 或多筆）。
  final List<WeatherForecast> forecasts;
  final String? errorMessage;

  WeatherSearchState copyWith({
    WeatherSearchStatus? status,
    List<WeatherForecast>? forecasts,
    String? errorMessage,
  }) {
    return WeatherSearchState(
      status: status ?? this.status,
      forecasts: forecasts ?? this.forecasts,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, forecasts, errorMessage];
}
