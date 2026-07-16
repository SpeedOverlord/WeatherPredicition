import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/network/api_configuration.dart';
import '../core/network/dio_api_client.dart';
import '../features/weather_search/data/repositories/weather_repository_impl.dart';
import '../features/weather_search/presentation/cubit/weather_search_cubit.dart';
import '../features/weather_search/presentation/pages/weather_search_page.dart';

/// 集中管理所有 path 常數（≈ iOS `AppRoute`）。
class AppRoute {
  const AppRoute._();

  static const String weatherSearch = '/';
}

/// CWA 開放資料 API 的 base URL（端點路徑由 WeatherEndpoint 集中管理）。
const String _apiBaseUrl = 'https://opendata.cwa.gov.tw/api';

/// 中央路由入口（≈ iOS `AppCoordinator`）。`GoRoute.builder` 為 composition root：
/// 注入 `ApiConfiguration` + `DioApiClient` → `WeatherRepositoryImpl` → `WeatherSearchCubit`。
/// 有特殊需求時可在此改注入自訂 `ApiClient`。
GoRouter createAppRouter({required String apiKey}) {
  return GoRouter(
    routes: [
      GoRoute(
        path: AppRoute.weatherSearch,
        builder: (BuildContext context, GoRouterState state) {
          final repository = WeatherRepositoryImpl(
            client: DioApiClient(),
            configuration: ApiConfiguration(baseUrl: _apiBaseUrl, authorizationKey: apiKey),
          );
          return BlocProvider(
            create: (_) => WeatherSearchCubit(repository),
            child: const WeatherSearchPage(),
          );
        },
      ),
    ],
  );
}
