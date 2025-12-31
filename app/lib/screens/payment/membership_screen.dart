import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../widgets/common/gradient_button.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  String _selectedPlan = 'yearly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('会员中心'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  children: [
                    // VIP权益
                    _buildBenefitsCard(),
                    const SizedBox(height: AppTheme.spacingL),

                    // 套餐选择
                    ...AppConstants.membershipPlans.entries.map(
                      (entry) => _buildPlanCard(entry.key, entry.value),
                    ),
                  ],
                ),
              ),
            ),

            // 购买按钮
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: GradientButton(
                  text: '立即开通',
                  onPressed: () {
                    // TODO: 支付流程
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        children: [
          const Text(
            'VIP会员权益',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppTheme.fontSizeXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBenefitItem(Icons.auto_awesome, '深度星盘'),
              _buildBenefitItem(Icons.favorite, '配对报告'),
              _buildBenefitItem(Icons.calendar_today, '每日运势'),
              _buildBenefitItem(Icons.block, '无广告'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppTheme.fontSizeS,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(String key, Map<String, dynamic> plan) {
    final isSelected = _selectedPlan == key;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = key),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: isSelected
              ? Border.all(color: AppTheme.primaryColor, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: key,
              groupValue: _selectedPlan,
              onChanged: (val) => setState(() => _selectedPlan = val!),
              activeColor: AppTheme.primaryColor,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan['name'] as String,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.fontSizeL,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${plan['days']}天',
                    style: const TextStyle(
                      color: AppTheme.textHint,
                      fontSize: AppTheme.fontSizeS,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '¥${plan['price']}',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: AppTheme.fontSizeXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (plan['originalPrice'] != null)
                  Text(
                    '¥${plan['originalPrice']}',
                    style: const TextStyle(
                      color: AppTheme.textHint,
                      fontSize: AppTheme.fontSizeS,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
