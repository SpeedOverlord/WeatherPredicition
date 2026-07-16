import UIKit

/// 集中管理的顏色設計系統（design tokens）。所有畫面統一由此取色，方便重複使用與改版。
/// 皆為動態色，隨明暗主題自動切換。
enum AppColor {
    // MARK: - Grounds

    /// 清單頁背景（讓卡片浮出）。
    static let background = UIColor.systemGroupedBackground
    /// 卡片表面。
    static let cardSurface = UIColor.secondarySystemGroupedBackground
    /// 縣市卡片標題列底色（靛藍，與天氣色系無關）。
    static let headerBar = dynamic(light: rgb(232, 235, 251), dark: rgb(38, 42, 64))
    /// 一般狀態視圖（初始 / 讀取中 / 錯誤）背景。
    static let plainBackground = UIColor.systemBackground
    static let separator = UIColor.separator

    // MARK: - Text

    static let textPrimary = UIColor.label
    static let textSecondary = UIColor.secondaryLabel
    static let textTertiary = UIColor.tertiaryLabel

    // MARK: - Accent / semantic

    static let accent = UIColor.systemBlue
    static let warning = UIColor.systemOrange

    // MARK: - Weather palette

    /// 依天氣分類的卡片底色。
    static func weatherBackground(_ category: WeatherCategory) -> UIColor {
        switch category {
        case .sunny:
            return dynamic(light: rgb(255, 243, 212), dark: rgb(52, 42, 16))
        case .cloudy:
            return dynamic(light: rgb(231, 237, 244), dark: rgb(33, 41, 50))
        case .rainy:
            return dynamic(light: rgb(216, 234, 245), dark: rgb(18, 40, 51))
        case .neutral:
            return .secondarySystemBackground
        }
    }

    /// 依天氣分類的圖示顏色。
    static func weatherIcon(_ category: WeatherCategory) -> UIColor {
        switch category {
        case .sunny: return .systemOrange
        case .cloudy: return .systemGray
        case .rainy: return .systemBlue
        case .neutral: return .systemGray2
        }
    }

    // MARK: - Helpers

    private static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
        UIColor(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
    }

    private static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { $0.userInterfaceStyle == .dark ? dark : light }
    }
}
