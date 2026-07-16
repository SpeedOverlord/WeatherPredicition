import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_prediction/features/weather_search/domain/entities/weather_exception.dart';
import 'package:weather_prediction/features/weather_search/domain/entities/weather_forecast.dart';
import 'package:weather_prediction/features/weather_search/domain/repositories/weather_repository.dart';
import 'package:weather_prediction/features/weather_search/presentation/cubit/city_name_resolver.dart';
import 'package:weather_prediction/features/weather_search/presentation/cubit/weather_error_message.dart';
import 'package:weather_prediction/features/weather_search/presentation/cubit/weather_search_cubit.dart';
import 'package:weather_prediction/features/weather_search/presentation/cubit/weather_search_state.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

WeatherForecast _makeForecast(String cityName, {int periodCount = 3}) {
  return WeatherForecast(
    cityName: cityName,
    periods: List<WeatherPeriod>.generate(
      periodCount,
      (i) => WeatherPeriod(
        startTime: '2026-07-15 ${18 + i}:00:00',
        endTime: '2026-07-16 06:00:00',
        weatherDescription: '多雲',
        rainProbability: '20',
        minTemperature: '27',
        maxTemperature: '32',
        comfort: '舒適至悶熱',
      ),
    ),
  );
}

/// 模擬 API 回傳全部 22 縣市。
List<WeatherForecast> _makeAllForecasts() =>
    CityNameResolver.allCities.map(_makeForecast).toList();

List<String> _names(WeatherSearchState s) => s.forecasts.map((f) => f.cityName).toList();

void main() {
  late MockWeatherRepository repository;

  setUp(() {
    repository = MockWeatherRepository();
  });

  // AC-1：初始狀態，且未呼叫 API
  test('AC1 initial state is initial and does not call API', () {
    final cubit = WeatherSearchCubit(repository);
    expect(cubit.state, const WeatherSearchState.initial());
    verifyNever(() => repository.fetchAllForecasts());
    cubit.close();
  });

  // AC-2：完整縣市名 → 只顯示該縣市
  blocTest<WeatherSearchCubit, WeatherSearchState>(
    'AC2 full city name shows that city',
    build: () {
      when(() => repository.fetchAllForecasts()).thenAnswer((_) async => _makeAllForecasts());
      return WeatherSearchCubit(repository);
    },
    act: (cubit) => cubit.search('臺北市'),
    expect: () => [
      const WeatherSearchState(status: WeatherSearchStatus.loading),
      isA<WeatherSearchState>()
          .having((s) => s.status, 'status', WeatherSearchStatus.loaded)
          .having(_names, 'cityNames', ['臺北市'])
          .having((s) => s.forecasts.first.periods.length, 'periods', 3),
    ],
  );

  // AC-3：loading 狀態序列（先 loading 後 loaded）
  blocTest<WeatherSearchCubit, WeatherSearchState>(
    'AC3 emits loading before loaded',
    build: () {
      when(() => repository.fetchAllForecasts()).thenAnswer((_) async => _makeAllForecasts());
      return WeatherSearchCubit(repository);
    },
    act: (cubit) => cubit.search('臺北市'),
    expect: () => [
      const WeatherSearchState(status: WeatherSearchStatus.loading),
      isA<WeatherSearchState>().having((s) => s.status, 'status', WeatherSearchStatus.loaded),
    ],
  );

  // AC-4：空白輸入 → 顯示全部縣市
  blocTest<WeatherSearchCubit, WeatherSearchState>(
    'AC4 blank input shows all cities',
    build: () {
      when(() => repository.fetchAllForecasts()).thenAnswer((_) async => _makeAllForecasts());
      return WeatherSearchCubit(repository);
    },
    act: (cubit) => cubit.search('   '),
    expect: () => [
      const WeatherSearchState(status: WeatherSearchStatus.loading),
      isA<WeatherSearchState>()
          .having((s) => s.status, 'status', WeatherSearchStatus.loaded)
          .having((s) => s.forecasts.length, 'count', CityNameResolver.allCities.length),
    ],
  );

  // AC-5：無效輸入 → 查無城市，且未呼叫 API
  blocTest<WeatherSearchCubit, WeatherSearchState>(
    'AC5 unmatched input shows error and does not call API',
    build: () {
      when(() => repository.fetchAllForecasts()).thenAnswer((_) async => _makeAllForecasts());
      return WeatherSearchCubit(repository);
    },
    act: (cubit) => cubit.search('火星市'),
    expect: () => [
      WeatherSearchState(
        status: WeatherSearchStatus.error,
        errorMessage: WeatherErrorMessage.text(WeatherErrorType.cityNotFound),
      ),
    ],
    verify: (_) => verifyNever(() => repository.fetchAllForecasts()),
  );

  // AC-6：資料格式錯誤 → 錯誤
  blocTest<WeatherSearchCubit, WeatherSearchState>(
    'AC6 invalid data shows error',
    build: () {
      when(() => repository.fetchAllForecasts())
          .thenThrow(const WeatherException(WeatherErrorType.invalidData));
      return WeatherSearchCubit(repository);
    },
    act: (cubit) => cubit.search('臺北市'),
    expect: () => [
      const WeatherSearchState(status: WeatherSearchStatus.loading),
      WeatherSearchState(
        status: WeatherSearchStatus.error,
        errorMessage: WeatherErrorMessage.text(WeatherErrorType.invalidData),
      ),
    ],
  );

  // AC-7：網路 / 伺服器錯誤 → 錯誤
  blocTest<WeatherSearchCubit, WeatherSearchState>(
    'AC7 request failed shows error',
    build: () {
      when(() => repository.fetchAllForecasts())
          .thenThrow(const WeatherException(WeatherErrorType.requestFailed));
      return WeatherSearchCubit(repository);
    },
    act: (cubit) => cubit.search('臺北市'),
    expect: () => [
      const WeatherSearchState(status: WeatherSearchStatus.loading),
      WeatherSearchState(
        status: WeatherSearchStatus.error,
        errorMessage: WeatherErrorMessage.text(WeatherErrorType.requestFailed),
      ),
    ],
  );

  // AC-10：授權失敗（HTTP 401）→ 錯誤（與連線失敗分開）
  blocTest<WeatherSearchCubit, WeatherSearchState>(
    'AC10 unauthorized shows error',
    build: () {
      when(() => repository.fetchAllForecasts())
          .thenThrow(const WeatherException(WeatherErrorType.unauthorized));
      return WeatherSearchCubit(repository);
    },
    act: (cubit) => cubit.search('臺北市'),
    expect: () => [
      const WeatherSearchState(status: WeatherSearchStatus.loading),
      WeatherSearchState(
        status: WeatherSearchStatus.error,
        errorMessage: WeatherErrorMessage.text(WeatherErrorType.unauthorized),
      ),
    ],
  );

  // AC-8：唯一前綴自動補全（台北 → 臺北市）
  blocTest<WeatherSearchCubit, WeatherSearchState>(
    'AC8 unique prefix autocompletes to one city',
    build: () {
      when(() => repository.fetchAllForecasts()).thenAnswer((_) async => _makeAllForecasts());
      return WeatherSearchCubit(repository);
    },
    act: (cubit) => cubit.search('台北'),
    expect: () => [
      const WeatherSearchState(status: WeatherSearchStatus.loading),
      isA<WeatherSearchState>()
          .having((s) => s.status, 'status', WeatherSearchStatus.loaded)
          .having(_names, 'cityNames', ['臺北市']),
    ],
  );

  // AC-9：多重前綴（新竹 → 新竹縣 + 新竹市）
  blocTest<WeatherSearchCubit, WeatherSearchState>(
    'AC9 multi prefix shows all matching cities',
    build: () {
      when(() => repository.fetchAllForecasts()).thenAnswer((_) async => _makeAllForecasts());
      return WeatherSearchCubit(repository);
    },
    act: (cubit) => cubit.search('新竹'),
    expect: () => [
      const WeatherSearchState(status: WeatherSearchStatus.loading),
      isA<WeatherSearchState>()
          .having((s) => s.status, 'status', WeatherSearchStatus.loaded)
          .having((s) => s.forecasts.length, 'count', 2)
          .having(_names, 'cityNames', containsAll(['新竹縣', '新竹市'])),
    ],
  );
}
