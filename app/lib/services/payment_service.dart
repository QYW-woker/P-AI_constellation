import '../models/api_response.dart';
import '../models/payment.dart';
import 'api_client.dart';

/// 支付服务
class PaymentService {
  final ApiClient _api = ApiClient();

  /// 获取商品列表
  Future<ApiResponse<List<Product>>> getProducts() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/payment/products',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final items = (response.data!['products'] as List? ?? [])
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
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

  /// 创建订单
  Future<ApiResponse<CreateOrderResponse>> createOrder({
    required String productType,
    required String paymentMethod,
    String? friendId,
  }) async {
    final data = <String, dynamic>{
      'productType': productType,
      'paymentMethod': paymentMethod,
    };
    if (friendId != null) {
      data['friendId'] = friendId;
    }

    final response = await _api.post<Map<String, dynamic>>(
      '/payment/order',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: CreateOrderResponse.fromJson(response.data!),
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 验证苹果支付
  Future<ApiResponse<void>> verifyApplePay({
    required String orderId,
    required String receiptData,
    required String transactionId,
  }) async {
    return await _api.post('/payment/apple/verify', data: {
      'orderId': orderId,
      'receiptData': receiptData,
      'transactionId': transactionId,
    });
  }

  /// 获取订单列表
  Future<ApiResponse<List<Order>>> getOrders({
    int page = 1,
    int pageSize = 20,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (status != null) {
      queryParams['status'] = status;
    }

    final response = await _api.get<Map<String, dynamic>>(
      '/payment/orders',
      queryParameters: queryParams,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final items = (response.data!['items'] as List? ?? [])
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
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

  /// 获取订单详情
  Future<ApiResponse<Order>> getOrderDetail(String orderId) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/payment/orders/$orderId',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      return ApiResponse(
        code: 0,
        message: 'success',
        data: Order.fromJson(response.data!),
      );
    }

    return ApiResponse(
      code: response.code,
      message: response.message,
      data: null,
    );
  }

  /// 取消订单
  Future<ApiResponse<void>> cancelOrder(String orderId) async {
    return await _api.post('/payment/orders/$orderId/cancel');
  }

  /// 获取购买记录
  Future<ApiResponse<List<Purchase>>> getPurchases({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/payment/purchases',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final items = (response.data!['items'] as List? ?? [])
          .map((e) => Purchase.fromJson(e as Map<String, dynamic>))
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
