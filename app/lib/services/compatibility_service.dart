import '../models/api_response.dart';
import '../models/compatibility.dart';
import 'api_client.dart';

/// 配对服务
class CompatibilityService {
  final ApiClient _api = ApiClient();

  /// 获取配对概览
  Future<ApiResponse<CompatibilityOverview>> getOverview(String friendId) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/compatibility/$friendId',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: CompatibilityOverview.fromJson(response.data!),
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 获取详细配对报告
  Future<ApiResponse<CompatibilityReport>> getReport(String friendId) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/compatibility/$friendId/report',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: CompatibilityReport.fromJson(response.data!),
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 购买配对报告
  Future<ApiResponse<CompatibilityReport>> purchaseReport(String friendId) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/compatibility/$friendId/report',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: CompatibilityReport.fromJson(response.data!),
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 检查是否已购买报告
  Future<ApiResponse<bool>> hasPurchasedReport(String friendId) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/compatibility/$friendId/purchased',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: response.data!['purchased'] as bool? ?? false,
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: false,
    );
  }
}
