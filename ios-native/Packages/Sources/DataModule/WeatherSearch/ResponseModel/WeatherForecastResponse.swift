import Foundation

/// CWA `F-C0032-001` 回應結構（僅解析本功能取用的欄位）。
/// 僅存在於 DataModule，不外流到 Domain / App 層。
struct WeatherForecastResponse: Decodable {
    let records: Records

    struct Records: Decodable {
        let location: [Location]
    }

    struct Location: Decodable {
        let locationName: String
        let weatherElement: [WeatherElement]
    }

    struct WeatherElement: Decodable {
        let elementName: String
        let time: [TimePeriod]
    }

    struct TimePeriod: Decodable {
        let startTime: String
        let endTime: String
        let parameter: Parameter
    }

    struct Parameter: Decodable {
        let parameterName: String
    }
}
