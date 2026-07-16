import DataModule
import UIKit

/// App 根路由 / composition root。
/// 單一畫面、無跨 feature 導覽，故不預先抽 `Coordinating` protocol 或 feature coordinator（避免過度設計）。
@MainActor
final class AppCoordinator {
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let configuration = APIConfiguration(
            baseURL: Environment.apiBaseURL,
            authorizationKey: Environment.cwaAPIKey
        )
        // 預設使用 URLSessionAPIClient；若有特殊需求（logging / retry 等），可在此注入自訂 APIClient。
        let repository = WeatherRepositoryImpl(configuration: configuration)
        let viewModel = WeatherSearchViewModel(repository: repository)
        let viewController = WeatherSearchViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
