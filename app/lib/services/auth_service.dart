import '../models/api_response.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'storage_service.dart';

/// 认证服务
class AuthService {
  final ApiClient _api = ApiClient();
  final StorageService _storage = StorageService();

  /// 发送验证码
  Future<ApiResponse<void>> sendSmsCode(String phone) async {
    return await _api.post('/auth/sms/send', data: {'phone': phone});
  }

  /// 手机号登录
  Future<ApiResponse<LoginResponse>> phoneLogin({
    required String phone,
    required String code,
    String? inviteCode,
  }) async {
    final data = <String, dynamic>{
      'phone': phone,
      'code': code,
    };
    if (inviteCode != null && inviteCode.isNotEmpty) {
      data['inviteCode'] = inviteCode;
    }

    final response = await _api.post<Map<String, dynamic>>(
      '/auth/login/phone',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final loginData = LoginResponse.fromJson(response.data!);
      await _storage.saveTokens(loginData.accessToken, loginData.refreshToken);
      return ApiResponse(
        code: 0,
        message: 'success',
        data: loginData,
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 微信登录
  Future<ApiResponse<LoginResponse>> wechatLogin({
    required String code,
    String? inviteCode,
  }) async {
    final data = <String, dynamic>{
      'code': code,
    };
    if (inviteCode != null && inviteCode.isNotEmpty) {
      data['inviteCode'] = inviteCode;
    }

    final response = await _api.post<Map<String, dynamic>>(
      '/auth/login/wechat',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final loginData = LoginResponse.fromJson(response.data!);
      await _storage.saveTokens(loginData.accessToken, loginData.refreshToken);
      return ApiResponse(
        code: 0,
        message: 'success',
        data: loginData,
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 刷新Token
  Future<ApiResponse<LoginResponse>> refreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      return ApiResponse(
        code: 11001,
        message: '请重新登录',
        data: null,
      );
    }

    final response = await _api.post<Map<String, dynamic>>(
      '/auth/token/refresh',
      data: {'refreshToken': refreshToken},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final loginData = LoginResponse.fromJson(response.data!);
      await _storage.saveTokens(loginData.accessToken, loginData.refreshToken);
      return ApiResponse(
        code: 0,
        message: 'success',
        data: loginData,
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 登出
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (e) {
      // 忽略网络错误
    }
    await _storage.logout();
  }

  /// 检查登录状态
  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }

  /// 获取当前Token
  Future<String?> getAccessToken() async {
    return await _storage.getAccessToken();
  }
}
