import Foundation

/// 抽象的網路請求介面。定義於 DataModule；App target 可注入自訂實作（logging / retry / stub 等），
/// 測試可注入 mock。保持最小：只負責「送出請求 → 回傳原始 Data」，不含解碼與領域邏輯。
public protocol APIClient: Sendable {
    /// 發出請求並回傳原始資料。傳輸失敗或非 2xx 時拋出 ``APIError``。
    func data(for request: URLRequest) async throws -> Data
}

/// 網路層錯誤（與領域錯誤 `WeatherError` 分離，讓 client 可被不同 repository 重複使用）。
public enum APIError: Error, Sendable, Equatable {
    /// 網路中斷 / 逾時等傳輸層錯誤。
    case transport
    /// 非 2xx 狀態碼（含授權失敗 401、伺服器 5xx）。
    case unacceptableStatusCode(Int)
    /// 回應不是 HTTP 回應。
    case invalidResponse
}
