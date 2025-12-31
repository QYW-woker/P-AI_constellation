import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            _buildSettingItem('推送通知', true),
            _buildSettingItem('每日运势提醒', true),
            _buildSettingItem('好友添加通知', true),
            const Divider(color: AppTheme.cardColor),
            _buildMenuItem('关于我们'),
            _buildMenuItem('用户协议'),
            _buildMenuItem('隐私政策'),
            _buildMenuItem('清除缓存'),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, bool value) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        value: value,
        onChanged: (val) {},
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildMenuItem(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.textHint,
        ),
        onTap: () {},
      ),
    );
  }
}
