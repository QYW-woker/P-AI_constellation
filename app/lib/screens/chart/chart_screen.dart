import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/chart_provider.dart';
import '../../widgets/chart/natal_chart_widget.dart';
import '../../widgets/common/loading_overlay.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final chartProvider = context.read<ChartProvider>();
    await chartProvider.fetchChart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Consumer<ChartProvider>(
            builder: (context, chartProvider, _) {
              if (chartProvider.isLoading) {
                return const LoadingPlaceholder(message: '加载星盘中...');
              }

              final chart = chartProvider.chart;
              if (chart == null) {
                return const EmptyPlaceholder(
                  icon: Icons.auto_awesome,
                  message: '暂无星盘数据',
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '我的星盘',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          color: AppTheme.textSecondary,
                          onPressed: () => context.push('/chart/detail'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingL),

                    // 星盘图
                    NatalChartWidget(chart: chart),
                    const SizedBox(height: AppTheme.spacingL),

                    // 三大星座
                    _buildMainSigns(chart.sunSign, chart.moonSign, chart.risingSign),
                    const SizedBox(height: AppTheme.spacingL),

                    // 元素分布
                    _buildElementDistribution(chart.elementCounts),
                    const SizedBox(height: AppTheme.spacingL),

                    // 行星位置
                    _buildPlanetList(chart.planets),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainSigns(String sun, String moon, String rising) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSignItem(
              '太阳星座',
              sun,
              Icons.wb_sunny,
              AppTheme.fireElement,
            ),
          ),
          Expanded(
            child: _buildSignItem(
              '月亮星座',
              moon,
              Icons.nightlight_round,
              AppTheme.waterElement,
            ),
          ),
          Expanded(
            child: _buildSignItem(
              '上升星座',
              rising,
              Icons.arrow_upward,
              AppTheme.airElement,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignItem(String label, String sign, IconData icon, Color color) {
    final signCN = AppConstants.zodiacChineseNames[sign] ?? sign;

    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textHint,
            fontSize: AppTheme.fontSizeS,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          signCN,
          style: TextStyle(
            color: color,
            fontSize: AppTheme.fontSizeL,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildElementDistribution(Map<String, int> elements) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '元素分布',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: AppTheme.fontSizeL,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              _buildElementBar('火', elements['fire'] ?? 0, AppTheme.fireElement),
              _buildElementBar('土', elements['earth'] ?? 0, AppTheme.earthElement),
              _buildElementBar('风', elements['air'] ?? 0, AppTheme.airElement),
              _buildElementBar('水', elements['water'] ?? 0, AppTheme.waterElement),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElementBar(String label, int count, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              height: 60,
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: (count / 10 * 60).clamp(8.0, 60.0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$label $count',
              style: TextStyle(
                color: color,
                fontSize: AppTheme.fontSizeS,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanetList(List<dynamic> planets) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '行星位置',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: AppTheme.fontSizeL,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          ...planets.map((planet) => _buildPlanetItem(planet)).toList(),
        ],
      ),
    );
  }

  Widget _buildPlanetItem(dynamic planet) {
    final planetCN = AppConstants.planetChineseNames[planet.planet] ?? planet.planet;
    final signCN = AppConstants.zodiacChineseNames[planet.sign] ?? planet.sign;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              planetCN,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: AppTheme.fontSizeM,
              ),
            ),
          ),
          Expanded(
            child: Text(
              signCN,
              style: const TextStyle(
                color: AppTheme.primaryLight,
                fontSize: AppTheme.fontSizeM,
              ),
            ),
          ),
          Text(
            planet.formattedDegree,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.fontSizeS,
            ),
          ),
          if (planet.isRetrograde)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '逆行',
                style: TextStyle(
                  color: AppTheme.warningColor,
                  fontSize: AppTheme.fontSizeXS,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
