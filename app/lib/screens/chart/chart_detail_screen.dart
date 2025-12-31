import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/chart_provider.dart';

class ChartDetailScreen extends StatelessWidget {
  const ChartDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('星盘详情'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Consumer<ChartProvider>(
          builder: (context, chartProvider, _) {
            final chart = chartProvider.chart;
            final interpretation = chartProvider.interpretation;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 解读内容
                  if (interpretation != null) ...[
                    _buildSection(
                      '太阳星座解读',
                      interpretation.sunMoonRising.sun.description,
                    ),
                    _buildSection(
                      '月亮星座解读',
                      interpretation.sunMoonRising.moon.description,
                    ),
                    _buildSection(
                      '上升星座解读',
                      interpretation.sunMoonRising.rising.description,
                    ),
                  ],

                  // 相位列表
                  if (chart != null && chart.aspects.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacingL),
                    const Text(
                      '主要相位',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.fontSizeXL,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    ...chart.aspects.map((aspect) => _buildAspectItem(aspect)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.primaryLight,
              fontSize: AppTheme.fontSizeL,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.fontSizeM,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAspectItem(dynamic aspect) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            aspect.planet1,
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          const SizedBox(width: 8),
          Text(
            aspect.symbol,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: AppTheme.fontSizeL,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            aspect.planet2,
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          const Spacer(),
          Text(
            '${aspect.orb.toStringAsFixed(1)}°',
            style: const TextStyle(color: AppTheme.textHint),
          ),
        ],
      ),
    );
  }
}
