import '../../domain/entities/weather_exception.dart';
import '../../domain/entities/weather_forecast.dart';
import '../models/weather_forecast_response.dart';

/// 將 API 的 `LocationData`（各要素平行時段陣列）轉為以「時段」為主的領域實體。
class WeatherForecastMapper {
  const WeatherForecastMapper();

  /// 缺少必要要素或各要素時段數不一致 / 為 0 時，拋出
  /// `WeatherException(WeatherErrorType.invalidData)`。
  WeatherForecast map(LocationData location) {
    final elementsByName = <String, List<TimeData>>{
      for (final element in location.weatherElements) element.elementName: element.times,
    };

    final wx = elementsByName['Wx'];
    if (wx == null || wx.isEmpty) {
      throw const WeatherException(WeatherErrorType.invalidData);
    }
    final periodCount = wx.length;

    // 取出與 Wx 時段數對齊的要素，缺少或不對齊即視為資料格式錯誤。
    List<TimeData> aligned(String name) {
      final times = elementsByName[name];
      if (times == null || times.length != periodCount) {
        throw const WeatherException(WeatherErrorType.invalidData);
      }
      return times;
    }

    final pop = aligned('PoP');
    final minT = aligned('MinT');
    final maxT = aligned('MaxT');
    final ci = aligned('CI');

    final periods = List<WeatherPeriod>.generate(periodCount, (index) {
      return WeatherPeriod(
        startTime: wx[index].startTime,
        endTime: wx[index].endTime,
        weatherDescription: wx[index].parameterName,
        rainProbability: pop[index].parameterName,
        minTemperature: minT[index].parameterName,
        maxTemperature: maxT[index].parameterName,
        comfort: ci[index].parameterName,
      );
    });

    return WeatherForecast(cityName: location.locationName, periods: periods);
  }
}
