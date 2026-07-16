import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_configuration.dart';
import '../../domain/entities/weather_exception.dart';
import '../../domain/entities/weather_forecast.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_endpoint.dart';
import '../mappers/weather_forecast_mapper.dart';
import '../models/weather_forecast_response.dart';

/// `WeatherRepository` 的實作：透過注入的 [ApiClient] 取得全部縣市預報、解析，
/// 並將失敗轉為 `WeatherException`。網路細節由 client 負責，本型別只負責組請求、解析與領域對應。
class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl({required this.client, required this.configuration});

  final ApiClient client;
  final ApiConfiguration configuration;
  static const WeatherForecastMapper _mapper = WeatherForecastMapper();

  @override
  Future<List<WeatherForecast>> fetchAllForecasts() async {
    final dynamic data;
    try {
      // 不帶 locationName → API 回傳全部縣市。
      data = await client.get(
        '${configuration.baseUrl}/${WeatherEndpoint.thirtySixHourForecast}',
        queryParameters: {'Authorization': configuration.authorizationKey},
      );
    } on ApiException catch (e) {
      // 授權失敗（401）單獨處理，方便辨識金鑰問題；其餘傳輸 / 5xx 歸為 requestFailed。
      if (e.type == ApiErrorType.unacceptableStatusCode && e.statusCode == 401) {
        throw const WeatherException(WeatherErrorType.unauthorized);
      }
      throw const WeatherException(WeatherErrorType.requestFailed);
    }

    final WeatherForecastResponse parsed;
    try {
      parsed = WeatherForecastResponse.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      throw const WeatherException(WeatherErrorType.invalidData);
    }

    return parsed.locations.map(_mapper.map).toList();
  }
}
