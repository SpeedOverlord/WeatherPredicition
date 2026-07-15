import 'package:dio/dio.dart';

import '../../domain/entities/weather_exception.dart';
import '../../domain/entities/weather_forecast.dart';
import '../../domain/repositories/weather_repository.dart';
import '../mappers/weather_forecast_mapper.dart';
import '../models/weather_forecast_response.dart';

/// `WeatherRepository` 的實作：呼叫 CWA `F-C0032-001`、解析、並將失敗轉為 `WeatherException`。
class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl({
    required this.dio,
    required this.apiKey,
    this.baseUrl = 'https://opendata.cwa.gov.tw/api/v1/rest/datastore/F-C0032-001',
  });

  final Dio dio;
  final String apiKey;
  final String baseUrl;
  static const WeatherForecastMapper _mapper = WeatherForecastMapper();

  @override
  Future<List<WeatherForecast>> fetchAllForecasts() async {
    late final Response<dynamic> response;
    try {
      // 不帶 locationName → API 回傳全部縣市。
      response = await dio.get<dynamic>(
        baseUrl,
        queryParameters: {'Authorization': apiKey},
      );
    } on DioException {
      // 網路中斷 / 逾時 / 401 / 5xx 皆歸為 requestFailed。
      throw const WeatherException(WeatherErrorType.requestFailed);
    }

    final WeatherForecastResponse parsed;
    try {
      parsed = WeatherForecastResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      throw const WeatherException(WeatherErrorType.invalidData);
    }

    return parsed.locations.map(_mapper.map).toList();
  }
}
