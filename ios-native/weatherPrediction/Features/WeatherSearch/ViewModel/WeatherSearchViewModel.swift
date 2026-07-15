import Combine
import DomainModule
import Foundation

@MainActor
final class WeatherSearchViewModel: WeatherSearchViewModelProtocol {
    @Published private(set) var state: WeatherSearchState = .initial
    var statePublisher: AnyPublisher<WeatherSearchState, Never> { $state.eraseToAnyPublisher() }

    private let repository: WeatherRepositoryProtocol

    init(repository: WeatherRepositoryProtocol) {
        self.repository = repository
    }

    func search(cityName: String) async {
        let targets = CityNameResolver.resolve(cityName)
        guard !targets.isEmpty else {
            // 非空輸入無法對應任何有效縣市前綴 → 查無城市（不呼叫 API）。
            state = .error(WeatherErrorMessage.text(for: .cityNotFound))
            return
        }

        state = .loading
        do {
            let all = try await repository.fetchAllForecasts()
            let targetSet = Set(targets)
            let filtered = all.filter { targetSet.contains($0.cityName) }
            if filtered.isEmpty {
                state = .error(WeatherErrorMessage.text(for: .cityNotFound))
            } else {
                state = .loaded(filtered)
            }
        } catch let error as WeatherError {
            state = .error(WeatherErrorMessage.text(for: error))
        } catch {
            state = .error(WeatherErrorMessage.text(for: .requestFailed))
        }
    }
}
