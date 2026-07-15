import Foundation

/// 天氣搜尋的領域錯誤。對應 spec 的錯誤路徑（流程 2b–2d）。
public enum WeatherError: Error, Equatable, Sendable {
    /// 輸入無法對應任何有效縣市前綴（流程 2b）。由 presentation 層判定。
    case cityNotFound
    /// API 回應無法解析 / 缺必要欄位（流程 2c）。
    case invalidData
    /// 網路中斷 / 逾時 / 授權失敗(401) / 伺服器錯誤(5xx)（流程 2d）。
    case requestFailed
}
