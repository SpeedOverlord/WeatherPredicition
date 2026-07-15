import DomainModule
import Foundation

/// 供 diffable data source 使用的 Hashable 展示列，由 ``WeatherPeriodModel`` 轉出。
/// `cityName` + `index` 提供跨縣市唯一穩定識別。
struct WeatherPeriodRow: Hashable {
    let cityName: String
    let index: Int
    let startTime: String
    let endTime: String
    let weatherDescription: String
    let rainProbability: String
    let minTemperature: String
    let maxTemperature: String
    let comfort: String

    init(cityName: String, index: Int, period: WeatherPeriodModel) {
        self.cityName = cityName
        self.index = index
        self.startTime = period.startTime
        self.endTime = period.endTime
        self.weatherDescription = period.weatherDescription
        self.rainProbability = period.rainProbability
        self.minTemperature = period.minTemperature
        self.maxTemperature = period.maxTemperature
        self.comfort = period.comfort
    }
}
