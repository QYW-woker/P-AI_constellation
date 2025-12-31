import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/friend_provider.dart';
import '../../widgets/common/gradient_button.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _addFriend() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入邀请码')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final friendProvider = context.read<FriendProvider>();
    final success = await friendProvider.addFriendByCode(code);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('添加成功')),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendProvider.error ?? '添加失败')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加好友'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '输入好友邀请码',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.fontSizeL,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextField(
                controller: _codeController,
                maxLength: 6,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: '请输入6位邀请码',
                  counterText: '',
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              GradientButton(
                text: '添加好友',
                onPressed: _addFriend,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
