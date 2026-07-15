import '../../domain/entities/weather_exception.dart';

/// 將領域錯誤類型轉為要顯示給使用者的訊息（presentation 文案）。與 iOS 端一致。
class WeatherErrorMessage {
  const WeatherErrorMessage._();

  static String text(WeatherErrorType type) {
    switch (type) {
      case WeatherErrorType.cityNotFound:
        return '查無此城市，請確認名稱後再試';
      case WeatherErrorType.invalidData:
        return '資料格式不正確，請稍後再試';
      case WeatherErrorType.requestFailed:
        return '連線失敗，請檢查網路或稍後再試';
    }
  }
}
