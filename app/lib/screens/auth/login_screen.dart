import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _inviteCodeController = TextEditingController();

  bool _agreedToTerms = false;
  bool _showInviteCode = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _inviteCodeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  /// 发送验证码
  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 11) {
      _showError('请输入正确的手机号');
      return;
    }

    if (!_agreedToTerms) {
      _showError('请先同意用户协议和隐私政策');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendSmsCode(phone);

    if (success) {
      _startCountdown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('验证码已发送')),
        );
      }
    } else {
      if (mounted) {
        _showError(authProvider.error ?? '发送失败');
      }
    }
  }

  /// 开始倒计时
  void _startCountdown() {
    setState(() {
      _countdown = AppConfig.smsResendInterval;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          timer.cancel();
        }
      });
    });
  }

  /// 登录
  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();

    if (phone.length != 11) {
      _showError('请输入正确的手机号');
      return;
    }

    if (code.length != AppConfig.smsCodeLength) {
      _showError('请输入${AppConfig.smsCodeLength}位验证码');
      return;
    }

    if (!_agreedToTerms) {
      _showError('请先同意用户协议和隐私政策');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.phoneLogin(
      phone: phone,
      code: code,
      inviteCode: _showInviteCode ? _inviteCodeController.text.trim() : null,
    );

    if (success && mounted) {
      // 检查是否需要填写出生信息
      if (!authProvider.hasBirthInfo) {
        context.go('/birth-info');
      } else {
        context.go('/');
      }
    } else if (mounted) {
      _showError(authProvider.error ?? '登录失败');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return LoadingOverlay(
            isLoading: authProvider.isLoading,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.backgroundGradient,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),

                      // Logo和标题
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                size: 40,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '欢迎来到AI星座',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '探索属于你的星象奥秘',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 60),

                      // 手机号输入
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: '请输入手机号',
                          prefixIcon: Icon(Icons.phone_android, color: AppTheme.textHint),
                          counterText: '',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 验证码输入
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _codeController,
                              keyboardType: TextInputType.number,
                              maxLength: AppConfig.smsCodeLength,
                              style: const TextStyle(color: AppTheme.textPrimary),
                              decoration: const InputDecoration(
                                hintText: '请输入验证码',
                                prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textHint),
                                counterText: '',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 100,
                            child: TextButton(
                              onPressed: _countdown > 0 ? null : _sendCode,
                              child: Text(
                                _countdown > 0 ? '${_countdown}s' : '获取验证码',
                                style: TextStyle(
                                  color: _countdown > 0
                                      ? AppTheme.textHint
                                      : AppTheme.primaryLight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 邀请码（可选）
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showInviteCode = !_showInviteCode;
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showInviteCode
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppTheme.textHint,
                              size: 20,
                            ),
                            const Text(
                              '有邀请码？',
                              style: TextStyle(color: AppTheme.textHint),
                            ),
                          ],
                        ),
                      ),

                      if (_showInviteCode) ...[
                        TextField(
                          controller: _inviteCodeController,
                          maxLength: 6,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                            hintText: '请输入邀请码（选填）',
                            prefixIcon: Icon(Icons.card_giftcard, color: AppTheme.textHint),
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      const SizedBox(height: 24),

                      // 登录按钮
                      GradientButton(
                        text: '登录/注册',
                        onPressed: _login,
                      ),

                      const SizedBox(height: 24),

                      // 用户协议
                      Row(
                        children: [
                          Checkbox(
                            value: _agreedToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreedToTerms = value ?? false;
                              });
                            },
                            activeColor: AppTheme.primaryColor,
                            side: const BorderSide(color: AppTheme.textHint),
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: AppTheme.fontSizeS,
                                  color: AppTheme.textHint,
                                ),
                                children: [
                                  const TextSpan(text: '我已阅读并同意'),
                                  TextSpan(
                                    text: '《用户协议》',
                                    style: const TextStyle(
                                      color: AppTheme.primaryLight,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // TODO: 打开用户协议
                                      },
                                  ),
                                  const TextSpan(text: '和'),
                                  TextSpan(
                                    text: '《隐私政策》',
                                    style: const TextStyle(
                                      color: AppTheme.primaryLight,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // TODO: 打开隐私政策
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // 第三方登录
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              '其他登录方式',
                              style: TextStyle(
                                color: AppTheme.textHint,
                                fontSize: AppTheme.fontSizeS,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialButton(
                                  icon: Icons.wechat,
                                  color: const Color(0xFF07C160),
                                  onTap: () {
                                    // TODO: 微信登录
                                  },
                                ),
                                const SizedBox(width: 24),
                                _buildSocialButton(
                                  icon: Icons.apple,
                                  color: Colors.white,
                                  onTap: () {
                                    // TODO: Apple登录
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.cardColor,
            width: 1,
          ),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}
