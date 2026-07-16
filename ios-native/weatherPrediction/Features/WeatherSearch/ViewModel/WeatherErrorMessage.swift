import DomainModule
import Foundation

/// 將領域錯誤轉為要顯示給使用者的訊息（presentation 文案）。
enum WeatherErrorMessage {
    static func text(for error: WeatherError) -> String {
        switch error {
        case .cityNotFound:
            return "查無此城市，請確認名稱後再試"
        case .invalidData:
            return "資料格式不正確，請稍後再試"
        case .requestFailed:
            return "連線失敗，請檢查網路或稍後再試"
        case .unauthorized:
            return "授權失敗，請確認 API 授權碼"
        }
    }
}
