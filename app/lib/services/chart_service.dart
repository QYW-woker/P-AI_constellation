import '../models/api_response.dart';
import '../models/user.dart';
import 'api_client.dart';

/// 星盘服务
class ChartService {
  final ApiClient _api = ApiClient();

  /// 获取星盘
  Future<ApiResponse<NatalChart>> getChart() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/chart',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: NatalChart.fromJson(response.data!),
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 生成星盘
  Future<ApiResponse<NatalChart>> generateChart() async {
    final response = await _api.post<Map<String, dynamic>>(
      '/chart',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: NatalChart.fromJson(response.data!),
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 获取星盘解读
  Future<ApiResponse<ChartInterpretation>> getInterpretation() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/chart/interpretation',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: ChartInterpretation.fromJson(response.data!),
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }
}

/// 星盘解读模型
class ChartInterpretation {
  final SunMoonRising sunMoonRising;
  final List<PlanetInterpretation> planets;
  final String? summary;

  ChartInterpretation({
    required this.sunMoonRising,
    required this.planets,
    this.summary,
  });

  factory ChartInterpretation.fromJson(Map<String, dynamic> json) {
    return ChartInterpretation(
      sunMoonRising:
          SunMoonRising.fromJson(json['sunMoonRising'] as Map<String, dynamic>),
      planets: (json['planets'] as List? ?? [])
          .map((e) => PlanetInterpretation.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: json['summary'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sunMoonRising': sunMoonRising.toJson(),
      'planets': planets.map((e) => e.toJson()).toList(),
      'summary': summary,
    };
  }
}

/// 太阳月亮上升解读
class SunMoonRising {
  final SignInterpretation sun;
  final SignInterpretation moon;
  final SignInterpretation rising;

  SunMoonRising({
    required this.sun,
    required this.moon,
    required this.rising,
  });

  factory SunMoonRising.fromJson(Map<String, dynamic> json) {
    return SunMoonRising(
      sun: SignInterpretation.fromJson(json['sun'] as Map<String, dynamic>),
      moon: SignInterpretation.fromJson(json['moon'] as Map<String, dynamic>),
      rising:
          SignInterpretation.fromJson(json['rising'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sun': sun.toJson(),
      'moon': moon.toJson(),
      'rising': rising.toJson(),
    };
  }
}

/// 星座解读
class SignInterpretation {
  final String sign;
  final String title;
  final String description;
  final List<String> keywords;
  final List<String> strengths;
  final List<String> challenges;

  SignInterpretation({
    required this.sign,
    required this.title,
    required this.description,
    required this.keywords,
    required this.strengths,
    required this.challenges,
  });

  factory SignInterpretation.fromJson(Map<String, dynamic> json) {
    return SignInterpretation(
      sign: json['sign'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      keywords: List<String>.from(json['keywords'] as List? ?? []),
      strengths: List<String>.from(json['strengths'] as List? ?? []),
      challenges: List<String>.from(json['challenges'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sign': sign,
      'title': title,
      'description': description,
      'keywords': keywords,
      'strengths': strengths,
      'challenges': challenges,
    };
  }
}

/// 行星解读
class PlanetInterpretation {
  final String planet;
  final String sign;
  final int house;
  final String title;
  final String description;

  PlanetInterpretation({
    required this.planet,
    required this.sign,
    required this.house,
    required this.title,
    required this.description,
  });

  factory PlanetInterpretation.fromJson(Map<String, dynamic> json) {
    return PlanetInterpretation(
      planet: json['planet'] as String,
      sign: json['sign'] as String,
      house: json['house'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planet': planet,
      'sign': sign,
      'house': house,
      'title': title,
      'description': description,
    };
  }
}
