/// CWA 天氣 API 端點路徑（相對於 base URL），集中管理避免散落。與 iOS 端 `WeatherEndpoint` 對齊。
class WeatherEndpoint {
  const WeatherEndpoint._();

  /// 一般天氣預報－今明 36 小時天氣預報。
  static const String thirtySixHourForecast = 'v1/rest/datastore/F-C0032-001';
}
