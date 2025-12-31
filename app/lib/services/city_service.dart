import '../models/api_response.dart';
import '../models/city.dart';
import 'api_client.dart';

/// 城市服务
class CityService {
  final ApiClient _api = ApiClient();

  /// 获取热门城市
  Future<ApiResponse<List<City>>> getHotCities() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/cities/hot',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final items = (response.data!['cities'] as List? ?? [])
          .map((e) => City.fromJson(e as Map<String, dynamic>))
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

  /// 搜索城市
  Future<ApiResponse<List<City>>> searchCities(String keyword) async {
    if (keyword.isEmpty) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: [],
      );
    }

    final response = await _api.get<Map<String, dynamic>>(
      '/cities/search',
      queryParameters: {'keyword': keyword},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final items = (response.data!['cities'] as List? ?? [])
          .map((e) => City.fromJson(e as Map<String, dynamic>))
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

  /// 获取城市详情
  Future<ApiResponse<City>> getCityDetail(String cityId) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/cities/$cityId',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: City.fromJson(response.data!),
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }
}
