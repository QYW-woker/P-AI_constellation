import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              final user = authProvider.user;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // 用户信息卡片
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      child: Column(
                        children: [
                          // 头像
                          Container(
                            width: 80,
                            height: 80,
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
                                    size: 40,
                                  ),
                          ),
                          const SizedBox(height: 16),

                          // 昵称
                          Text(
                            user?.nickname ?? '未设置昵称',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),

                          // VIP状态
                          if (user?.isVipActive ?? false)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'VIP 剩余${user!.vipDaysRemaining}天',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: AppTheme.fontSizeS,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else
                            TextButton(
                              onPressed: () => context.push('/membership'),
                              child: const Text('开通VIP'),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingL),

                    // 功能列表
                    _buildMenuItem(
                      context,
                      icon: Icons.card_giftcard,
                      title: '邀请好友',
                      subtitle: '邀请好友赚VIP天数',
                      onTap: () => context.push('/invite'),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.star,
                      title: '会员中心',
                      subtitle: '解锁更多功能',
                      onTap: () => context.push('/membership'),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.receipt_long,
                      title: '订单记录',
                      onTap: () => context.push('/orders'),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings,
                      title: '设置',
                      onTap: () => context.push('/settings'),
                    ),

                    const SizedBox(height: AppTheme.spacingL),

                    // 退出登录
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppTheme.cardColor,
                              title: const Text('确认退出'),
                              content: const Text('确定要退出登录吗？'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    '退出',
                                    style: TextStyle(color: AppTheme.errorColor),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true && context.mounted) {
                            await authProvider.logout();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          }
                        },
                        child: const Text(
                          '退出登录',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(
          title,
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textHint,
                  fontSize: AppTheme.fontSizeS,
                ),
              )
            : null,
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.textHint,
        ),
        onTap: onTap,
      ),
    );
  }
}
