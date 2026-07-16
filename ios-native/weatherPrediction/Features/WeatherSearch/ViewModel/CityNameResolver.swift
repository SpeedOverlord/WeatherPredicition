import Foundation

/// 將使用者輸入解析為要顯示的目標縣市名清單。
///
/// 規則（見 spec 流程 1 步驟 3）：
/// - 正規化：trim + 「台」→「臺」。
/// - 空輸入 → 全部縣市。
/// - 以正規化字串為前綴的縣市 → 全部符合者（可能多個，如「新竹」→ 新竹縣 + 新竹市）。
/// - 無符合 → 空陣列（呼叫端視為查無城市）。
enum CityNameResolver {
    /// CWA F-C0032-001 的有效 locationName（22 縣市）。
    static let allCities = [
        "宜蘭縣", "花蓮縣", "臺東縣", "澎湖縣", "金門縣", "連江縣",
        "臺北市", "新北市", "桃園市", "臺中市", "臺南市", "高雄市",
        "基隆市", "新竹縣", "新竹市", "苗栗縣", "彰化縣", "南投縣",
        "雲林縣", "嘉義縣", "嘉義市", "屏東縣",
    ]

    static func resolve(_ input: String) -> [String] {
        let normalized = input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "台", with: "臺")
        if normalized.isEmpty {
            return allCities
        }
        return allCities.filter { $0.hasPrefix(normalized) }
    }
}
