/// API统一响应模型
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
    );
  }

  /// 是否成功
  bool get isSuccess => code == 0;

  /// 是否失败
  bool get isError => code != 0;

  /// 是否未登录
  bool get isUnauthorized => code == 11001 || code == 11002;

  /// 是否无权限
  bool get isForbidden => code == 11003;
}

/// 分页响应模型
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final itemsJson = json['items'] as List? ?? [];
    return PaginatedResponse<T>(
      items: itemsJson.map((e) => fromJsonT(e as Map<String, dynamic>)).toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  /// 总页数
  int get totalPages => (total / pageSize).ceil();

  /// 是否是最后一页
  bool get isLastPage => page >= totalPages;

  /// 是否为空
  bool get isEmpty => items.isEmpty;

  /// 是否非空
  bool get isNotEmpty => items.isNotEmpty;
}

/// 登录响应模型
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final bool isNewUser;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.isNewUser,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int,
      isNewUser: json['isNewUser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'isNewUser': isNewUser,
    };
  }
}

/// 邀请信息响应
class InviteInfo {
  final String inviteCode;
  final int inviteCount;
  final int rewardDays;
  final List<InviteRecord> records;

  InviteInfo({
    required this.inviteCode,
    required this.inviteCount,
    required this.rewardDays,
    required this.records,
  });

  factory InviteInfo.fromJson(Map<String, dynamic> json) {
    return InviteInfo(
      inviteCode: json['inviteCode'] as String,
      inviteCount: json['inviteCount'] as int? ?? 0,
      rewardDays: json['rewardDays'] as int? ?? 0,
      records: (json['records'] as List? ?? [])
          .map((e) => InviteRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inviteCode': inviteCode,
      'inviteCount': inviteCount,
      'rewardDays': rewardDays,
      'records': records.map((e) => e.toJson()).toList(),
    };
  }
}

/// 邀请记录
class InviteRecord {
  final String inviteeId;
  final String inviteeNickname;
  final String? inviteeAvatarUrl;
  final int rewardDays;
  final DateTime createdAt;

  InviteRecord({
    required this.inviteeId,
    required this.inviteeNickname,
    this.inviteeAvatarUrl,
    required this.rewardDays,
    required this.createdAt,
  });

  factory InviteRecord.fromJson(Map<String, dynamic> json) {
    return InviteRecord(
      inviteeId: json['inviteeId'] as String,
      inviteeNickname: json['inviteeNickname'] as String,
      inviteeAvatarUrl: json['inviteeAvatarUrl'] as String?,
      rewardDays: json['rewardDays'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inviteeId': inviteeId,
      'inviteeNickname': inviteeNickname,
      'inviteeAvatarUrl': inviteeAvatarUrl,
      'rewardDays': rewardDays,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// 分享响应
class ShareResponse {
  final String imageUrl;
  final DateTime? expiresAt;

  ShareResponse({
    required this.imageUrl,
    this.expiresAt,
  });

  factory ShareResponse.fromJson(Map<String, dynamic> json) {
    return ShareResponse(
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
