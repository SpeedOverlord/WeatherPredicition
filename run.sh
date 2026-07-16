#!/usr/bin/env bash
#
# 天氣預測 一鍵啟動腳本
# 1) 詢問 CWA 授權碼 → 2) 建立兩平台 secrets 檔 → 3) 開啟 spec HTML
# 4) 開兩個模擬器：一台跑 iOS 原生、一台跑 Flutter
#
# 用法： ./run.sh
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 兩台模擬器（分別跑 native / flutter）；可自行改成其他機型名稱。
IOS_SIM="iPhone 16"
FLUTTER_SIM="iPhone 16 Pro"
BUNDLE_ID="com.example.weatherPrediction"

info()  { printf "\033[1;34m▸ %s\033[0m\n" "$*"; }
ok()    { printf "\033[1;32m✓ %s\033[0m\n" "$*"; }
warn()  { printf "\033[1;33m! %s\033[0m\n" "$*"; }

# 取得指定名稱模擬器的 UDID（精確比對，避免 "Pro" 誤中 "Pro Max"）。
udid_for() {
  xcrun simctl list devices available \
    | sed -n "s/^ *$1 (\([0-9A-Fa-f-]\{36\}\)).*/\1/p" | head -1
}

# ── 0. 前置檢查 ──────────────────────────────────────────────
command -v xcodebuild >/dev/null || { echo "找不到 xcodebuild，請先安裝 Xcode"; exit 1; }
command -v flutter    >/dev/null || { echo "找不到 flutter，請先安裝 Flutter SDK"; exit 1; }

# ── 1. 詢問授權碼 ────────────────────────────────────────────
echo "════════════════════════════════════════════"
echo "  天氣預測 — 一鍵啟動（iOS 原生 + Flutter）"
echo "════════════════════════════════════════════"
echo "申請授權碼：https://opendata.cwa.gov.tw/ （會員中心 → API 授權碼）"
read -r -p "請輸入 CWA API 授權碼： " API_KEY
if [ -z "${API_KEY// }" ]; then
  echo "未輸入授權碼，結束。"
  exit 1
fi

# ── 2. 建立兩平台 secrets 檔（不進版控）─────────────────────
info "建立 secrets 檔…"
cat > "$ROOT/ios-native/weatherPrediction/Config/Secrets.xcconfig" <<EOF
// 本檔已被 .gitignore 排除，不進版控。由 run.sh 自動產生。
CWA_API_KEY = $API_KEY
EOF

mkdir -p "$ROOT/flutter/config"
cat > "$ROOT/flutter/config/dart_defines.json" <<EOF
{
  "CWA_API_KEY": "$API_KEY"
}
EOF
ok "已寫入 Secrets.xcconfig 與 dart_defines.json"

# ── 3. 開啟 spec HTML ────────────────────────────────────────
info "開啟功能規格 HTML…"
open "$ROOT/shared-spec/WeatherSearch/spec.html" || warn "無法開啟 spec.html"

# ── 4. 啟動兩台模擬器 ───────────────────────────────────────
info "啟動模擬器：$IOS_SIM（native）、$FLUTTER_SIM（flutter）…"
open -a Simulator
IOS_UDID="$(udid_for "$IOS_SIM")"
FLUTTER_UDID="$(udid_for "$FLUTTER_SIM")"
[ -n "$IOS_UDID" ]     || { echo "找不到模擬器：$IOS_SIM"; exit 1; }
[ -n "$FLUTTER_UDID" ] || { echo "找不到模擬器：$FLUTTER_SIM"; exit 1; }
xcrun simctl boot "$IOS_UDID"     2>/dev/null || true
xcrun simctl boot "$FLUTTER_UDID" 2>/dev/null || true

# ── 5. Build + 跑 iOS 原生（在 $IOS_SIM）─────────────────────
info "編譯 iOS 原生（首次較久）…"
cd "$ROOT/ios-native"
xcodebuild build -quiet \
  -workspace weatherPrediction.xcworkspace \
  -scheme weatherPrediction \
  -configuration Debug \
  -destination "platform=iOS Simulator,name=$IOS_SIM" \
  -derivedDataPath build/DD
APP="$(find build/DD/Build/Products/Debug-iphonesimulator -maxdepth 1 -name '*.app' | head -1)"
[ -n "$APP" ] || { echo "找不到編譯後的 .app"; exit 1; }
xcrun simctl install "$IOS_UDID" "$APP"
xcrun simctl launch "$IOS_UDID" "$BUNDLE_ID" >/dev/null
ok "iOS 原生已在「$IOS_SIM」啟動"

# ── 6. Build + 跑 Flutter（在 $FLUTTER_SIM，前景 attach）────
info "取得 Flutter 依賴…"
cd "$ROOT/flutter"
flutter pub get >/dev/null

echo ""
ok "iOS 原生執行中（$IOS_SIM）。接著在「$FLUTTER_SIM」啟動 Flutter…"
echo "  （Flutter 會 attach 在此終端機：r 熱重載、R 熱重啟、q 結束）"
echo ""
exec flutter run -d "$FLUTTER_UDID" --dart-define-from-file=config/dart_defines.json
