# WeatherSearch 功能規格文件（平台中立 · SSOT）

> **說明：** 本 spec 為**單一事實來源（SSOT）**，同時驅動 iOS 原生（Swift）與 Flutter 兩個專案。
> 只描述**行為、流程、API、驗收條件**，不綁定任何平台語法或型別。
> 掃描排除目錄：`Pods/`, `.build/`, `DerivedData/`, `.dart_tool/`, `build/`, `vendor/`

---

## 更新紀錄

| 日期 | 版本 | 更新內容 | 負責人 |
|------|------|----------|--------|
| 2026-07-15 | v1.0 | 初版建立 | Tim Chen |
| 2026-07-15 | v1.1 | 空白輸入改為查詢全部縣市；輸入自動補全（`新北`→`新北市`、`台北`→`臺北市`）；前綴符合多個縣市時全部取得（`新竹`→新竹縣+新竹市）；氣象資料改為縣市清單顯示 | Tim Chen |

---

## 目錄

- [功能模組](#功能模組)
- [流程](#流程)
- [全局事件監聽](#全局事件監聽)
- [API 端點](#api-端點)
- [驗收條件（Acceptance Criteria）](#驗收條件acceptance-criteria)
- [平台實作對照](#平台實作對照)

---

## 功能模組

### 模組：天氣搜尋（WeatherSearch）

**描述：** 使用者在輸入框輸入城市名稱（locationName），點「確認」後串接中央氣象署（CWA）開放資料「一般天氣預報－今明 36 小時天氣預報」API，於同一畫面的**顯示區塊**呈現四種狀態之一：**初始 / 讀取中 / 氣象資料 / 錯誤**。

- 顯示區塊在任一時刻只呈現一種狀態。
- 讀取中為畫面內 inline 狀態（**非 Dialog** 行為）。
- 氣象資料成功時，顯示**一或多個縣市的清單**，每個縣市含**今明 36 小時、共 3 個時段**的預報，每段含天氣現象、降雨機率、最低溫、最高溫、舒適度。
- 輸入解析（見流程）決定要顯示哪些縣市：空白 → 全部 22 縣市；輸入為某縣市名的前綴 → 所有符合的縣市（可能多個）。

**有效縣市清單（22，hardcode 於 App）：** 宜蘭縣、花蓮縣、臺東縣、澎湖縣、金門縣、連江縣、臺北市、新北市、桃園市、臺中市、臺南市、高雄市、基隆市、新竹縣、新竹市、苗栗縣、彰化縣、南投縣、雲林縣、嘉義縣、嘉義市、屏東縣。

---

## 流程

### WeatherSearch - 流程 1：Happy Path（搜尋成功）

1. 進入畫面：顯示輸入框 + 確認按鈕；顯示區塊為**初始狀態**（提示輸入城市名稱），此時**不呼叫 API**。
2. 使用者於輸入框輸入城市名（可留空、可為部分名稱）→ 點「確認」。
3. **輸入解析**（決定要顯示哪些縣市）：
   - a. 正規化：去除前後空白（trim）；將字元「台」轉為「臺」。
   - b. 若正規化後**為空** → 目標 = **全部 22 縣市**。
   - c. 否則 → 目標 = 有效縣市清單中**以正規化字串為前綴**的所有縣市（完整名視為自身前綴）。
     - 唯一符合：`新北`→`新北市`、`台北`→`臺北市`、`臺南市`→`臺南市`。
     - 多個符合：`新竹`→`新竹縣`+`新竹市`、`嘉義`→`嘉義縣`+`嘉義市`（其他前綴同理處理）。
     - 無符合：目標為空 → 轉流程 2b（查無城市）。
4. 顯示區塊切換為**讀取中**（inline loading，非 Dialog）。
5. 呼叫 API 取得**全部縣市**的預報（帶入授權碼；不帶 locationName），解析所有 `records.location`。
6. 以步驟 3 的目標縣市**過濾**回傳資料 → 顯示區塊切換為**氣象資料**（縣市清單，1 或多筆）：
   - 每個縣市顯示縣市名稱 + 3 個時段，每段：天氣現象（Wx）、降雨機率（PoP，百分比）、最低溫（MinT，°C）、最高溫（MaxT，°C）、舒適度（CI），以及該段起訖時間。

> **實作策略：** App 一律呼叫 API 取全部縣市（一次請求），再依步驟 3 的目標於**用戶端過濾**。此法同時涵蓋「全部 / 唯一 / 多重前綴 / 無效」四種情形，邏輯單一。

### WeatherSearch - 流程 2：Error Path

- **2b — 查無城市**：非空輸入正規化後**不符合任何有效縣市前綴**（例：`火星市`）→ 顯示**錯誤狀態**（提示：查無此城市，請確認名稱）。（可於用戶端判定，不需呼叫 API。）
- **2c — 資料格式不正確**：API 回應無法解析為預期結構，或缺少必要欄位 → 顯示**錯誤狀態**（提示：資料格式不正確），程式不崩潰。
- **2d — 網路 / 伺服器錯誤**：網路中斷、逾時、HTTP 401（授權失敗）、HTTP 5xx → 顯示**錯誤狀態**（對應錯誤字串），程式不崩潰。

### WeatherSearch - 邊界條件

- 讀取中再次點「確認」：以最新一次請求結果為準，不得出現多個狀態交錯顯示。
- 前綴符合多個縣市時，**全部**列於氣象資料清單（不只取第 1 筆）。
- 從錯誤 / 氣象資料狀態，使用者可再次輸入並搜尋，狀態依上述流程重新切換。

---

## 全局事件監聽

> 本功能不監聽登入狀態、網路狀態等全局事件。網路錯誤於發出請求的當下處理（流程 2d）。

| 事件 | 觸發時機 | 處理行為 |
|---|---|---|
| （無） | — | — |

---

## API 端點

### GET `https://opendata.cwa.gov.tw/api/v1/rest/datastore/F-C0032-001`

**用途：** 取得今明 36 小時天氣預報（一般天氣預報）。本 App **不帶 `locationName`**，一律取回全部縣市後於用戶端過濾。

**Request 參數：**
- `Authorization` (String，隱含) — CWA API 授權碼。**存於未進版控（gitignored）的 secrets 檔**，程式於執行期從設定 / 環境讀入；版控中僅保留一份 placeholder 範本檔。**授權碼實際值不得出現在任何進版控的檔案**。
- `locationName`：**不帶**（省略時 API 回傳全部 22 縣市）。縣市過濾由 App 依「輸入解析」結果於用戶端進行。

**Response（取用欄位；其餘欄位忽略）：**
```json
{
  "success": "true",
  "records": {
    "location": [
      {
        "locationName": "臺北市",
        "weatherElement": [
          { "elementName": "Wx",   "time": [ { "startTime": "2026-07-15 18:00:00", "endTime": "2026-07-16 06:00:00", "parameter": { "parameterName": "多雲", "parameterValue": "4" } } ] },
          { "elementName": "PoP",  "time": [ { "parameter": { "parameterName": "20", "parameterUnit": "百分比" } } ] },
          { "elementName": "MinT", "time": [ { "parameter": { "parameterName": "27", "parameterUnit": "C" } } ] },
          { "elementName": "CI",   "time": [ { "parameter": { "parameterName": "舒適至悶熱" } } ] },
          { "elementName": "MaxT", "time": [ { "parameter": { "parameterName": "32", "parameterUnit": "C" } } ] }
        ]
      }
    ]
  }
}
```

- 不帶 `locationName` 時，`records.location` 含全部 22 縣市；每個 `weatherElement` 的 `time` 陣列有 3 筆（3 個時段），彼此以索引對齊。
- 領域模型將同一時段的 Wx / PoP / MinT / MaxT / CI 合併為一筆「時段預報」，共 3 筆；每個縣市一個模型。

**錯誤 Response 處理：**

| 情況 | 對應流程 | 行為 |
|---|---|---|
| 用戶端過濾後無符合縣市（無效輸入） | 2b | 查無城市 → 錯誤狀態 |
| HTTP 200 + 無法解析 / 缺必要欄位 | 2c | 資料格式錯誤 → 錯誤狀態，不崩潰 |
| HTTP 401 | 2d | 授權失敗 → 錯誤狀態 |
| 網路中斷 / 逾時 / HTTP 5xx | 2d | 網路 / 伺服器錯誤 → 錯誤狀態，不崩潰 |

---

## 驗收條件（Acceptance Criteria）

> **這是測試的唯一依據。** 每條 AC = 一個獨立、可測、平台中立的行為。
> `/write-unit-tests` 會為**兩個平台各寫一個對應測試**（互為鏡像），一條 AC ↔ 一個 canonical 測試 / 平台。

| ID | 前提 | 動作 | 預期結果 |
|----|------|------|---------|
| AC-1 | 剛進入畫面、尚未搜尋 | 觀察顯示區塊狀態 | 呈現**初始狀態**，且未呼叫 API |
| AC-2 | 輸入完整有效縣市名（如「臺北市」）、API 回傳全部縣市 | 點確認 | 呈現**氣象資料狀態**：清單含**該 1 個縣市**，含 3 個時段（Wx/PoP/MinT/MaxT/CI） |
| AC-3 | 搜尋 | 點確認 → API 回應前後 | loading 狀態序列：請求中為 true、回應後為 false |
| AC-4 | 輸入為空或 trim 後為純空白、API 回傳全部縣市 | 點確認 | 呈現**氣象資料狀態**：清單含**全部 22 個縣市** |
| AC-5 | 非空輸入正規化後不符任何有效縣市前綴（如「火星市」） | 點確認 | 呈現**錯誤狀態**（查無此城市），且**未呼叫 API** |
| AC-6 | API 回應無法解析 / 缺必要欄位 | 點確認 | 呈現**錯誤狀態**（資料格式不正確），不崩潰 |
| AC-7 | API 請求失敗（網路中斷 / 401 / 5xx） | 點確認 | 呈現**錯誤狀態**（對應錯誤字串），不崩潰 |
| AC-8 | 輸入部分名稱或以「台」書寫、前綴**唯一**符合（如「台北」） | 點確認 | 自動補全為「臺北市」，清單含**該 1 個縣市** |
| AC-9 | 輸入部分名稱、前綴符合**多個**縣市（如「新竹」） | 點確認 | 清單含**所有符合縣市**（新竹縣 + 新竹市） |

### AC × 平台覆蓋矩陣（由 /write-unit-tests 填寫）

| AC | iOS 測試（方法名）| Flutter 測試（描述）|
|----|------------------|--------------------|
| AC-1 | `test_AC1_onInit_showsInitialState_andDoesNotCallAPI` | `AC1 initial state is initial and does not call API` |
| AC-2 | `test_AC2_fullCityName_showsThatCity` | `AC2 full city name shows that city` |
| AC-3 | `test_AC3_duringSearch_emitsLoadingThenLoaded` | `AC3 emits loading before loaded` |
| AC-4 | `test_AC4_blankInput_showsAllCities` | `AC4 blank input shows all cities` |
| AC-5 | `test_AC5_unmatchedInput_showsError_andDoesNotCallAPI` | `AC5 unmatched input shows error and does not call API` |
| AC-6 | `test_AC6_invalidData_showsError` | `AC6 invalid data shows error` |
| AC-7 | `test_AC7_requestFailed_showsError` | `AC7 request failed shows error` |
| AC-8 | `test_AC8_uniquePrefix_autocompletesToOneCity` | `AC8 unique prefix autocompletes to one city` |
| AC-9 | `test_AC9_multiPrefix_showsAllMatchingCities` | `AC9 multi prefix shows all matching cities` |

**測試位置：** iOS `ios-native/weatherPredictionTests/WeatherSearch/WeatherSearchViewModelTests.swift`；Flutter `flutter/test/features/weather_search/presentation/weather_search_cubit_test.dart`。兩平台各 9 個測試，行為互為鏡像。

> 每格恰一個測試，無空格（漏測）、無重複（冗餘）。

---

## 平台實作對照

> 只有兩平台實作方式必然不同時才填；行為必須一致。

| 主題 | iOS 原生 | Flutter |
|---|---|---|
| API 授權碼儲存（gitignored） | 未追蹤的 `.xcconfig`（值注入 Info.plist）於執行期讀入；版控留 `.example` 範本 | 未追蹤的 `--dart-define` / `.env`（build 時注入）；版控留 `.example` 範本 |
| 四狀態顯示 | 顯示區塊以四種 UIView 子視圖切換（初始 / 讀取中 / 氣象 / 錯誤），依 ViewModel state 顯示對應一種 | **實作四個獨立 Widget** 表現四狀態（初始 / 讀取中 / 氣象 / 錯誤），依 Bloc state 切換顯示對應一種 |
| 讀取中呈現 | inline 子視圖（**非 Dialog / 非 HUD 彈窗**） | inline Widget（**非 Dialog**） |
| 氣象資料（縣市清單） | 以 **`UICollectionView` + Diffable Data Source**：**每個縣市一個 section**（header = 縣市名），section 內 3 個時段 cell | 以 `ListView` 排列縣市卡片，每個縣市內含縣市名 + 3 個時段 Widget |
| 輸入解析（正規化 + 前綴補全） | 純函式 `CityNameResolver`（app target），內含 22 縣市清單；`resolve(input) -> [String]` 目標縣市名 | 純函式 `CityNameResolver`（presentation），鏡像同一份 22 清單與邏輯 |
| 資料取得策略 | Repository `fetchAllForecasts() -> [WeatherForecastModel]`（取全部，不帶 locationName）；ViewModel 依目標過濾 | Repository `fetchAllForecasts() -> List<WeatherForecast>`；Cubit 依目標過濾 |

---

## ✅ 完成確認清單

### 流程
- [x] Happy Path 完整
- [x] Error Path（輸入無效、查無城市、資料格式錯誤、網路/授權錯誤）已記錄
- [x] 邊界條件已記錄

### API
- [x] 端點列出；Request 參數完整（含隱含 auth header）；錯誤 Response 處理已說明

### 驗收條件
- [x] 每個流程步驟與錯誤路徑都有對應 AC
- [x] 每條 AC 是單一、可測、平台中立的行為；AC 之間無重疊
- [x] AC ID 唯一且連續（AC-1..AC-8）

### 平台中立性
- [x] spec 主體無 Swift / Dart 專有語法或型別名
- [x] 兩平台無行為差異（僅實作方式差異記於平台實作對照）

---

*此文件由人工審閱後確認，不以 AI 工具署名。*
