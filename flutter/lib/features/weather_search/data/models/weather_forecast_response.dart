/// CWA `F-C0032-001` 回應結構（僅解析本功能取用的欄位）。
/// 僅存在於 data 層，不外流到 domain / presentation。
///
/// 任一欄位型別不符時，`fromJson` 會拋出型別轉換錯誤，由 Repository 轉為
/// `WeatherErrorType.invalidData`。
class WeatherForecastResponse {
  const WeatherForecastResponse({required this.locations});

  final List<LocationData> locations;

  factory WeatherForecastResponse.fromJson(Map<String, dynamic> json) {
    final records = json['records'] as Map<String, dynamic>;
    final rawLocations = records['location'] as List<dynamic>;
    return WeatherForecastResponse(
      locations: rawLocations
          .map((dynamic e) => LocationData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LocationData {
  const LocationData({required this.locationName, required this.weatherElements});

  final String locationName;
  final List<WeatherElementData> weatherElements;

  factory LocationData.fromJson(Map<String, dynamic> json) {
    final rawElements = json['weatherElement'] as List<dynamic>;
    return LocationData(
      locationName: json['locationName'] as String,
      weatherElements: rawElements
          .map((dynamic e) => WeatherElementData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WeatherElementData {
  const WeatherElementData({required this.elementName, required this.times});

  final String elementName;
  final List<TimeData> times;

  factory WeatherElementData.fromJson(Map<String, dynamic> json) {
    final rawTimes = json['time'] as List<dynamic>;
    return WeatherElementData(
      elementName: json['elementName'] as String,
      times: rawTimes
          .map((dynamic e) => TimeData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TimeData {
  const TimeData({
    required this.startTime,
    required this.endTime,
    required this.parameterName,
  });

  final String startTime;
  final String endTime;
  final String parameterName;

  factory TimeData.fromJson(Map<String, dynamic> json) {
    final parameter = json['parameter'] as Map<String, dynamic>;
    return TimeData(
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      parameterName: parameter['parameterName'] as String,
    );
  }
}
