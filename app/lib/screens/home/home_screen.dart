import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/horoscope_provider.dart';
import '../../providers/chart_provider.dart';
import '../../widgets/common/loading_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final horoscopeProvider = context.read<HoroscopeProvider>();
    final chartProvider = context.read<ChartProvider>();

    await Future.wait([
      horoscopeProvider.fetchTodayHoroscope(),
      chartProvider.fetchChart(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.surfaceColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部问候
                  _buildHeader(),
                  const SizedBox(height: AppTheme.spacingL),

                  // 今日运势卡片
                  _buildTodayHoroscopeCard(),
                  const SizedBox(height: AppTheme.spacingM),

                  // 功能入口
                  _buildQuickActions(),
                  const SizedBox(height: AppTheme.spacingL),

                  // 星盘概览
                  _buildChartOverview(),
                  const SizedBox(height: AppTheme.spacingL),

                  // 运势详情入口
                  _buildHoroscopeDetails(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        final greeting = _getGreeting();

        return Row(
          children: [
            // 头像
            GestureDetector(
              onTap: () => context.go('/profile'),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                ),
                child: user?.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          user!.avatarUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // 问候语
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.fontSizeM,
                    ),
                  ),
                  Text(
                    user?.nickname ?? '星座爱好者',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.fontSizeXL,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // VIP标识
            if (user?.isVipActive ?? false)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'VIP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTodayHoroscopeCard() {
    return Consumer2<HoroscopeProvider, ChartProvider>(
      builder: (context, horoscopeProvider, chartProvider, _) {
        final horoscope = horoscopeProvider.todayHoroscope;
        final sunSign = chartProvider.sunSign;
        final sunSignCN = sunSign != null
            ? AppConstants.zodiacChineseNames[sunSign] ?? sunSign
            : '';

        if (horoscopeProvider.isLoading) {
          return _buildLoadingCard();
        }

        return GestureDetector(
          onTap: () => context.push('/horoscope'),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题行
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '今日运势',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                        if (sunSignCN.isNotEmpty)
                          Text(
                            sunSignCN,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: AppTheme.fontSizeM,
                            ),
                          ),
                      ],
                    ),
                    // 分数
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${horoscope?.overallScore ?? '--'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingM),

                // 运势摘要
                Text(
                  horoscope?.summary ?? '加载中...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppTheme.fontSizeM,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppTheme.spacingM),

                // 幸运元素
                if (horoscope != null)
                  Wrap(
                    spacing: AppTheme.spacingS,
                    runSpacing: AppTheme.spacingS,
                    children: [
                      _buildLuckyTag(
                        Icons.color_lens,
                        horoscope.luckyColor,
                      ),
                      _buildLuckyTag(
                        Icons.numbers,
                        '${horoscope.luckyNumber}',
                      ),
                      _buildLuckyTag(
                        Icons.explore,
                        horoscope.luckyDirection,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLuckyTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppTheme.fontSizeS,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.auto_awesome,
            title: '我的星盘',
            color: const Color(0xFF8B5CF6),
            onTap: () => context.go('/chart'),
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: _buildActionCard(
            icon: Icons.favorite,
            title: '配对测试',
            color: const Color(0xFFEC4899),
            onTap: () => context.go('/friends'),
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: _buildActionCard(
            icon: Icons.card_giftcard,
            title: '邀请好友',
            color: const Color(0xFF10B981),
            onTap: () => context.push('/invite'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: AppTheme.fontSizeS,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartOverview() {
    return Consumer<ChartProvider>(
      builder: (context, chartProvider, _) {
        final chart = chartProvider.chart;

        if (chart == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '三大星座',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.fontSizeL,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/chart/detail'),
                    child: const Text(
                      '查看详情',
                      style: TextStyle(
                        color: AppTheme.primaryLight,
                        fontSize: AppTheme.fontSizeS,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: _buildSignItem(
                      '太阳',
                      chart.sunSign,
                      AppTheme.fireElement,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppTheme.textHint.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _buildSignItem(
                      '月亮',
                      chart.moonSign,
                      AppTheme.waterElement,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppTheme.textHint.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _buildSignItem(
                      '上升',
                      chart.risingSign,
                      AppTheme.airElement,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSignItem(String label, String sign, Color color) {
    final signCN = AppConstants.zodiacChineseNames[sign] ?? sign;

    return Column(
      children: [
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

  Widget _buildHoroscopeDetails() {
    return Consumer<HoroscopeProvider>(
      builder: (context, horoscopeProvider, _) {
        final horoscope = horoscopeProvider.todayHoroscope;

        if (horoscope == null) {
          return const SizedBox.shrink();
        }

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
                '运势分析',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.fontSizeL,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              _buildScoreRow('综合', horoscope.scores.overall),
              _buildScoreRow('爱情', horoscope.scores.love),
              _buildScoreRow('事业', horoscope.scores.career),
              _buildScoreRow('财运', horoscope.scores.wealth),
              _buildScoreRow('健康', horoscope.scores.health),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreRow(String label, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.fontSizeM,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100,
                backgroundColor: AppTheme.surfaceColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getScoreColor(score),
                ),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              '$score',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _getScoreColor(score),
                fontSize: AppTheme.fontSizeM,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.successColor;
    if (score >= 60) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了';
    if (hour < 12) return '早上好';
    if (hour < 14) return '中午好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }
}
