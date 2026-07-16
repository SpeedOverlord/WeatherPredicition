import Foundation

/// 預設以 `URLSession` 實作的 ``APIClient``。放在 DataModule，讓 SPM 自成一體、可獨立測試；
/// App target 若有特殊需求可提供自訂實作覆寫。無可變狀態，Sendable。
public final class URLSessionAPIClient: APIClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func data(for request: URLRequest) async throws -> Data {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.transport
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.unacceptableStatusCode(httpResponse.statusCode)
        }
        return data
    }
}
