# AI星座应用 - 前端

基于 Flutter 3.x 的跨平台星座应用。

## 技术栈

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Network**: Dio
- **Router**: go_router
- **Storage**: SharedPreferences + FlutterSecureStorage

## 项目结构

```
app/
├── lib/
│   ├── config/               # 配置文件
│   │   ├── app_config.dart   # 应用配置
│   │   ├── constants.dart    # 常量定义
│   │   ├── theme.dart        # 主题配置
│   │   └── router.dart       # 路由配置
│   ├── models/               # 数据模型
│   │   ├── user.dart         # 用户/星盘模型
│   │   ├── horoscope.dart    # 运势模型
│   │   ├── friend.dart       # 好友模型
│   │   ├── compatibility.dart # 配对模型
│   │   ├── payment.dart      # 支付模型
│   │   ├── city.dart         # 城市模型
│   │   └── api_response.dart # API响应模型
│   ├── services/             # API服务
│   │   ├── api_client.dart   # HTTP客户端
│   │   ├── storage_service.dart
│   │   ├── auth_service.dart
│   │   ├── user_service.dart
│   │   ├── chart_service.dart
│   │   ├── horoscope_service.dart
│   │   ├── friend_service.dart
│   │   ├── compatibility_service.dart
│   │   ├── payment_service.dart
│   │   ├── city_service.dart
│   │   └── share_service.dart
│   ├── providers/            # 状态管理
│   │   ├── auth_provider.dart
│   │   ├── chart_provider.dart
│   │   ├── horoscope_provider.dart
│   │   └── friend_provider.dart
│   ├── screens/              # 页面
│   │   ├── auth/             # 认证页面
│   │   ├── home/             # 首页
│   │   ├── chart/            # 星盘页面
│   │   ├── horoscope/        # 运势页面
│   │   ├── friends/          # 好友页面
│   │   ├── compatibility/    # 配对页面
│   │   ├── profile/          # 个人中心
│   │   └── payment/          # 支付页面
│   ├── widgets/              # 组件
│   │   ├── common/           # 通用组件
│   │   ├── chart/            # 星盘组件
│   │   └── share/            # 分享组件
│   └── main.dart             # 入口文件
├── assets/                   # 资源文件
│   ├── images/
│   └── fonts/
└── pubspec.yaml
```

## 功能模块

### 已实现

- [x] 登录注册（手机号验证码）
- [x] 出生信息填写
- [x] 星盘生成与展示
- [x] 今日运势
- [x] 好友列表
- [x] 配对分析
- [x] 个人中心
- [x] 会员系统
- [x] 邀请好友

### 待实现

- [ ] 微信登录
- [ ] Apple登录
- [ ] 支付功能
- [ ] 分享功能
- [ ] 推送通知
- [ ] 深度星盘报告

## 快速开始

### 环境要求

- Flutter >= 3.0.0
- Dart >= 3.0.0
- Android Studio / VS Code
- Xcode (for iOS)

### 安装依赖

```bash
cd app
flutter pub get
```

### 运行项目

```bash
# 开发模式
flutter run

# 指定设备
flutter run -d <device_id>

# 构建APK
flutter build apk

# 构建iOS
flutter build ios
```

### 配置API地址

修改 `lib/config/app_config.dart`:

```dart
static const String apiBaseUrl = 'http://your-api-url/api/v1';
```

## 主题配置

应用使用深色主题，主要色调：

- 主色: `#6366F1` (紫蓝色)
- 背景渐变: `#1E1B4B` → `#0F0A1A`
- 卡片背景: `#2D2A5A`
- 元素色:
  - 火象: `#FF6B6B`
  - 土象: `#51CF66`
  - 风象: `#74C0FC`
  - 水象: `#CC5DE8`

## 状态管理

使用 Provider 进行状态管理：

```dart
// 获取状态
final authProvider = context.read<AuthProvider>();

// 监听状态
Consumer<AuthProvider>(
  builder: (context, auth, _) {
    return Text(auth.user?.nickname ?? '');
  },
)
```

## 路由导航

使用 go_router 进行路由管理：

```dart
// 跳转页面
context.go('/chart');
context.push('/chart/detail');

// 返回
context.pop();
```

## 网络请求

```dart
// 获取API客户端
final api = ApiClient();

// GET请求
final response = await api.get<User>('/user/profile');

// POST请求
final response = await api.post('/auth/login', data: {...});
```

## 安全存储

敏感数据使用 FlutterSecureStorage 加密存储：

```dart
final storage = StorageService();

// 保存Token
await storage.saveTokens(accessToken, refreshToken);

// 获取Token
final token = await storage.getAccessToken();
```

## License

MIT
