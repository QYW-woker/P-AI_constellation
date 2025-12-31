/// 应用配置
class AppConfig {
  // API配置
  static const String apiBaseUrl = 'http://localhost:3000/api/v1';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // 缓存配置
  static const Duration cacheExpiry = Duration(hours: 1);
  static const int maxCacheSize = 100;

  // 分页配置
  static const int defaultPageSize = 20;

  // 动画配置
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // 验证码配置
  static const int smsCodeLength = 6;
  static const int smsResendInterval = 60;

  // 限制配置
  static const int maxFriends = 50;
  static const int nicknameMinLength = 2;
  static const int nicknameMaxLength = 12;
}

/// 环境配置
enum Environment { dev, test, staging, prod }

class EnvConfig {
  final Environment env;
  final String apiBaseUrl;
  final bool enableLog;

  const EnvConfig({
    required this.env,
    required this.apiBaseUrl,
    this.enableLog = false,
  });

  static const EnvConfig dev = EnvConfig(
    env: Environment.dev,
    apiBaseUrl: 'http://localhost:3000/api/v1',
    enableLog: true,
  );

  static const EnvConfig test = EnvConfig(
    env: Environment.test,
    apiBaseUrl: 'https://test-api.yourapp.com/api/v1',
    enableLog: true,
  );

  static const EnvConfig staging = EnvConfig(
    env: Environment.staging,
    apiBaseUrl: 'https://staging-api.yourapp.com/api/v1',
    enableLog: true,
  );

  static const EnvConfig prod = EnvConfig(
    env: Environment.prod,
    apiBaseUrl: 'https://api.yourapp.com/api/v1',
    enableLog: false,
  );

  static EnvConfig current = dev;
}
