import '../models/api_response.dart';
import 'api_client.dart';

/// 分享服务
class ShareService {
  final ApiClient _api = ApiClient();

  /// 生成运势分享卡片
  Future<ApiResponse<ShareCardResponse>> generateHoroscopeCard({
    DateTime? date,
    String style = 'default',
    String size = 'story',
  }) async {
    final data = <String, dynamic>{
      'style': style,
      'size': size,
    };
    if (date != null) {
      data['date'] = date.toIso8601String().split('T')[0];
    }

    final response = await _api.post<Map<String, dynamic>>(
      '/share/horoscope',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: ShareCardResponse.fromJson(response.data!),
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 生成配对分享卡片
  Future<ApiResponse<ShareCardResponse>> generateCompatibilityCard({
    required String friendId,
    String style = 'default',
    String size = 'square',
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/share/compatibility',
      data: {
        'friendId': friendId,
        'style': style,
        'size': size,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: ShareCardResponse.fromJson(response.data!),
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 生成性格卡片
  Future<ApiResponse<ShareCardResponse>> generateProfileCard({
    String style = 'default',
    String size = 'story',
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/share/profile',
      data: {
        'style': style,
        'size': size,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: ShareCardResponse.fromJson(response.data!),
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }
}

/// 分享卡片响应
class ShareCardResponse {
  final String imageUrl;
  final DateTime? expiresAt;

  ShareCardResponse({
    required this.imageUrl,
    this.expiresAt,
  });

  factory ShareCardResponse.fromJson(Map<String, dynamic> json) {
    return ShareCardResponse(
      imageUrl: json['imageUrl'] as String,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}
