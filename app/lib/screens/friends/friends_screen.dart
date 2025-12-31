import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/friend_provider.dart';
import '../../models/friend.dart';
import '../../widgets/common/loading_overlay.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final friendProvider = context.read<FriendProvider>();
    await friendProvider.fetchFriends(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 标题栏
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '好友',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_add),
                      color: AppTheme.primaryColor,
                      onPressed: () => context.push('/friends/add'),
                    ),
                  ],
                ),
              ),

              // 好友列表
              Expanded(
                child: Consumer<FriendProvider>(
                  builder: (context, friendProvider, _) {
                    if (friendProvider.isLoading && !friendProvider.hasFriends) {
                      return const LoadingPlaceholder(message: '加载中...');
                    }

                    if (!friendProvider.hasFriends) {
                      return EmptyPlaceholder(
                        icon: Icons.people_outline,
                        message: '还没有好友\n快去添加吧',
                        actionText: '添加好友',
                        onAction: () => context.push('/friends/add'),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppTheme.primaryColor,
                      backgroundColor: AppTheme.surfaceColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                        ),
                        itemCount: friendProvider.friends.length,
                        itemBuilder: (context, index) {
                          return _buildFriendItem(
                            friendProvider.friends[index],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendItem(Friend friend) {
    final sunSignCN = friend.sunSign != null
        ? AppConstants.zodiacChineseNames[friend.sunSign] ?? friend.sunSign
        : '';

    return GestureDetector(
      onTap: () => context.push('/compatibility/${friend.friendId}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Row(
          children: [
            // 头像
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
              ),
              child: friend.avatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        friend.avatarUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 12),

            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.nickname,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.fontSizeL,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (sunSignCN.isNotEmpty)
                    Text(
                      sunSignCN,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: AppTheme.fontSizeS,
                      ),
                    ),
                ],
              ),
            ),

            // 配对分数
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _getScoreColor(friend.compatibilityScore).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${friend.compatibilityScore}分',
                style: TextStyle(
                  color: _getScoreColor(friend.compatibilityScore),
                  fontSize: AppTheme.fontSizeS,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.successColor;
    if (score >= 60) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}
