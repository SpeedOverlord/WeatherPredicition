import Foundation

/// 天氣現象（Wx）文字的語意分類。實際顏色由 ``AppColor`` 提供、圖示名見下方。
enum WeatherCategory {
    case sunny
    case cloudy
    case rainy
    case neutral
}

enum WeatherStyle {
    /// 依 Wx 文字關鍵字分類。優先序：雨/雷 → 晴 → 多雲/陰 → 其他。
    static func category(for description: String) -> WeatherCategory {
        if description.contains("雨") || description.contains("雷") {
            return .rainy
        }
        if description.contains("晴") {
            return .sunny
        }
        if description.contains("雲") || description.contains("陰") {
            return .cloudy
        }
        return .neutral
    }

    /// 對應的 SF Symbol 名稱。
    static func iconName(for category: WeatherCategory) -> String {
        switch category {
        case .sunny: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        case .neutral: return "cloud.sun.fill"
        }
    }
}
