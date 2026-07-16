import Foundation

/// 執行期組態。API 授權碼由 gitignored 的 `Secrets.xcconfig` → Info.plist 注入，程式在此讀入。
enum Environment {
    /// CWA API 授權碼。缺少時回傳空字串（呼叫 API 會得到授權失敗 → 錯誤狀態）。
    static var cwaAPIKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "CWA_API_KEY") as? String) ?? ""
    }

    /// CWA 開放資料 API 的 base URL（端點路徑由 DataModule 的 WeatherEndpoint 集中管理）。
    static let apiBaseURL = URL(string: "https://opendata.cwa.gov.tw/api")!
}
