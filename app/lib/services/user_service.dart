import '../models/api_response.dart';
import '../models/user.dart';
import '../models/payment.dart';
import 'api_client.dart';
import 'storage_service.dart';

/// 用户服务
class UserService {
  final ApiClient _api = ApiClient();
  final StorageService _storage = StorageService();

  /// 获取用户资料
  Future<ApiResponse<User>> getProfile() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/user/profile',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final user = User.fromJson(response.data!);
      await _storage.saveUser(user);
      return ApiResponse(
        code: 0,
        message: 'success',
        data: user,
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 更新用户资料
  Future<ApiResponse<User>> updateProfile({
    String? nickname,
    String? avatarUrl,
    String? gender,
  }) async {
    final data = <String, dynamic>{};
    if (nickname != null) data['nickname'] = nickname;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    if (gender != null) data['gender'] = gender;

    final response = await _api.put<Map<String, dynamic>>(
      '/user/profile',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final user = User.fromJson(response.data!);
      await _storage.saveUser(user);
      return ApiResponse(
        code: 0,
        message: 'success',
        data: user,
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 更新出生信息
  Future<ApiResponse<User>> updateBirthInfo({
    required DateTime birthDate,
    required String birthTime,
    required String birthCity,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    final data = {
      'birthDate': birthDate.toIso8601String().split('T')[0],
      'birthTime': birthTime,
      'birthCity': birthCity,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
    };

    final response = await _api.put<Map<String, dynamic>>(
      '/user/profile',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final user = User.fromJson(response.data!);
      await _storage.saveUser(user);
      return ApiResponse(
        code: 0,
        message: 'success',
        data: user,
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 获取会员信息
  Future<ApiResponse<Membership>> getMembership() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/user/membership',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: Membership.fromJson(response.data!),
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 获取邀请信息
  Future<ApiResponse<InviteInfo>> getInviteInfo() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/user/invite/info',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: InviteInfo.fromJson(response.data!),
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 应用邀请码
  Future<ApiResponse<void>> applyInviteCode(String inviteCode) async {
    return await _api.post('/user/invite/apply', data: {
      'inviteCode': inviteCode,
    });
  }

  /// 上传头像
  Future<ApiResponse<String>> uploadAvatar(String filePath) async {
    final response = await _api.upload<Map<String, dynamic>>(
      '/user/avatar',
      filePath,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: response.data!['avatarUrl'] as String,
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 获取缓存的用户信息
  User? getCachedUser() {
    return _storage.getUser();
  }

  /// 注销账号
  Future<ApiResponse<void>> deleteAccount() async {
    return await _api.delete('/user/account');
  }
}
