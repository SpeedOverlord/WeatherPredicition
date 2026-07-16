import Foundation

/// API 連線設定：base URL 與授權碼。由 App target（composition root）注入，
/// 讓 base URL / 金鑰不散落在 DataModule 內。
public struct APIConfiguration: Sendable {
    public let baseURL: URL
    public let authorizationKey: String

    public init(baseURL: URL, authorizationKey: String) {
        self.baseURL = baseURL
        self.authorizationKey = authorizationKey
    }
}
