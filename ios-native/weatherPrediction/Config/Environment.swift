import Foundation

/// 執行期組態。API 授權碼由 gitignored 的 `Secrets.xcconfig` → Info.plist 注入，程式在此讀入。
enum Environment {
    /// CWA API 授權碼。缺少時回傳空字串（呼叫 API 會得到授權失敗 → 錯誤狀態）。
    static var cwaAPIKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "CWA_API_KEY") as? String) ?? ""
    }

    /// F-C0032-001 端點。
    static let weatherBaseURL = URL(
        string: "https://opendata.cwa.gov.tw/api/v1/rest/datastore/F-C0032-001"
    )!
}
