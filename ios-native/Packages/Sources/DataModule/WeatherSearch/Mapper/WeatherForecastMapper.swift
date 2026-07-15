import DomainModule
import Foundation

/// 將 API 的 `Location`（各要素平行時段陣列）轉為以「時段」為主的領域模型。
enum WeatherForecastMapper {
    /// - Throws: ``WeatherError/invalidData`` 當缺少必要要素或各要素時段數不一致 / 為 0。
    static func map(_ location: WeatherForecastResponse.Location) throws -> WeatherForecastModel {
        var elementsByName: [String: [WeatherForecastResponse.TimePeriod]] = [:]
        for element in location.weatherElement {
            elementsByName[element.elementName] = element.time
        }

        guard let wx = elementsByName["Wx"], !wx.isEmpty else {
            throw WeatherError.invalidData
        }
        let periodCount = wx.count

        // 取出與 Wx 時段數對齊的要素，缺少或不對齊即視為資料格式錯誤。
        func aligned(_ name: String) throws -> [WeatherForecastResponse.TimePeriod] {
            guard let times = elementsByName[name], times.count == periodCount else {
                throw WeatherError.invalidData
            }
            return times
        }

        let pop = try aligned("PoP")
        let minT = try aligned("MinT")
        let maxT = try aligned("MaxT")
        let ci = try aligned("CI")

        let periods = (0..<periodCount).map { index in
            WeatherPeriodModel(
                startTime: wx[index].startTime,
                endTime: wx[index].endTime,
                weatherDescription: wx[index].parameter.parameterName,
                rainProbability: pop[index].parameter.parameterName,
                minTemperature: minT[index].parameter.parameterName,
                maxTemperature: maxT[index].parameter.parameterName,
                comfort: ci[index].parameter.parameterName
            )
        }
        return WeatherForecastModel(cityName: location.locationName, periods: periods)
    }
}
