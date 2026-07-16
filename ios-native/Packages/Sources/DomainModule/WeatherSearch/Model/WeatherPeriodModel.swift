import Foundation

/// 單一時段（12 小時）的天氣預報。今明 36 小時共 3 段。
public struct WeatherPeriodModel: Equatable, Sendable {
    public let startTime: String
    public let endTime: String
    /// 天氣現象（Wx），例如「多雲」。
    public let weatherDescription: String
    /// 降雨機率（PoP）百分比字串，例如「20」。
    public let rainProbability: String
    /// 最低溫（MinT，°C）。
    public let minTemperature: String
    /// 最高溫（MaxT，°C）。
    public let maxTemperature: String
    /// 舒適度（CI），例如「舒適至悶熱」。
    public let comfort: String

    public init(
        startTime: String,
        endTime: String,
        weatherDescription: String,
        rainProbability: String,
        minTemperature: String,
        maxTemperature: String,
        comfort: String
    ) {
        self.startTime = startTime
        self.endTime = endTime
        self.weatherDescription = weatherDescription
        self.rainProbability = rainProbability
        self.minTemperature = minTemperature
        self.maxTemperature = maxTemperature
        self.comfort = comfort
    }
}
