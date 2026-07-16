import 'package:dio/dio.dart';

import 'api_client.dart';

/// 預設以 dio 實作的 [ApiClient]。放在 core，讓資料層依賴抽象而非 dio；
/// App 有特殊需求（logging / retry 等）可注入自訂實作、測試可注入 mock。與 iOS 端 `URLSessionAPIClient` 對齊。
class DioApiClient implements ApiClient {
  DioApiClient({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  @override
  Future<dynamic> get(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get<dynamic>(url, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      final response = e.response;
      if (response != null) {
        // 非 2xx（含 401、5xx）。
        throw ApiException(ApiErrorType.unacceptableStatusCode, statusCode: response.statusCode);
      }
      // 網路中斷 / 逾時等傳輸層錯誤。
      throw const ApiException(ApiErrorType.transport);
    }
  }
}
