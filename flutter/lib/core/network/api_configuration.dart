/// API 連線設定：base URL 與授權碼。由 composition root（router）注入，
/// 讓 base URL / 金鑰不散落在資料層。與 iOS 端 `APIConfiguration` 對齊。
class ApiConfiguration {
  const ApiConfiguration({required this.baseUrl, required this.authorizationKey});

  final String baseUrl;
  final String authorizationKey;
}
