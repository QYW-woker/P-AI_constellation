import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/storage_service.dart';

/// 认证状态
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
}

/// 认证状态管理
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final StorageService _storage = StorageService();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _error;
  bool _isLoading = false;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get hasUser => _user != null;
  bool get hasBirthInfo => _user?.hasBirthInfo ?? false;
  bool get hasNatalChart => _user?.hasNatalChart ?? false;
  bool get isVip => _user?.isVipActive ?? false;

  /// 初始化认证状态
  Future<void> init() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        // 尝试获取用户信息
        final response = await _userService.getProfile();
        if (response.isSuccess && response.data != null) {
          _user = response.data;
          _status = AuthStatus.authenticated;
        } else {
          // Token可能已过期
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      debugPrint('Auth init error: $e');
    }

    notifyListeners();
  }

  /// 发送验证码
  Future<bool> sendSmsCode(String phone) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.sendSmsCode(phone);
      _setLoading(false);

      if (!response.isSuccess) {
        _setError(response.message);
        return false;
      }
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('发送验证码失败');
      return false;
    }
  }

  /// 手机号登录
  Future<bool> phoneLogin({
    required String phone,
    required String code,
    String? inviteCode,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.phoneLogin(
        phone: phone,
        code: code,
        inviteCode: inviteCode,
      );

      if (!response.isSuccess) {
        _setLoading(false);
        _setError(response.message);
        return false;
      }

      // 获取用户信息
      final userResponse = await _userService.getProfile();
      if (userResponse.isSuccess && userResponse.data != null) {
        _user = userResponse.data;
        _status = AuthStatus.authenticated;
        _setLoading(false);
        notifyListeners();
        return true;
      }

      _setLoading(false);
      _setError('获取用户信息失败');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('登录失败');
      return false;
    }
  }

  /// 微信登录
  Future<bool> wechatLogin({
    required String code,
    String? inviteCode,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.wechatLogin(
        code: code,
        inviteCode: inviteCode,
      );

      if (!response.isSuccess) {
        _setLoading(false);
        _setError(response.message);
        return false;
      }

      // 获取用户信息
      final userResponse = await _userService.getProfile();
      if (userResponse.isSuccess && userResponse.data != null) {
        _user = userResponse.data;
        _status = AuthStatus.authenticated;
        _setLoading(false);
        notifyListeners();
        return true;
      }

      _setLoading(false);
      _setError('获取用户信息失败');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('登录失败');
      return false;
    }
  }

  /// 登出
  Future<void> logout() async {
    _setLoading(true);

    await _authService.logout();

    _user = null;
    _status = AuthStatus.unauthenticated;
    _setLoading(false);
    notifyListeners();
  }

  /// 刷新用户信息
  Future<void> refreshUser() async {
    try {
      final response = await _userService.getProfile();
      if (response.isSuccess && response.data != null) {
        _user = response.data;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Refresh user error: $e');
    }
  }

  /// 更新用户信息
  Future<bool> updateProfile({
    String? nickname,
    String? avatarUrl,
    String? gender,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _userService.updateProfile(
        nickname: nickname,
        avatarUrl: avatarUrl,
        gender: gender,
      );

      _setLoading(false);

      if (response.isSuccess && response.data != null) {
        _user = response.data;
        notifyListeners();
        return true;
      }

      _setError(response.message);
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('更新失败');
      return false;
    }
  }

  /// 更新出生信息
  Future<bool> updateBirthInfo({
    required DateTime birthDate,
    required String birthTime,
    required String birthCity,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _userService.updateBirthInfo(
        birthDate: birthDate,
        birthTime: birthTime,
        birthCity: birthCity,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );

      _setLoading(false);

      if (response.isSuccess && response.data != null) {
        _user = response.data;
        notifyListeners();
        return true;
      }

      _setError(response.message);
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('更新失败');
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
