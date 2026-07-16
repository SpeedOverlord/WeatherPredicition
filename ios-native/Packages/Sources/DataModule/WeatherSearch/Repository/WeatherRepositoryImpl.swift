import DomainModule
import Foundation

/// ``WeatherRepositoryProtocol`` 的實作：透過注入的 ``APIClient`` 取得全部縣市預報、解析，
/// 並將失敗轉為 ``WeatherError``。網路細節（送出請求、狀態碼）由 client 負責，
/// 本型別只負責組請求、解碼與領域對應。
public final class WeatherRepositoryImpl: WeatherRepositoryProtocol {
    private let client: APIClient
    private let configuration: APIConfiguration

    /// - Parameters:
    ///   - configuration: base URL 與授權碼（由 App 層注入）。
    ///   - client: 網路實作，預設 ``URLSessionAPIClient``；App / 測試可注入自訂或 mock。
    public init(configuration: APIConfiguration, client: APIClient = URLSessionAPIClient()) {
        self.configuration = configuration
        self.client = client
    }

    public func fetchAllForecasts() async throws -> [WeatherForecastModel] {
        let request = try makeForecastRequest()

        let data: Data
        do {
            data = try await client.data(for: request)
        } catch APIError.unacceptableStatusCode(401) {
            // 授權失敗單獨處理，方便辨識金鑰問題。
            throw WeatherError.unauthorized
        } catch {
            // 其餘傳輸 / 非 2xx（逾時、5xx 等）歸為 requestFailed。
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

    /// 組出「不帶 locationName（取回全部縣市）+ 授權碼」的請求。
    private func makeForecastRequest() throws -> URLRequest {
        let endpointURL = configuration.baseURL.appendingPathComponent(WeatherEndpoint.thirtySixHourForecast)
        guard var components = URLComponents(url: endpointURL, resolvingAgainstBaseURL: false) else {
            throw WeatherError.requestFailed
        }
        components.queryItems = [
            URLQueryItem(name: "Authorization", value: configuration.authorizationKey),
        ]
        guard let url = components.url else {
            throw WeatherError.requestFailed
        }
        return URLRequest(url: url)
    }
}
