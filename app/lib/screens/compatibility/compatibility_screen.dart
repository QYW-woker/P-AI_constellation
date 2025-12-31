import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/friend_provider.dart';
import '../../widgets/common/gradient_button.dart';

class CompatibilityScreen extends StatefulWidget {
  final String friendId;

  const CompatibilityScreen({super.key, required this.friendId});

  @override
  State<CompatibilityScreen> createState() => _CompatibilityScreenState();
}

class _CompatibilityScreenState extends State<CompatibilityScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final friendProvider = context.read<FriendProvider>();
    await friendProvider.getCompatibilityOverview(widget.friendId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('配对分析'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Consumer<FriendProvider>(
          builder: (context, friendProvider, _) {
            final friend = friendProvider.getFriendById(widget.friendId);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                children: [
                  // 配对分数
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingXL),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${friend?.compatibilityScore ?? '--'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          friend?.compatibilityLevel ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: AppTheme.fontSizeL,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  // 查看详细报告按钮
                  GradientButton(
                    text: '查看详细报告',
                    onPressed: () {
                      context.push('/compatibility/${widget.friendId}/report');
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
