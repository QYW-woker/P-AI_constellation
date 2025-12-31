import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/gradient_button.dart';

class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('邀请好友'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final user = authProvider.user;
            final inviteCode = user?.inviteCode ?? '';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                children: [
                  // 邀请说明
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.card_giftcard,
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '邀请好友 赚VIP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppTheme.fontSizeXXL,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '每邀请1位好友，双方各获3天VIP',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: AppTheme.fontSizeM,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  // 邀请码
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '我的邀请码',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: AppTheme.fontSizeM,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              inviteCode,
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              color: AppTheme.primaryColor,
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: inviteCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('邀请码已复制')),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  // 分享按钮
                  GradientButton(
                    text: '分享给好友',
                    onPressed: () {
                      // TODO: 分享功能
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
