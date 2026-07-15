import DomainModule
import Foundation

/// ``WeatherRepositoryProtocol`` 的實作：呼叫 CWA `F-C0032-001`、解析、並將失敗轉為 ``WeatherError``。
/// 無可變狀態，設計為 stateless（Sendable）。
public final class WeatherRepositoryImpl: WeatherRepositoryProtocol {
    private let baseURL: URL
    private let apiKey: String
    private let session: URLSession

    /// - Parameters:
    ///   - baseURL: F-C0032-001 端點。
    ///   - apiKey: CWA 授權碼（由 App 層從 gitignored 設定讀入後注入）。
    public init(
        baseURL: URL = URL(string: "https://opendata.cwa.gov.tw/api/v1/rest/datastore/F-C0032-001")!,
        apiKey: String,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.session = session
    }

    public func fetchAllForecasts() async throws -> [WeatherForecastModel] {
        // 不帶 locationName → API 回傳全部縣市。
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "Authorization", value: apiKey),
        ]
        guard let url = components?.url else {
            throw WeatherError.requestFailed
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw WeatherError.requestFailed
        }

        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw WeatherError.requestFailed
        }

        let decoded: WeatherForecastResponse
        do {
            decoded = try JSONDecoder().decode(WeatherForecastResponse.self, from: data)
        } catch {
            throw WeatherError.invalidData
        }

        return try decoded.records.location.map { try WeatherForecastMapper.map($0) }
    }
}
