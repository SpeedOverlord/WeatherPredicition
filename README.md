# 天氣預測（weatherPrediction）

輸入城市名稱，串接**中央氣象署（CWA）開放資料「一般天氣預報－今明 36 小時天氣預報」**，顯示該城市的天氣。

本 repo 以 **Monorepo** 同時維護兩個**功能完全一致**的專案，差別只在實作平台；功能一致性由單一份平台中立規格（`shared-spec/`）保證。

## 專案

| 專案 | 技術 | 目錄 |
|---|---|---|
| iOS 原生 | Swift + UIKit（MVVM-C + Clean Architecture） | [`ios-native/`](ios-native/README.md) |
| Flutter | Dart + Flutter（Bloc + Clean Architecture） | [`flutter/`](flutter/README.md) |

## 目錄結構

```
weatherPrediction/
├── shared-spec/              # ✅ 單一事實來源（SSOT）— 平台中立規格
│   └── WeatherSearch/spec.md
├── ios-native/              # Swift + UIKit（MVVM-C + Clean）
└── flutter/                 # Dart + Flutter（Bloc + Clean）
```

## 功能一致性如何保證

- `shared-spec/WeatherSearch/spec.md` 是唯一事實來源（SSOT），同時驅動兩專案的實作與測試。
- 以 spec 的「驗收條件（AC-1..AC-8）」為準，兩平台各寫**鏡像測試**（一條 AC ↔ 一個測試 / 平台，共 8 × 2）。
- 任何行為差異都視為 bug。

## 已實作功能

| 功能 | 規格 | iOS | Flutter |
|---|---|---|---|
| 天氣搜尋（輸入城市 → 四狀態顯示：初始 / 讀取中 / 氣象資料 / 錯誤） | [spec](shared-spec/WeatherSearch/spec.md) | ✅ | ✅ |

四種顯示狀態：

1. **初始**：尚未搜尋時的提示畫面。
2. **讀取中**：畫面內 inline loading（非 Dialog）。
3. **氣象資料**：**一或多個縣市的可收合卡片清單**，點縣市標題列展開，展開時今明 36 小時共 3 個時段以三欄並排（天氣現象、降雨機率、最低/最高溫、舒適度），卡片依天氣上底色。每次搜尋一律收合。
4. **錯誤**：查無城市 / 資料格式錯誤 / 連線失敗 / **授權失敗（HTTP 401，單獨）**，各顯示對應訊息。

> UI 一致性：兩平台共用一套 design system（顏色 / 字體 token）與可注入的網路層（`APIClient` / `ApiClient`）；細節見各平台 README。

輸入解析（兩平台一致）：

- **留空** → 顯示**全部 22 縣市**。
- **自動補全**：`新北`→`新北市`、`台北`→`臺北市`（去空白 + 「台」轉「臺」+ 前綴補全）。
- **前綴符合多個** → 全部取得：`新竹`→`新竹縣`+`新竹市`、`嘉義`→`嘉義縣`+`嘉義市`。
- **無符合**（如 `火星市`）→ 查無城市錯誤。

## 🚀 一鍵啟動（macOS）

```bash
./run.sh
```

腳本會：**詢問 CWA 授權碼 → 自動建立兩平台 secrets 檔 → 開啟功能規格 HTML → 開兩台模擬器（`iPhone 16` 跑 iOS 原生、`iPhone 16 Pro` 跑 Flutter）並 build/執行**。需先安裝 Xcode 16+ 與 Flutter SDK。（腳本本身不含金鑰，執行時才詢問。）

## 🔑 API 授權碼設定（手動，非必要）

> 若不用 `run.sh`，可手動設定。CWA `F-C0032-001` 需要授權碼，**授權碼不進版控**，各平台用一份 gitignored 檔案提供：

- iOS：`ios-native/weatherPrediction/Config/Secrets.xcconfig`（範本 `Secrets.example.xcconfig`）
- Flutter：`flutter/config/dart_defines.json`（範本 `dart_defines.example.json`）

申請授權碼：<https://opendata.cwa.gov.tw/>（會員中心 → API 授權碼）。設定細節見各平台 README。

## 快速 build / test

```bash
# ── iOS（需 Xcode 16+）──
cd ios-native
xcodebuild test -workspace weatherPrediction.xcworkspace -scheme weatherPrediction \
  -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16'

# ── Flutter（需 Flutter SDK）──
cd flutter
flutter analyze
flutter test
```

## 開發流程

本專案遵循 SDD → TDD → 實作 → Code Review → Build/測試 → README 的順序（詳見 `CLAUDE.md`）。

## 🤖 AI 使用揭露

本專案在開發過程中使用 **Anthropic 的 Claude（透過 Claude Code）** 協助開發。使用方式：

- **規格（SDD）**：依作業需求與 CWA API 實際回應，整理出平台中立的 `shared-spec/WeatherSearch/spec.md`（含驗收條件 AC-1..AC-8）。
- **測試先行（TDD）**：依 AC 清單，為兩平台各產生單元測試並通過測試。
- **實作**：依 spec 完成 iOS（MVVM-C + Clean）與 Flutter（Bloc + Clean）兩邊實作至測試全綠。
- **Code Review 與文件**：協助自我審查（架構合規、避免過度設計、跨平台一致性）與撰寫本說明文件。

所有產出均經人工審閱後確認；API 授權碼由開發者自行提供且不進版控。
