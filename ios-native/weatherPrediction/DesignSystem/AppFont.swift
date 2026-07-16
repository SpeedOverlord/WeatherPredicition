import UIKit

/// 集中管理的字體設計系統（design tokens）。所有畫面統一由此取字體，方便重複使用與改版。
enum AppFont {
    /// 縣市卡片標題（縣市名）。
    static let cityTitle = UIFont.systemFont(ofSize: 19, weight: .bold)
    /// 清單結果數（「共 N 個縣市」）。
    static let listCount = UIFont.systemFont(ofSize: 13, weight: .semibold)
    /// 卡片標題列右側今日摘要。
    static let summary = UIFont.systemFont(ofSize: 14, weight: .regular)
    /// 時段欄的起訖時間。
    static let periodTime = UIFont.systemFont(ofSize: 11, weight: .medium)
    /// 時段欄的天氣現象。
    static let weather = UIFont.systemFont(ofSize: 16, weight: .bold)
    /// 時段欄的溫度。
    static let temperature = UIFont.systemFont(ofSize: 14, weight: .semibold)
    /// 時段欄的降雨 / 舒適度等註記。
    static let caption = UIFont.systemFont(ofSize: 12, weight: .regular)
    /// 一般狀態視圖（初始 / 讀取中 / 錯誤）的說明文字。
    static let body = UIFont.systemFont(ofSize: 16, weight: .regular)
}
