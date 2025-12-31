import 'package:intl/intl.dart';
import '../models/api_response.dart';
import '../models/horoscope.dart';
import 'api_client.dart';

/// 运势服务
class HoroscopeService {
  final ApiClient _api = ApiClient();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// 获取每日运势
  Future<ApiResponse<DailyHoroscope>> getDailyHoroscope({DateTime? date}) async {
    final queryParams = <String, dynamic>{};
    if (date != null) {
      queryParams['date'] = _dateFormat.format(date);
    }

    final response = await _api.get<Map<String, dynamic>>(
      '/horoscope/daily',
      queryParameters: queryParams,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: DailyHoroscope.fromJson(response.data!),
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 获取每周运势
  Future<ApiResponse<WeeklyHoroscope>> getWeeklyHoroscope() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/horoscope/weekly',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: WeeklyHoroscope.fromJson(response.data!),
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 获取历史运势列表
  Future<ApiResponse<List<DailyHoroscope>>> getHoroscopeHistory({
    int page = 1,
    int pageSize = 7,
  }) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/horoscope/history',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final items = (response.data!['items'] as List? ?? [])
          .map((e) => DailyHoroscope.fromJson(e as Map<String, dynamic>))
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
