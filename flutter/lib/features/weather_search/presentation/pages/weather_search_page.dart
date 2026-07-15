import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/weather_search_cubit.dart';
import '../cubit/weather_search_state.dart';
import '../widgets/weather_content_widget.dart';
import '../widgets/weather_error_widget.dart';
import '../widgets/weather_initial_widget.dart';
import '../widgets/weather_loading_widget.dart';

/// 天氣搜尋主畫面：上方輸入框 + 確認按鈕，下方顯示區塊依狀態切換四個 Widget。
class WeatherSearchPage extends StatefulWidget {
  const WeatherSearchPage({super.key});

  @override
  State<WeatherSearchPage> createState() => _WeatherSearchPageState();
}

class _WeatherSearchPageState extends State<WeatherSearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onConfirm() {
    FocusScope.of(context).unfocus();
    context.read<WeatherSearchCubit>().search(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('天氣預測')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _onConfirm(),
                      decoration: const InputDecoration(
                        hintText: '請輸入城市名稱',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _onConfirm,
                    child: const Text('確認'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<WeatherSearchCubit, WeatherSearchState>(
                  builder: (context, state) => _buildDisplay(state),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisplay(WeatherSearchState state) {
    switch (state.status) {
      case WeatherSearchStatus.initial:
        return const WeatherInitialWidget();
      case WeatherSearchStatus.loading:
        return const WeatherLoadingWidget();
      case WeatherSearchStatus.loaded:
        return WeatherContentWidget(forecasts: state.forecasts);
      case WeatherSearchStatus.error:
        return WeatherErrorWidget(message: state.errorMessage ?? '發生錯誤');
    }
  }
}
