import '../models/api_response.dart';
import '../models/friend.dart';
import 'api_client.dart';

/// 好友服务
class FriendService {
  final ApiClient _api = ApiClient();

  /// 获取好友列表
  Future<ApiResponse<List<Friend>>> getFriends({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/friends',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final items = (response.data!['items'] as List? ?? [])
          .map((e) => Friend.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse(
        code: 0,
        message: 'success',
        data: items,
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 添加好友（通过用户ID）
  Future<ApiResponse<Friend>> addFriendById(String friendId) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/friends',
      data: {'friendId': friendId},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: Friend.fromJson(response.data!),
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 添加好友（通过邀请码）
  Future<ApiResponse<Friend>> addFriendByCode(String inviteCode) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/friends',
      data: {'inviteCode': inviteCode},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: Friend.fromJson(response.data!),
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 删除好友
  Future<ApiResponse<void>> removeFriend(String friendId) async {
    return await _api.delete('/friends/$friendId');
  }

  /// 获取好友详情
  Future<ApiResponse<Friend>> getFriendDetail(String friendId) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/friends/$friendId',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: Friend.fromJson(response.data!),
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 搜索好友
  Future<ApiResponse<List<Friend>>> searchFriends(String keyword) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/friends/search',
      queryParameters: {'keyword': keyword},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final items = (response.data!['items'] as List? ?? [])
          .map((e) => Friend.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse(
        code: 0,
        message: 'success',
        data: items,
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }
}
