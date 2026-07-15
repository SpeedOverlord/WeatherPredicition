import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/weather_search/data/repositories/weather_repository_impl.dart';
import '../features/weather_search/presentation/cubit/weather_search_cubit.dart';
import '../features/weather_search/presentation/pages/weather_search_page.dart';

/// 集中管理所有 path 常數（≈ iOS `AppRoute`）。
class AppRoute {
  const AppRoute._();

  static const String weatherSearch = '/';
}

/// 中央路由入口（≈ iOS `AppCoordinator`）。`GoRoute.builder` 為 composition root：
/// 建立 `WeatherRepositoryImpl` → `WeatherSearchCubit`，以 `BlocProvider` 向下注入。
GoRouter createAppRouter({required String apiKey}) {
  return GoRouter(
    routes: [
      GoRoute(
        path: AppRoute.weatherSearch,
        builder: (BuildContext context, GoRouterState state) {
          final repository = WeatherRepositoryImpl(dio: Dio(), apiKey: apiKey);
          return BlocProvider(
            create: (_) => WeatherSearchCubit(repository),
            child: const WeatherSearchPage(),
          );
        },
      ),
    ],
  );
}
