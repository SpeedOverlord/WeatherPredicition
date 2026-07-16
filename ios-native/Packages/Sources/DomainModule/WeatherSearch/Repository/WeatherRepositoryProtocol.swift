import Foundation

/// 取得天氣預報的 Repository 介面。
///
/// 取回**全部縣市**的今明 36 小時預報（不帶 locationName），縣市過濾由呼叫端進行。
/// 實作者負責呼叫 API、解析，並把失敗轉為 ``WeatherError``：
/// - 無法解析 / 缺欄位 → ``WeatherError/invalidData``
/// - 網路 / 401 / 5xx → ``WeatherError/requestFailed``
public protocol WeatherRepositoryProtocol: Sendable {
    func fetchAllForecasts() async throws -> [WeatherForecastModel]
}
