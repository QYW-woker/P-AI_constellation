import 'user.dart';

/// 好友模型
class Friend {
  final String id;
  final String friendId;
  final String nickname;
  final String? avatarUrl;
  final String? sunSign;
  final String? moonSign;
  final String? risingSign;
  final int compatibilityScore;
  final DateTime createdAt;

  Friend({
    required this.id,
    required this.friendId,
    required this.nickname,
    this.avatarUrl,
    this.sunSign,
    this.moonSign,
    this.risingSign,
    required this.compatibilityScore,
    required this.createdAt,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      friendId: json['friendId'] as String,
      nickname: json['nickname'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      sunSign: json['sunSign'] as String?,
      moonSign: json['moonSign'] as String?,
      risingSign: json['risingSign'] as String?,
      compatibilityScore: json['compatibilityScore'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'friendId': friendId,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'sunSign': sunSign,
      'moonSign': moonSign,
      'risingSign': risingSign,
      'compatibilityScore': compatibilityScore,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 是否有星盘数据
  bool get hasChart => sunSign != null && moonSign != null && risingSign != null;

  /// 获取配对等级描述
  String get compatibilityLevel {
    if (compatibilityScore >= 90) return '绝配';
    if (compatibilityScore >= 80) return '非常契合';
    if (compatibilityScore >= 70) return '比较契合';
    if (compatibilityScore >= 60) return '一般';
    if (compatibilityScore >= 50) return '需要磨合';
    return '挑战较大';
  }
}

/// 好友关系
class Friendship {
  final String id;
  final String userId;
  final String friendId;
  final int compatibilityScore;
  final DateTime createdAt;
  final User? friend;

  Friendship({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.compatibilityScore,
    required this.createdAt,
    this.friend,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      id: json['id'] as String,
      userId: json['userId'] as String,
      friendId: json['friendId'] as String,
      compatibilityScore: json['compatibilityScore'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      friend: json['friend'] != null
          ? User.fromJson(json['friend'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'friendId': friendId,
      'compatibilityScore': compatibilityScore,
      'createdAt': createdAt.toIso8601String(),
      'friend': friend?.toJson(),
    };
  }
}

/// 添加好友请求
class AddFriendRequest {
  final String? friendId;
  final String? inviteCode;

  AddFriendRequest({
    this.friendId,
    this.inviteCode,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (friendId != null) map['friendId'] = friendId;
    if (inviteCode != null) map['inviteCode'] = inviteCode;
    return map;
  }
}
