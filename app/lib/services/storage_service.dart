import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/user.dart';

/// 存储服务
class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  StorageService._internal();

  factory StorageService() {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  /// 初始化
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== Token管理 ====================

  /// 保存Token
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(
      key: AppConstants.keyAccessToken,
      value: accessToken,
    );
    await _secureStorage.write(
      key: AppConstants.keyRefreshToken,
      value: refreshToken,
    );
  }

  /// 获取AccessToken
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConstants.keyAccessToken);
  }

  /// 获取RefreshToken
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.keyRefreshToken);
  }

  /// 清除Token
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.keyAccessToken);
    await _secureStorage.delete(key: AppConstants.keyRefreshToken);
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== 用户信息 ====================

  /// 保存用户信息
  Future<void> saveUser(User user) async {
    await _prefs?.setString(
      AppConstants.keyUserInfo,
      jsonEncode(user.toJson()),
    );
  }

  /// 获取用户信息
  User? getUser() {
    final userJson = _prefs?.getString(AppConstants.keyUserInfo);
    if (userJson == null) return null;
    try {
      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  /// 清除用户信息
  Future<void> clearUser() async {
    await _prefs?.remove(AppConstants.keyUserInfo);
  }

  // ==================== 引导页状态 ====================

  /// 设置引导页完成
  Future<void> setOnboardingComplete() async {
    await _prefs?.setBool(AppConstants.keyOnboardingComplete, true);
  }

  /// 检查引导页是否完成
  bool isOnboardingComplete() {
    return _prefs?.getBool(AppConstants.keyOnboardingComplete) ?? false;
  }

  // ==================== 推送Token ====================

  /// 保存推送Token
  Future<void> savePushToken(String token) async {
    await _prefs?.setString(AppConstants.keyPushToken, token);
  }

  /// 获取推送Token
  String? getPushToken() {
    return _prefs?.getString(AppConstants.keyPushToken);
  }

  // ==================== 通用存储 ====================

  /// 保存字符串
  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  /// 获取字符串
  String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// 保存整数
  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  /// 获取整数
  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  /// 保存布尔值
  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  /// 获取布尔值
  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  /// 保存JSON对象
  Future<void> setJson(String key, Map<String, dynamic> value) async {
    await _prefs?.setString(key, jsonEncode(value));
  }

  /// 获取JSON对象
  Map<String, dynamic>? getJson(String key) {
    final value = _prefs?.getString(key);
    if (value == null) return null;
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// 删除键
  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  /// 清除所有数据
  Future<void> clearAll() async {
    await _prefs?.clear();
    await _secureStorage.deleteAll();
  }

  /// 登出时清理数据
  Future<void> logout() async {
    await clearTokens();
    await clearUser();
  }
}
