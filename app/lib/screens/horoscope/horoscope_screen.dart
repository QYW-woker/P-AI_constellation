import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/horoscope_provider.dart';

class HoroscopeScreen extends StatelessWidget {
  const HoroscopeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今日运势'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Consumer<HoroscopeProvider>(
          builder: (context, horoscopeProvider, _) {
            final horoscope = horoscopeProvider.todayHoroscope;

            if (horoscope == null) {
              return const Center(
                child: Text(
                  '暂无运势数据',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 综合运势
                  _buildScoreCard(horoscope),
                  const SizedBox(height: AppTheme.spacingL),

                  // 宜忌
                  _buildDosDonts(horoscope),
                  const SizedBox(height: AppTheme.spacingL),

                  // 详细描述
                  _buildSummary(horoscope.summary),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScoreCard(dynamic horoscope) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        children: [
          Text(
            '${horoscope.overallScore}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            '综合运势',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildDosDonts(dynamic horoscope) {
    return Row(
      children: [
        Expanded(
          child: _buildListCard(
            '宜',
            horoscope.doList,
            AppTheme.successColor,
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: _buildListCard(
            '忌',
            horoscope.dontList,
            AppTheme.errorColor,
          ),
        ),
      ],
    );
  }

  Widget _buildListCard(String title, List<String> items, Color color) {
    return Container(
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
            style: TextStyle(
              color: color,
              fontSize: AppTheme.fontSizeL,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '• $item',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: AppTheme.fontSizeM,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSummary(String summary) {
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
            '今日提示',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: AppTheme.fontSizeL,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary,
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
}
