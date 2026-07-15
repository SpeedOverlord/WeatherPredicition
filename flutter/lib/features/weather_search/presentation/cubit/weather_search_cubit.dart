import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/weather_exception.dart';
import '../../domain/repositories/weather_repository.dart';
import 'city_name_resolver.dart';
import 'weather_error_message.dart';
import 'weather_search_state.dart';

class WeatherSearchCubit extends Cubit<WeatherSearchState> {
  WeatherSearchCubit(this._repository) : super(const WeatherSearchState.initial());

  final WeatherRepository _repository;

  Future<void> search(String cityName) async {
    final targets = CityNameResolver.resolve(cityName);
    if (targets.isEmpty) {
      // 非空輸入無法對應任何有效縣市前綴 → 查無城市（不呼叫 API）。
      _emitError(WeatherErrorType.cityNotFound);
      return;
    }

    emit(const WeatherSearchState(status: WeatherSearchStatus.loading));
    try {
      final all = await _repository.fetchAllForecasts();
      final targetSet = targets.toSet();
      final filtered = all.where((f) => targetSet.contains(f.cityName)).toList();
      if (filtered.isEmpty) {
        _emitError(WeatherErrorType.cityNotFound);
      } else {
        emit(WeatherSearchState(status: WeatherSearchStatus.loaded, forecasts: filtered));
      }
    } on WeatherException catch (e) {
      _emitError(e.type);
    } catch (_) {
      _emitError(WeatherErrorType.requestFailed);
    }
  }

  void _emitError(WeatherErrorType type) {
    emit(
      WeatherSearchState(
        status: WeatherSearchStatus.error,
        errorMessage: WeatherErrorMessage.text(type),
      ),
    );
  }
}
