import DomainModule
import Foundation

/// 顯示區塊的四種狀態（對應 spec：初始 / 讀取中 / 氣象資料 / 錯誤）。
enum WeatherSearchState: Equatable {
    case initial
    case loading
    case loaded([WeatherForecastModel])
    case error(String)
}
