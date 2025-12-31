/// 每日运势模型
class DailyHoroscope {
  final String id;
  final String userId;
  final DateTime date;
  final HoroscopeScores scores;
  final String summary;
  final List<String> doList;
  final List<String> dontList;
  final String luckyColor;
  final int luckyNumber;
  final String luckyDirection;
  final String luckyTime;
  final DateTime createdAt;

  DailyHoroscope({
    required this.id,
    required this.userId,
    required this.date,
    required this.scores,
    required this.summary,
    required this.doList,
    required this.dontList,
    required this.luckyColor,
    required this.luckyNumber,
    required this.luckyDirection,
    required this.luckyTime,
    required this.createdAt,
  });

  factory DailyHoroscope.fromJson(Map<String, dynamic> json) {
    return DailyHoroscope(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      scores: HoroscopeScores.fromJson(json['scores'] as Map<String, dynamic>),
      summary: json['summary'] as String,
      doList: List<String>.from(json['doList'] as List),
      dontList: List<String>.from(json['dontList'] as List),
      luckyColor: json['luckyColor'] as String,
      luckyNumber: json['luckyNumber'] as int,
      luckyDirection: json['luckyDirection'] as String,
      luckyTime: json['luckyTime'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'scores': scores.toJson(),
      'summary': summary,
      'doList': doList,
      'dontList': dontList,
      'luckyColor': luckyColor,
      'luckyNumber': luckyNumber,
      'luckyDirection': luckyDirection,
      'luckyTime': luckyTime,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 获取综合评分
  int get overallScore => scores.overall;

  /// 获取最高分维度
  String get bestDimension {
    final dimensions = {
      'love': scores.love,
      'career': scores.career,
      'wealth': scores.wealth,
      'health': scores.health,
    };
    return dimensions.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// 获取最低分维度
  String get worstDimension {
    final dimensions = {
      'love': scores.love,
      'career': scores.career,
      'wealth': scores.wealth,
      'health': scores.health,
    };
    return dimensions.entries.reduce((a, b) => a.value < b.value ? a : b).key;
  }
}

/// 运势评分
class HoroscopeScores {
  final int overall;
  final int love;
  final int career;
  final int wealth;
  final int health;

  HoroscopeScores({
    required this.overall,
    required this.love,
    required this.career,
    required this.wealth,
    required this.health,
  });

  factory HoroscopeScores.fromJson(Map<String, dynamic> json) {
    return HoroscopeScores(
      overall: json['overall'] as int,
      love: json['love'] as int,
      career: json['career'] as int,
      wealth: json['wealth'] as int,
      health: json['health'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall': overall,
      'love': love,
      'career': career,
      'wealth': wealth,
      'health': health,
    };
  }

  /// 获取平均分
  double get average => (overall + love + career + wealth + health) / 5;

  /// 获取指定维度的分数
  int getScore(String dimension) {
    switch (dimension) {
      case 'overall':
        return overall;
      case 'love':
        return love;
      case 'career':
        return career;
      case 'wealth':
        return wealth;
      case 'health':
        return health;
      default:
        return 0;
    }
  }
}

/// 每周运势模型
class WeeklyHoroscope {
  final String id;
  final String userId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final String summary;
  final List<WeeklyTrend> trends;
  final String advice;
  final DateTime createdAt;

  WeeklyHoroscope({
    required this.id,
    required this.userId,
    required this.weekStart,
    required this.weekEnd,
    required this.summary,
    required this.trends,
    required this.advice,
    required this.createdAt,
  });

  factory WeeklyHoroscope.fromJson(Map<String, dynamic> json) {
    return WeeklyHoroscope(
      id: json['id'] as String,
      userId: json['userId'] as String,
      weekStart: DateTime.parse(json['weekStart'] as String),
      weekEnd: DateTime.parse(json['weekEnd'] as String),
      summary: json['summary'] as String,
      trends: (json['trends'] as List)
          .map((e) => WeeklyTrend.fromJson(e as Map<String, dynamic>))
          .toList(),
      advice: json['advice'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'weekStart': weekStart.toIso8601String(),
      'weekEnd': weekEnd.toIso8601String(),
      'summary': summary,
      'trends': trends.map((e) => e.toJson()).toList(),
      'advice': advice,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// 每周趋势
class WeeklyTrend {
  final String dimension;
  final int score;
  final String trend;
  final String description;

  WeeklyTrend({
    required this.dimension,
    required this.score,
    required this.trend,
    required this.description,
  });

  factory WeeklyTrend.fromJson(Map<String, dynamic> json) {
    return WeeklyTrend(
      dimension: json['dimension'] as String,
      score: json['score'] as int,
      trend: json['trend'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dimension': dimension,
      'score': score,
      'trend': trend,
      'description': description,
    };
  }

  /// 趋势是否上升
  bool get isRising => trend == 'up';

  /// 趋势是否下降
  bool get isFalling => trend == 'down';
}
