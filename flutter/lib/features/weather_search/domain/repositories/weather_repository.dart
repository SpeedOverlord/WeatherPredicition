import '../entities/weather_forecast.dart';

/// 取得天氣預報的 Repository 介面。
///
/// 取回**全部縣市**的今明 36 小時預報（不帶 locationName），縣市過濾由呼叫端進行。
/// 實作者負責呼叫 API、解析、並把失敗轉為 `WeatherException`：
/// - 無法解析 / 缺欄位 → `WeatherErrorType.invalidData`
/// - 網路 / 401 / 5xx → `WeatherErrorType.requestFailed`
abstract class WeatherRepository {
  Future<List<WeatherForecast>> fetchAllForecasts();
}
