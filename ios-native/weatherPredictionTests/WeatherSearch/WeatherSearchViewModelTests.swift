import Combine
import DomainModule
import Testing
@testable import weatherPrediction

/// WeatherSearch 的 AC-1..AC-9 canonical 測試（一條 AC ↔ 一個測試）。
@MainActor
struct WeatherSearchViewModelTests {

    // MARK: - Helpers

    private func makeForecast(cityName: String, periodCount: Int = 3) -> WeatherForecastModel {
        let periods = (0..<periodCount).map { index in
            WeatherPeriodModel(
                startTime: "2026-07-15 \(18 + index):00:00",
                endTime: "2026-07-16 06:00:00",
                weatherDescription: "多雲",
                rainProbability: "20",
                minTemperature: "27",
                maxTemperature: "32",
                comfort: "舒適至悶熱"
            )
        }
        return WeatherForecastModel(cityName: cityName, periods: periods)
    }

    /// 模擬 API 回傳全部 22 縣市。
    private func makeAllForecasts() -> [WeatherForecastModel] {
        CityNameResolver.allCities.map { makeForecast(cityName: $0) }
    }

    private func makeSUT(
        result: Result<[WeatherForecastModel], Error>
    ) -> (WeatherSearchViewModel, MockWeatherRepository) {
        let repository = MockWeatherRepository()
        repository.result = result
        return (WeatherSearchViewModel(repository: repository), repository)
    }

    private func loadedCityNames(_ state: WeatherSearchState) -> [String]? {
        if case .loaded(let forecasts) = state { return forecasts.map(\.cityName) }
        return nil
    }

    // MARK: - AC-1：初始狀態，且未呼叫 API

    @Test
    func test_AC1_onInit_showsInitialState_andDoesNotCallAPI() {
        let (sut, repository) = makeSUT(result: .success(makeAllForecasts()))

        #expect(sut.state == .initial)
        #expect(repository.callCount == 0)
    }

    // MARK: - AC-2：完整縣市名 → 只顯示該縣市

    @Test
    func test_AC2_fullCityName_showsThatCity() async {
        let (sut, _) = makeSUT(result: .success(makeAllForecasts()))

        await sut.search(cityName: "臺北市")

        #expect(loadedCityNames(sut.state) == ["臺北市"])
        if case .loaded(let forecasts) = sut.state {
            #expect(forecasts.first?.periods.count == 3)
        } else {
            Issue.record("expected .loaded state")
        }
    }

    // MARK: - AC-3：loading 狀態序列（先 loading 後 loaded）

    @Test
    func test_AC3_duringSearch_emitsLoadingThenLoaded() async {
        let (sut, _) = makeSUT(result: .success(makeAllForecasts()))
        var states: [WeatherSearchState] = []
        let cancellable = sut.statePublisher.sink { states.append($0) }
        defer { cancellable.cancel() }

        await sut.search(cityName: "臺北市")

        #expect(states.contains(.loading))
        if case .loaded = states.last {
            // ok
        } else {
            Issue.record("expected last state to be .loaded")
        }
    }

    // MARK: - AC-4：空白輸入 → 顯示全部縣市

    @Test
    func test_AC4_blankInput_showsAllCities() async {
        let (sut, _) = makeSUT(result: .success(makeAllForecasts()))

        await sut.search(cityName: "   ")

        #expect(loadedCityNames(sut.state)?.count == CityNameResolver.allCities.count)
    }

    // MARK: - AC-5：無效輸入 → 查無城市，且未呼叫 API

    @Test
    func test_AC5_unmatchedInput_showsError_andDoesNotCallAPI() async {
        let (sut, repository) = makeSUT(result: .success(makeAllForecasts()))

        await sut.search(cityName: "火星市")

        #expect(sut.state == .error(WeatherErrorMessage.text(for: .cityNotFound)))
        #expect(repository.callCount == 0)
    }

    // MARK: - AC-6：資料格式錯誤 → 錯誤

    @Test
    func test_AC6_invalidData_showsError() async {
        let (sut, _) = makeSUT(result: .failure(WeatherError.invalidData))

        await sut.search(cityName: "臺北市")

        #expect(sut.state == .error(WeatherErrorMessage.text(for: .invalidData)))
    }

    // MARK: - AC-7：網路 / 伺服器錯誤 → 錯誤

    @Test
    func test_AC7_requestFailed_showsError() async {
        let (sut, _) = makeSUT(result: .failure(WeatherError.requestFailed))

        await sut.search(cityName: "臺北市")

        #expect(sut.state == .error(WeatherErrorMessage.text(for: .requestFailed)))
    }

    // MARK: - AC-10：授權失敗（HTTP 401）→ 錯誤（與連線失敗分開）

    @Test
    func test_AC10_unauthorized_showsError() async {
        let (sut, _) = makeSUT(result: .failure(WeatherError.unauthorized))

        await sut.search(cityName: "臺北市")

        #expect(sut.state == .error(WeatherErrorMessage.text(for: .unauthorized)))
    }

    // MARK: - AC-8：唯一前綴自動補全（台北 → 臺北市）

    @Test
    func test_AC8_uniquePrefix_autocompletesToOneCity() async {
        let (sut, _) = makeSUT(result: .success(makeAllForecasts()))

        await sut.search(cityName: "台北")

        #expect(loadedCityNames(sut.state) == ["臺北市"])
    }

    // MARK: - AC-9：多重前綴（新竹 → 新竹縣 + 新竹市）

    @Test
    func test_AC9_multiPrefix_showsAllMatchingCities() async {
        let (sut, _) = makeSUT(result: .success(makeAllForecasts()))

        await sut.search(cityName: "新竹")

        let names = loadedCityNames(sut.state)
        #expect(names?.count == 2)
        #expect(names?.contains("新竹縣") == true)
        #expect(names?.contains("新竹市") == true)
    }
}
