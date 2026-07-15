import Combine
import Foundation

/// 天氣搜尋 ViewModel 對外介面。VC 只認識此 protocol。
@MainActor
protocol WeatherSearchViewModelProtocol: AnyObject {
    /// 目前狀態（持續性狀態）。
    var state: WeatherSearchState { get }
    /// 狀態變化的 publisher，VC 訂閱後即取得最新值。
    var statePublisher: AnyPublisher<WeatherSearchState, Never> { get }
    /// 使用者輸入城市名並點確認後呼叫。內部負責正規化、驗證、呼叫 API 與狀態切換。
    func search(cityName: String) async
}
