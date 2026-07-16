# 天氣預測 — iOS 原生

Swift + UIKit，架構為 **MVVM-C + Clean Architecture**。功能與 Flutter 端完全一致（見 [`shared-spec/WeatherSearch/spec.md`](../shared-spec/WeatherSearch/spec.md)）。

## 環境需求

- **Xcode 16+**（deployment target iOS 15.0）
- 無第三方套件依賴：只用 UIKit + URLSession + 本地 SPM modules（不需 CocoaPods）。

## Setup

```bash
cd ios-native

# 1) 設定 API 授權碼（不進版控）
cp weatherPrediction/Config/Secrets.example.xcconfig weatherPrediction/Config/Secrets.xcconfig
#   編輯 Secrets.xcconfig，把 CWA_API_KEY 換成你自己的授權碼

# 2) 開啟 workspace（不是 .xcodeproj）— workspace 已引用本地 SPM 套件 Packages
open weatherPrediction.xcworkspace
```

> 授權碼申請：<https://opendata.cwa.gov.tw/>（會員中心 → API 授權碼）。
> `Secrets.xcconfig` 已被 `.gitignore` 排除；其值於 build 時注入 `Info.plist` 的 `CWA_API_KEY`，由 `Environment.swift` 於執行期讀入。

## Build / Test / Run

```bash
# 單元測試（編譯 App + 執行 8 個 AC 測試）
xcodebuild test -workspace weatherPrediction.xcworkspace -scheme weatherPrediction \
  -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16'

# 在模擬器執行：開 weatherPrediction.xcworkspace，選 scheme「weatherPrediction」+ iPhone 16 → ⌘R
```

> `weatherPrediction.xcworkspace` 同時引用 App 的 `weatherPrediction.xcodeproj` 與本地 SPM 套件 `Packages`；
> App target 透過 package product 依賴 `DomainModule` / `DataModule`，由 workspace 解析。

## 架構（MVVM-C + Clean）

```
ios-native/
├── weatherPrediction.xcworkspace     # 開這個（引用 .xcodeproj + Packages SPM）
├── weatherPrediction.xcodeproj       # App 專案
├── Packages/                         # 本地 SPM modules（Clean 分層）
│   └── Sources/
│       ├── DomainModule/             # WeatherForecastModel / WeatherRepositoryProtocol / WeatherError
│       └── DataModule/
│           ├── Networking/           # APIClient(protocol) / URLSessionAPIClient / APIConfiguration
│           └── WeatherSearch/        # ResponseModel / Mapper / WeatherEndpoint / WeatherRepositoryImpl
└── weatherPrediction/
    ├── App/                          # AppDelegate / SceneDelegate / AppCoordinator（composition root）
    ├── Config/                       # Environment、App.xcconfig、Secrets*.xcconfig
    ├── DesignSystem/                 # AppColor / AppFont（顏色・字體 tokens）
    └── Features/WeatherSearch/
        ├── ViewModel/                # WeatherSearchViewModel(@MainActor) + Protocol + State + ErrorMessage + CityNameResolver
        └── View/                     # ViewController + 四狀態 View + WeatherCityCell（卡片）+ WeatherPeriodColumnView + WeatherStyle
```

- **Presentation**：`WeatherSearchViewModel`（`@MainActor`，四狀態以 `@Published` 發佈）；`WeatherSearchViewController` 只認識 `any WeatherSearchViewModelProtocol`，透過 Combine 綁定狀態切換四種子視圖。
- **氣象資料清單**：`UICollectionView` + `UICollectionViewDiffableDataSource`；每縣市一張**可收合卡片**（`WeatherCityCell`：靛藍標題列 + 展開時三欄 `WeatherPeriodColumnView`，依天氣上底色）。展開狀態存於 `WeatherContentView`，每次搜尋一律收合。
- **Design System**：顏色 / 字體集中於 `DesignSystem/AppColor`、`AppFont`，各畫面統一取用。
- **網路層**：`DataModule/Networking` 的 `APIClient`（protocol）+ 預設 `URLSessionAPIClient` + `APIConfiguration`（baseURL/授權碼）；端點集中於 `WeatherEndpoint`。`WeatherRepositoryImpl` 注入 `APIClient`（可測試 / App 可覆寫）。
- **導覽 / DI**：單一畫面、無跨 feature 導覽，`AppCoordinator` 作為唯一 composition root 建立 `APIConfiguration` → `WeatherRepositoryImpl` 並注入 ViewModel（依 CLAUDE.md「避免過度設計」，不預先抽 `Coordinating` protocol）。
- **Clean 分層**：`DomainModule`（純模型 + 介面）←`DataModule`（Networking + API 解析 + Repository 實作）；依賴方向單向。
- **Swift 6**：strict concurrency，無 `@unchecked Sendable`；單次非同步用 `async/await`，持續狀態用 Combine。

## 測試

`weatherPredictionTests/WeatherSearch/WeatherSearchViewModelTests.swift`：以 mock repository 驗證 AC-1..AC-9（Swift Testing），與 Flutter 端互為鏡像。

## 已實作功能

| 功能 | 規格 |
|---|---|
| 天氣搜尋（四狀態顯示 + 錯誤處理） | [spec](../shared-spec/WeatherSearch/spec.md) |

AI 使用揭露見 [根 README](../README.md#-ai-使用揭露)。
