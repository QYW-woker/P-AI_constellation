/// 商品模型
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String type;
  final Map<String, dynamic>? metadata;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.type,
    this.metadata,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
      type: json['type'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'type': type,
      'metadata': metadata,
    };
  }

  /// 是否有折扣
  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  /// 折扣百分比
  int get discountPercent {
    if (!hasDiscount) return 0;
    return ((1 - price / originalPrice!) * 100).round();
  }

  /// 是否是会员商品
  bool get isMembership => type.startsWith('membership_');

  /// 是否是报告商品
  bool get isReport =>
      type == 'compatibility_report' || type == 'deep_chart_report';
}

/// 订单模型
class Order {
  final String id;
  final String userId;
  final String productType;
  final double amount;
  final String status;
  final String paymentMethod;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime? paidAt;

  Order({
    required this.id,
    required this.userId,
    required this.productType,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    required this.createdAt,
    this.paidAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['userId'] as String,
      productType: json['productType'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String,
      transactionId: json['transactionId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      paidAt:
          json['paidAt'] != null ? DateTime.parse(json['paidAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productType': productType,
      'amount': amount,
      'status': status,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
    };
  }

  /// 是否已支付
  bool get isPaid => status == 'paid';

  /// 是否待支付
  bool get isPending => status == 'pending';

  /// 是否已取消
  bool get isCancelled => status == 'cancelled';

  /// 是否已退款
  bool get isRefunded => status == 'refunded';

  /// 获取状态文本
  String get statusText {
    switch (status) {
      case 'pending':
        return '待支付';
      case 'paid':
        return '已支付';
      case 'cancelled':
        return '已取消';
      case 'refunded':
        return '已退款';
      default:
        return '未知';
    }
  }

  /// 获取支付方式文本
  String get paymentMethodText {
    switch (paymentMethod) {
      case 'wechat':
        return '微信支付';
      case 'apple':
        return 'Apple Pay';
      default:
        return paymentMethod;
    }
  }
}

/// 创建订单请求
class CreateOrderRequest {
  final String productType;
  final String paymentMethod;
  final String? friendId;

  CreateOrderRequest({
    required this.productType,
    required this.paymentMethod,
    this.friendId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'productType': productType,
      'paymentMethod': paymentMethod,
    };
    if (friendId != null) map['friendId'] = friendId;
    return map;
  }
}

/// 订单创建响应
class CreateOrderResponse {
  final String orderId;
  final String? prepayId;
  final Map<String, dynamic>? paymentParams;

  CreateOrderResponse({
    required this.orderId,
    this.prepayId,
    this.paymentParams,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      orderId: json['orderId'] as String,
      prepayId: json['prepayId'] as String?,
      paymentParams: json['paymentParams'] as Map<String, dynamic>?,
    );
  }
}

/// 会员信息
class Membership {
  final bool isVip;
  final DateTime? expireAt;
  final int daysRemaining;
  final String? plan;

  Membership({
    required this.isVip,
    this.expireAt,
    required this.daysRemaining,
    this.plan,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      isVip: json['isVip'] as bool,
      expireAt: json['expireAt'] != null
          ? DateTime.parse(json['expireAt'] as String)
          : null,
      daysRemaining: json['daysRemaining'] as int? ?? 0,
      plan: json['plan'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isVip': isVip,
      'expireAt': expireAt?.toIso8601String(),
      'daysRemaining': daysRemaining,
      'plan': plan,
    };
  }

  /// 会员是否有效
  bool get isActive => isVip && daysRemaining > 0;

  /// 是否即将过期（7天内）
  bool get isExpiringSoon => isActive && daysRemaining <= 7;
}

/// 购买记录
class Purchase {
  final String id;
  final String userId;
  final String productType;
  final String orderId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  Purchase({
    required this.id,
    required this.userId,
    required this.productType,
    required this.orderId,
    this.metadata,
    required this.createdAt,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] as String,
      userId: json['userId'] as String,
      productType: json['productType'] as String,
      orderId: json['orderId'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productType': productType,
      'orderId': orderId,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
