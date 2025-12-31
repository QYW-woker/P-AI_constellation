/// 配对概览模型
class CompatibilityOverview {
  final String friendId;
  final String friendNickname;
  final String? friendAvatarUrl;
  final String? friendSunSign;
  final int totalScore;
  final Map<String, int> dimensions;
  final String summary;
  final bool hasDetailedReport;

  CompatibilityOverview({
    required this.friendId,
    required this.friendNickname,
    this.friendAvatarUrl,
    this.friendSunSign,
    required this.totalScore,
    required this.dimensions,
    required this.summary,
    required this.hasDetailedReport,
  });

  factory CompatibilityOverview.fromJson(Map<String, dynamic> json) {
    return CompatibilityOverview(
      friendId: json['friendId'] as String,
      friendNickname: json['friendNickname'] as String,
      friendAvatarUrl: json['friendAvatarUrl'] as String?,
      friendSunSign: json['friendSunSign'] as String?,
      totalScore: json['totalScore'] as int,
      dimensions: Map<String, int>.from(json['dimensions'] as Map),
      summary: json['summary'] as String,
      hasDetailedReport: json['hasDetailedReport'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
      'friendNickname': friendNickname,
      'friendAvatarUrl': friendAvatarUrl,
      'friendSunSign': friendSunSign,
      'totalScore': totalScore,
      'dimensions': dimensions,
      'summary': summary,
      'hasDetailedReport': hasDetailedReport,
    };
  }

  /// 获取匹配等级
  String get matchLevel {
    if (totalScore >= 90) return '天作之合';
    if (totalScore >= 80) return '绝佳搭档';
    if (totalScore >= 70) return '相处融洽';
    if (totalScore >= 60) return '有缘有份';
    if (totalScore >= 50) return '需要磨合';
    return '互相学习';
  }

  /// 获取最佳匹配维度
  String get bestDimension {
    return dimensions.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// 获取最需改善维度
  String get improveDimension {
    return dimensions.entries.reduce((a, b) => a.value < b.value ? a : b).key;
  }
}

/// 配对详细报告
class CompatibilityReport {
  final String id;
  final String userId;
  final String friendId;
  final int totalScore;
  final Map<String, DimensionDetail> dimensions;
  final String summary;
  final List<String> strengths;
  final List<String> challenges;
  final List<String> suggestions;
  final DateTime createdAt;

  CompatibilityReport({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.totalScore,
    required this.dimensions,
    required this.summary,
    required this.strengths,
    required this.challenges,
    required this.suggestions,
    required this.createdAt,
  });

  factory CompatibilityReport.fromJson(Map<String, dynamic> json) {
    final dimensionsJson = json['dimensions'] as Map<String, dynamic>;
    final dimensions = <String, DimensionDetail>{};
    dimensionsJson.forEach((key, value) {
      dimensions[key] = DimensionDetail.fromJson(value as Map<String, dynamic>);
    });

    return CompatibilityReport(
      id: json['id'] as String,
      userId: json['userId'] as String,
      friendId: json['friendId'] as String,
      totalScore: json['totalScore'] as int,
      dimensions: dimensions,
      summary: json['summary'] as String,
      strengths: List<String>.from(json['strengths'] as List),
      challenges: List<String>.from(json['challenges'] as List),
      suggestions: List<String>.from(json['suggestions'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'friendId': friendId,
      'totalScore': totalScore,
      'dimensions': dimensions.map((k, v) => MapEntry(k, v.toJson())),
      'summary': summary,
      'strengths': strengths,
      'challenges': challenges,
      'suggestions': suggestions,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// 维度详情
class DimensionDetail {
  final int score;
  final String title;
  final String description;
  final List<String> details;

  DimensionDetail({
    required this.score,
    required this.title,
    required this.description,
    required this.details,
  });

  factory DimensionDetail.fromJson(Map<String, dynamic> json) {
    return DimensionDetail(
      score: json['score'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      details: List<String>.from(json['details'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'title': title,
      'description': description,
      'details': details,
    };
  }

  /// 获取等级描述
  String get levelText {
    if (score >= 90) return '极佳';
    if (score >= 80) return '很好';
    if (score >= 70) return '良好';
    if (score >= 60) return '一般';
    if (score >= 50) return '待改善';
    return '需努力';
  }
}
