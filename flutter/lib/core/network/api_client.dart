/// 抽象網路請求介面。App 可注入自訂實作、測試可注入 mock。與 iOS 端 `APIClient` 對齊。
/// 最小職責：送出請求 → 回傳已解析的回應資料；不含解碼成領域模型與領域邏輯。
abstract class ApiClient {
  Future<dynamic> get(String url, {Map<String, dynamic>? queryParameters});
}

/// 網路層錯誤類型（與領域錯誤 `WeatherException` 分離，讓 client 可被不同 repository 重複使用）。
enum ApiErrorType { transport, unacceptableStatusCode, invalidResponse }

class ApiException implements Exception {
  const ApiException(this.type, {this.statusCode});

  final ApiErrorType type;
  final int? statusCode;

  @override
  String toString() => 'ApiException($type, status: $statusCode)';
}
