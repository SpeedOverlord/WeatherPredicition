import Foundation

/// 一個城市的今明 36 小時天氣預報（3 個時段）。
public struct WeatherForecastModel: Equatable, Sendable {
    public let cityName: String
    public let periods: [WeatherPeriodModel]

    public init(cityName: String, periods: [WeatherPeriodModel]) {
        self.cityName = cityName
        self.periods = periods
    }
}
