/// 用户模型
class User {
  final String id;
  final String? phone;
  final String? wxOpenid;
  final String nickname;
  final String? avatarUrl;
  final String? gender;
  final bool isVip;
  final DateTime? vipExpireAt;
  final String inviteCode;
  final String? invitedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BirthInfo? birthInfo;
  final NatalChart? natalChart;

  User({
    required this.id,
    this.phone,
    this.wxOpenid,
    required this.nickname,
    this.avatarUrl,
    this.gender,
    this.isVip = false,
    this.vipExpireAt,
    required this.inviteCode,
    this.invitedBy,
    required this.createdAt,
    required this.updatedAt,
    this.birthInfo,
    this.natalChart,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phone: json['phone'] as String?,
      wxOpenid: json['wxOpenid'] as String?,
      nickname: json['nickname'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      gender: json['gender'] as String?,
      isVip: json['isVip'] as bool? ?? false,
      vipExpireAt: json['vipExpireAt'] != null
          ? DateTime.parse(json['vipExpireAt'] as String)
          : null,
      inviteCode: json['inviteCode'] as String,
      invitedBy: json['invitedBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      birthInfo: json['birthInfo'] != null
          ? BirthInfo.fromJson(json['birthInfo'] as Map<String, dynamic>)
          : null,
      natalChart: json['natalChart'] != null
          ? NatalChart.fromJson(json['natalChart'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'wxOpenid': wxOpenid,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'gender': gender,
      'isVip': isVip,
      'vipExpireAt': vipExpireAt?.toIso8601String(),
      'inviteCode': inviteCode,
      'invitedBy': invitedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'birthInfo': birthInfo?.toJson(),
      'natalChart': natalChart?.toJson(),
    };
  }

  User copyWith({
    String? nickname,
    String? avatarUrl,
    String? gender,
    bool? isVip,
    DateTime? vipExpireAt,
    BirthInfo? birthInfo,
    NatalChart? natalChart,
  }) {
    return User(
      id: id,
      phone: phone,
      wxOpenid: wxOpenid,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      isVip: isVip ?? this.isVip,
      vipExpireAt: vipExpireAt ?? this.vipExpireAt,
      inviteCode: inviteCode,
      invitedBy: invitedBy,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      birthInfo: birthInfo ?? this.birthInfo,
      natalChart: natalChart ?? this.natalChart,
    );
  }

  /// 是否已填写出生信息
  bool get hasBirthInfo => birthInfo != null;

  /// 是否已生成星盘
  bool get hasNatalChart => natalChart != null;

  /// VIP是否有效
  bool get isVipActive {
    if (!isVip) return false;
    if (vipExpireAt == null) return false;
    return vipExpireAt!.isAfter(DateTime.now());
  }

  /// 获取剩余VIP天数
  int get vipDaysRemaining {
    if (!isVipActive) return 0;
    return vipExpireAt!.difference(DateTime.now()).inDays;
  }
}

/// 出生信息
class BirthInfo {
  final String id;
  final String userId;
  final DateTime birthDate;
  final String birthTime;
  final String birthCity;
  final double latitude;
  final double longitude;
  final String timezone;
  final DateTime createdAt;
  final DateTime updatedAt;

  BirthInfo({
    required this.id,
    required this.userId,
    required this.birthDate,
    required this.birthTime,
    required this.birthCity,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BirthInfo.fromJson(Map<String, dynamic> json) {
    return BirthInfo(
      id: json['id'] as String,
      userId: json['userId'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      birthTime: json['birthTime'] as String,
      birthCity: json['birthCity'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'birthDate': birthDate.toIso8601String(),
      'birthTime': birthTime,
      'birthCity': birthCity,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// 本命星盘
class NatalChart {
  final String id;
  final String userId;
  final String sunSign;
  final String moonSign;
  final String risingSign;
  final List<PlanetPosition> planets;
  final List<HouseInfo> houses;
  final List<AspectInfo> aspects;
  final Map<String, int> elementCounts;
  final Map<String, int> modeCounts;
  final String? interpretation;
  final DateTime createdAt;
  final DateTime updatedAt;

  NatalChart({
    required this.id,
    required this.userId,
    required this.sunSign,
    required this.moonSign,
    required this.risingSign,
    required this.planets,
    required this.houses,
    required this.aspects,
    required this.elementCounts,
    required this.modeCounts,
    this.interpretation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NatalChart.fromJson(Map<String, dynamic> json) {
    return NatalChart(
      id: json['id'] as String,
      userId: json['userId'] as String,
      sunSign: json['sunSign'] as String,
      moonSign: json['moonSign'] as String,
      risingSign: json['risingSign'] as String,
      planets: (json['planets'] as List)
          .map((e) => PlanetPosition.fromJson(e as Map<String, dynamic>))
          .toList(),
      houses: (json['houses'] as List)
          .map((e) => HouseInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      aspects: (json['aspects'] as List)
          .map((e) => AspectInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      elementCounts: Map<String, int>.from(json['elementCounts'] as Map),
      modeCounts: Map<String, int>.from(json['modeCounts'] as Map),
      interpretation: json['interpretation'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'sunSign': sunSign,
      'moonSign': moonSign,
      'risingSign': risingSign,
      'planets': planets.map((e) => e.toJson()).toList(),
      'houses': houses.map((e) => e.toJson()).toList(),
      'aspects': aspects.map((e) => e.toJson()).toList(),
      'elementCounts': elementCounts,
      'modeCounts': modeCounts,
      'interpretation': interpretation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 获取主导元素
  String get dominantElement {
    String dominant = 'fire';
    int maxCount = 0;
    elementCounts.forEach((element, count) {
      if (count > maxCount) {
        maxCount = count;
        dominant = element;
      }
    });
    return dominant;
  }

  /// 获取主导模式
  String get dominantMode {
    String dominant = 'cardinal';
    int maxCount = 0;
    modeCounts.forEach((mode, count) {
      if (count > maxCount) {
        maxCount = count;
        dominant = mode;
      }
    });
    return dominant;
  }
}

/// 行星位置
class PlanetPosition {
  final String planet;
  final String sign;
  final double degree;
  final int house;
  final bool isRetrograde;

  PlanetPosition({
    required this.planet,
    required this.sign,
    required this.degree,
    required this.house,
    this.isRetrograde = false,
  });

  factory PlanetPosition.fromJson(Map<String, dynamic> json) {
    return PlanetPosition(
      planet: json['planet'] as String,
      sign: json['sign'] as String,
      degree: (json['degree'] as num).toDouble(),
      house: json['house'] as int,
      isRetrograde: json['isRetrograde'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planet': planet,
      'sign': sign,
      'degree': degree,
      'house': house,
      'isRetrograde': isRetrograde,
    };
  }

  /// 格式化度数显示
  String get formattedDegree {
    final deg = degree.floor();
    final min = ((degree - deg) * 60).round();
    return '$deg°$min\'';
  }
}

/// 宫位信息
class HouseInfo {
  final int house;
  final String sign;
  final double degree;

  HouseInfo({
    required this.house,
    required this.sign,
    required this.degree,
  });

  factory HouseInfo.fromJson(Map<String, dynamic> json) {
    return HouseInfo(
      house: json['house'] as int,
      sign: json['sign'] as String,
      degree: (json['degree'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'house': house,
      'sign': sign,
      'degree': degree,
    };
  }
}

/// 相位信息
class AspectInfo {
  final String planet1;
  final String planet2;
  final String type;
  final double orb;
  final bool isApplying;

  AspectInfo({
    required this.planet1,
    required this.planet2,
    required this.type,
    required this.orb,
    this.isApplying = false,
  });

  factory AspectInfo.fromJson(Map<String, dynamic> json) {
    return AspectInfo(
      planet1: json['planet1'] as String,
      planet2: json['planet2'] as String,
      type: json['type'] as String,
      orb: (json['orb'] as num).toDouble(),
      isApplying: json['isApplying'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planet1': planet1,
      'planet2': planet2,
      'type': type,
      'orb': orb,
      'isApplying': isApplying,
    };
  }

  /// 获取相位符号
  String get symbol {
    switch (type) {
      case 'conjunction':
        return '☌';
      case 'opposition':
        return '☍';
      case 'trine':
        return '△';
      case 'square':
        return '□';
      case 'sextile':
        return '⚹';
      default:
        return '';
    }
  }
}
