import Foundation

/// CWA 天氣 API 的端點路徑（相對於 ``APIConfiguration/baseURL``），集中管理避免散落各處。
enum WeatherEndpoint {
    /// 一般天氣預報－今明 36 小時天氣預報。
    static let thirtySixHourForecast = "v1/rest/datastore/F-C0032-001"
}
