import DomainModule
import Foundation

/// 測試用假 Repository。@MainActor 隔離，供 @MainActor 的 ViewModel 測試安全存取呼叫紀錄。
@MainActor
final class MockWeatherRepository: WeatherRepositoryProtocol {
    var result: Result<[WeatherForecastModel], Error> = .success([])
    private(set) var callCount = 0

    func fetchAllForecasts() async throws -> [WeatherForecastModel] {
        callCount += 1
        return try result.get()
    }
}
