# 天氣預測 — Flutter

Dart + Flutter，架構為 **Bloc + Clean Architecture**。功能與 iOS 原生端完全一致（見 [`shared-spec/WeatherSearch/spec.md`](../shared-spec/WeatherSearch/spec.md)）。

## 環境需求

- **Flutter SDK 3.44+**（Dart SDK 見 `pubspec.yaml`）
- 主要套件：`flutter_bloc`、`equatable`、`go_router`、`dio`（測試：`bloc_test`、`mocktail`）

## Setup

```bash
cd flutter
flutter pub get

# 設定 API 授權碼（不進版控）
cp config/dart_defines.example.json config/dart_defines.json
#   編輯 config/dart_defines.json，把 CWA_API_KEY 換成你自己的授權碼
```

> 授權碼申請：<https://opendata.cwa.gov.tw/>（會員中心 → API 授權碼）。
> `config/dart_defines.json` 已被 `.gitignore` 排除；透過 `--dart-define-from-file` 於執行期以 `String.fromEnvironment('CWA_API_KEY')` 讀入。

## Build / Test / Run

```bash
# 靜態分析（零 warning）
flutter analyze

# 單元測試（8 個 AC 測試）
flutter test

# 在模擬器 / 裝置執行（需帶入授權碼檔）
flutter run --dart-define-from-file=config/dart_defines.json
```

## 架構（Bloc + Clean，feature-first）

```
flutter/lib/
├── main.dart                         # 讀入 CWA_API_KEY，建立 MaterialApp.router（含 light/dark theme）
├── core/
│   ├── network/                      # ApiClient(abstract) / DioApiClient / ApiConfiguration
│   └── theme/                        # app_colors.dart / app_text_styles.dart（顏色・字體 tokens）
├── router/app_router.dart            # GoRouter（≈ Coordinator）+ composition root（注入 client/config + BlocProvider）
└── features/weather_search/
    ├── domain/                       # entities（WeatherForecast/WeatherPeriod）、WeatherRepository（abstract）、WeatherException
    ├── data/                         # WeatherForecastResponse(fromJson)、Mapper、WeatherEndpoint、WeatherRepositoryImpl（注入 ApiClient）
    └── presentation/
        ├── cubit/                    # WeatherSearchCubit + State（四狀態）+ WeatherErrorMessage + CityNameResolver
        ├── pages/weather_search_page.dart
        └── widgets/                  # 四狀態 Widget（Initial/Loading/Content/Error）+ 卡片清單 + WeatherStyle
```

- **Cubit（≈ ViewModel）**：`WeatherSearchCubit` 只依賴 abstract `WeatherRepository`（constructor 注入），emit immutable 的 `WeatherSearchState`（`status` enum：initial / loading / loaded / error），不 import `material.dart`、不碰 `BuildContext`。
- **四狀態 Widget**：`WeatherSearchPage` 以 `BlocBuilder` 依 `state.status` 切換四個獨立 Widget；讀取中為 inline（非 Dialog）。
- **氣象資料清單**：`ListView` + 每縣市一張**可收合卡片**（`InkWell` 靛藍標題列 + 展開時 `IntrinsicHeight` 三欄，依天氣上底色）。展開狀態存於 `WeatherContentWidget`（容器），每次搜尋一律收合。
- **Design System**：顏色 / 字體集中於 `core/theme/app_colors.dart`、`app_text_styles.dart`（與 iOS 對齊）。
- **網路層**：`core/network` 的 `ApiClient`（abstract）+ 預設 `DioApiClient` + `ApiConfiguration`；端點集中於 `WeatherEndpoint`。`WeatherRepositoryImpl` 依賴抽象 `ApiClient`（可測試 / composition root 覆寫）。
- **導覽 / DI**：`router/app_router.dart` 為 composition root，`GoRoute.builder` 注入 `DioApiClient` + `ApiConfiguration` → `WeatherRepositoryImpl` → `WeatherSearchCubit`（`BlocProvider`）。
- **Clean 分層**：`presentation → domain`、`data → domain`；presentation 不直接依賴 data（透過 abstract repository）。

## 測試

`test/features/weather_search/presentation/weather_search_cubit_test.dart`：以 `mocktail` mock repository + `bloc_test` 驗證 AC-1..AC-9，與 iOS 端互為鏡像。

## 已實作功能

| 功能 | 規格 |
|---|---|
| 天氣搜尋（四狀態顯示 + 錯誤處理） | [spec](../shared-spec/WeatherSearch/spec.md) |

AI 使用揭露見 [根 README](../README.md#-ai-使用揭露)。
